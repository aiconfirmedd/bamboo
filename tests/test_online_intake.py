"""Security boundaries: real HTTP handlers and PostgreSQL RLS, synthetic data only."""
import copy
import json
import os
from pathlib import Path
import secrets
import unittest
from urllib.parse import urlsplit
from unittest.mock import patch

# Provision an isolated test database; never point this at shared or production data.
DB=os.environ.get('INTAKE_TEST_DATABASE_URL')
for name in ['INTAKE_TEST_DATABASE_URL','INTAKE_TEST_ADMIN_URL']:
    if os.environ.get(name) and urlsplit(os.environ[name]).hostname not in {'localhost','127.0.0.1'}:
        raise ValueError('Intake integration tests require a disposable local PostgreSQL instance')

class OnlineIntakeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from intake.app import create_app
        cls.create_app=staticmethod(create_app)

    def setUp(self):
        self.subject='alice-'+secrets.token_hex(5)
        self.config={'APP_ORIGIN':'https://intake.example.test','SECRET_KEY':secrets.token_hex(32),
          'OIDC_ISSUER':'https://identity.example.test','OIDC_CLIENT_ID':'test-client',
          'OIDC_CLIENT_SECRET':'synthetic-secret','ALLOWED_EMAILS':'owner@example.test,other@example.test',
          'OPERATOR_EMAILS':'operator@example.test','DATABASE_URL':DB or 'postgresql://invalid',
          'RETENTION_DAYS':'30','TESTING':True}
        self.app=self.create_app(self.config);self.client=self.app.test_client()
        from scripts.prepare_setup import load_spec
        a={f['key']:(None if f['type']=='number' else f['default']) for f in load_spec()['fields']}
        a.update(company_name='Synthetic '+secrets.token_hex(4),project_name='Test portal',contact_name='Owner',
          contact_email='owner@example.test',account_owner_email='owner@example.test',acknowledge=True)
        self.data={'schema_version':1,'submitted_at':'2026-10-30T12:00:00Z','answers':a}
        self.headers={'Origin':'https://intake.example.test','X-CSRF-Token':'synthetic-csrf'}

    def login(self,subject=None,email='owner@example.test'):
        subject=subject or self.subject
        with self.client.session_transaction(base_url='https://intake.example.test') as s:
            s['identity']={'sub':subject,'email':email,'iss':'https://identity.example.test'};s['csrf']='synthetic-csrf';s.permanent=True

    def get(self,path):return self.client.get(path,base_url='https://intake.example.test')
    def post(self,path,data=None,headers=None):
        return self.client.post(path,json=data,headers=headers or self.headers,base_url='https://intake.example.test')

    def test_anonymous_cannot_read_form_or_submissions(self):
        for path in ['/form','/api/session','/api/submissions','/operator']:
            self.assertIn(self.get(path).status_code,[302,401])
        self.assertEqual(self.post('/api/submissions',self.data).status_code,401)

    def test_login_claims_require_verified_allowlisted_identity(self):
        from intake.app import allowed_identity
        base={'iss':'https://identity.example.test','sub':'alice','email':'owner@example.test','email_verified':True}
        self.assertEqual(allowed_identity(base,self.app.config)['sub'],'alice')
        for update in [{'email_verified':False},{'email':'attacker@example.test'},{'iss':'https://evil.example.test'},{'sub':''}]:
            with self.assertRaises(ValueError):allowed_identity(base|update,self.app.config)

    def test_mutations_require_csrf_and_exact_origin(self):
        self.login()
        for headers in [{'Origin':'https://intake.example.test'},{'Origin':'https://evil.example.test','X-CSRF-Token':'synthetic-csrf'},{'X-CSRF-Token':'synthetic-csrf'}]:
            self.assertEqual(self.post('/api/submissions',self.data,headers).status_code,403)
        self.assertEqual(self.post('/logout',{}, {'Origin':'https://evil.example.test','X-CSRF-Token':'synthetic-csrf'}).status_code,403)

    def test_unapproved_session_is_denied_and_operator_is_server_assigned(self):
        self.login(email='attacker@example.test')
        self.assertEqual(self.get('/api/session').status_code,403)
        self.login()
        self.assertEqual(self.get('/operator').status_code,403)

    def test_invalid_json_secrets_and_oversize_rejected_before_storage(self):
        self.login()
        for data in [{},self.data|{'unexpected':True},self.data|{'answers':self.data['answers']|{'notes':'ghp_'+'x'*30}}]:
            self.assertEqual(self.post('/api/submissions',data).status_code,400)
        response=self.client.post('/api/submissions',data='x'*1_000_001,content_type='application/json',headers=self.headers,base_url='https://intake.example.test')
        self.assertEqual(response.status_code,413)

    def test_startup_rejects_unsafe_public_configuration(self):
        for update in [{'APP_ORIGIN':'http://intake.example.test'},{'SECRET_KEY':'short'},{'RETENTION_DAYS':'0'},
                       {'TESTING':False,'DATABASE_URL':'postgresql://intake_runtime:synthetic@db.example.test/intake?sslmode=require'}]:
            with self.assertRaises(ValueError):self.create_app(self.config|update)

    def test_invalid_control_character_is_a_client_error(self):
        self.login()
        self.data['answers']['notes']='bad'+chr(0)+'input'
        self.assertEqual(self.post('/api/submissions',self.data).status_code,400)

    def test_form_online_mode_and_security_headers(self):
        self.login();r=self.get('/form')
        self.assertEqual(r.status_code,200)
        self.assertIn(b'/assets/online.js',r.data)
        self.assertIn("frame-ancestors 'none'",r.headers['Content-Security-Policy'])
        self.assertEqual(r.headers['Cache-Control'],'no-store')
        self.assertNotIn(b'synthetic-secret',r.data)

    def test_oidc_roundtrip_validates_state_nonce_and_signed_id_token(self):
        import time
        from urllib.parse import urlsplit,parse_qs
        from requests import Response as HTTPResponse
        from joserfc.jwk import RSAKey
        from joserfc import jwt
        key=RSAKey.generate_key(2048,{'kid':'synthetic-key'})
        for invalid in [None,'nonce','signature','state','unverified','audience']:
            client=self.create_app(self.config).test_client();nonce=''
            def transport(_session,request,**kwargs):
                response=HTTPResponse();response.status_code=200
                if request.url.endswith('/.well-known/openid-configuration'):
                    body={'issuer':'https://identity.example.test','authorization_endpoint':'https://identity.example.test/authorize','token_endpoint':'https://identity.example.test/token','jwks_uri':'https://identity.example.test/jwks','token_endpoint_auth_methods_supported':['client_secret_basic'],'id_token_signing_alg_values_supported':['RS256']}
                elif request.url.endswith('/jwks'):body={'keys':[key.as_dict(private=False)]}
                elif request.url.endswith('/token'):
                    claims={'iss':'https://identity.example.test','aud':'wrong-client' if invalid=='audience' else 'test-client','sub':'alice','email':'owner@example.test','email_verified':invalid!='unverified','iat':int(time.time()),'exp':int(time.time())+300,'nonce':'wrong' if invalid=='nonce' else nonce}
                    signing_key=RSAKey.generate_key(2048,{'kid':'synthetic-key'}) if invalid=='signature' else key
                    body={'access_token':'synthetic-access','token_type':'Bearer','id_token':jwt.encode({'alg':'RS256','kid':'synthetic-key'},claims,signing_key)}
                else:raise AssertionError('Unexpected external request: '+request.url)
                response._content=json.dumps(body).encode();response.headers['Content-Type']='application/json';return response
            with patch('requests.sessions.Session.send',transport):
                start=client.get('/login',base_url='https://intake.example.test')
                params=parse_qs(urlsplit(start.location).query);nonce=params['nonce'][0]
                self.assertIn('code_challenge',params)
                state='wrong' if invalid=='state' else params['state'][0]
                result=client.get('/auth/callback',query_string={'code':'synthetic-code','state':state},base_url='https://intake.example.test')
                self.assertEqual(result.status_code,302 if invalid is None else 403)
                if invalid is None:
                    self.assertEqual(client.get('/api/session',base_url='https://intake.example.test').status_code,200)
                    cookie=result.headers.get('Set-Cookie','')
                    self.assertIn('HttpOnly',cookie);self.assertIn('Secure',cookie)
                    with client.session_transaction(base_url='https://intake.example.test') as state:
                        self.assertNotIn('access_token',state);self.assertNotIn('id_token',state)

    @unittest.skipUnless(DB,'Set INTAKE_TEST_DATABASE_URL for real PostgreSQL tests')
    def test_expiry_purge_and_rate_limit(self):
        from intake.store import Store,RateLimited
        store=Store(DB);subject='rate-'+secrets.token_hex(5)
        sid,_=store.submit(subject,False,self.data,30)
        with store.transaction(subject,False) as db:
            # Audit inserts exercise the same database-backed rate counter as submissions.
            for _ in range(29):store.audit(db,subject,sid,'submit')
        with self.assertRaises(RateLimited):store.submit(subject,False,self.data,30)
        admin=os.environ.get('INTAKE_TEST_ADMIN_URL')
        if not admin:self.fail('INTAKE_TEST_ADMIN_URL required for expiry integration test')
        import psycopg
        with psycopg.connect(admin) as db:
            db.execute("UPDATE setup_intake.submissions SET created_at=now()-interval '32 days',expires_at=now()-interval '1 day' WHERE id=%s",(sid,))
        self.assertIsNone(store.export(subject,False,sid))
        self.assertFalse(any(str(row['id'])==sid for row in store.list(subject,False)))
        self.assertGreaterEqual(store.purge()['expired_submissions_deleted'],1)
        with store.transaction(subject,False) as db:
            self.assertEqual(db.execute('SELECT id FROM setup_intake.submissions WHERE id=%s',(sid,)).fetchall(),[])

    @unittest.skipUnless(DB,'Set INTAKE_TEST_DATABASE_URL for real PostgreSQL tests')
    def test_submission_idempotency_isolation_operator_export_and_delete(self):
        self.login();r=self.post('/api/submissions',self.data)
        self.assertEqual(r.status_code,201,r.data);sid=r.json['id']
        again=self.post('/api/submissions',self.data)
        self.assertEqual(again.json['id'],sid)
        self.assertNotIn('answers',r.json)
        self.assertEqual(self.get('/api/submissions/'+sid+'/export').json['answers'],self.data['answers'])
        self.login('bob','other@example.test')
        self.assertEqual(self.get('/api/submissions/'+sid+'/export').status_code,404)
        self.assertEqual(self.post('/api/submissions/'+sid+'/delete',{}).status_code,404)
        self.login('operator','operator@example.test')
        self.assertEqual(self.get('/operator').status_code,200)
        self.assertEqual(self.get('/api/submissions/'+sid+'/export').status_code,200)
        self.assertEqual(self.post('/api/submissions/'+sid+'/status',{'status':'reviewed'}).status_code,200)
        self.login();self.assertEqual(self.post('/api/submissions/'+sid+'/status',{'status':'closed'}).status_code,403)
        self.assertEqual(self.post('/api/submissions/'+sid+'/delete',{}).status_code,200)
        self.assertEqual(self.get('/api/submissions/'+sid+'/export').status_code,404)

    @unittest.skipUnless(DB,'Set INTAKE_TEST_DATABASE_URL for real PostgreSQL tests')
    def test_database_rls_blocks_cross_user_even_without_handler_checks(self):
        from intake.store import Store
        self.login();sid=self.post('/api/submissions',self.data).json['id'];store=Store(DB)
        with store.transaction('someone-else',False) as db:
            self.assertEqual(db.execute('SELECT id FROM setup_intake.submissions WHERE id=%s',(sid,)).fetchall(),[])
            self.assertEqual(db.execute('DELETE FROM setup_intake.submissions WHERE id=%s RETURNING id',(sid,)).fetchall(),[])
        with store.transaction(self.subject,False) as db:
            self.assertEqual(str(db.execute('SELECT id FROM setup_intake.submissions WHERE id=%s',(sid,)).fetchone()['id']),sid)

if __name__=='__main__':unittest.main()
