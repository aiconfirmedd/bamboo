"""Standalone authenticated setup intake; no HR app or provider provisioning."""
import base64
from datetime import timedelta
import hashlib
import hmac
import json
import os
from pathlib import Path
import re
import secrets
from urllib.parse import urlsplit
from authlib.integrations.flask_client import OAuth
from flask import Flask,abort,g,jsonify,redirect,render_template,request,session,Response
from werkzeug.exceptions import HTTPException
from scripts.prepare_setup import load_spec,validate,reject_constant
from intake.store import Store,RateLimited
from psycopg.conninfo import conninfo_to_dict
ROOT=Path(__file__).resolve().parents[1]

def emails(value):return {x.strip().lower() for x in value.split(',') if x.strip()}

def allowed_identity(claims,config):
    email=claims.get('email','')
    if (claims.get('iss')!=config['OIDC_ISSUER'] or not isinstance(claims.get('sub'),str)
        or not 1<=len(claims['sub'])<=255 or claims.get('email_verified') is not True
        or not isinstance(email,str) or email.lower() not in emails(config['ALLOWED_EMAILS'])|emails(config['OPERATOR_EMAILS'])):
        raise ValueError('Identity not permitted')
    return {'sub':claims['sub'],'email':email.lower(),'iss':claims['iss']}

def create_app(config=None):
    app=Flask(__name__,static_folder='static',static_url_path='/assets',template_folder='templates')
    names=['APP_ORIGIN','SECRET_KEY','DATABASE_URL','OIDC_ISSUER','OIDC_CLIENT_ID','OIDC_CLIENT_SECRET','ALLOWED_EMAILS','OPERATOR_EMAILS','RETENTION_DAYS']
    app.config.update({k:os.environ.get(k,'') for k in names})
    if config:app.config.update(config)
    for k in names:
        if not app.config.get(k):raise ValueError('Missing intake setting: '+k)
    if not app.testing:
        try:database=conninfo_to_dict(app.config['DATABASE_URL'])
        except Exception:raise ValueError('Invalid intake database configuration') from None
        if database.get('sslmode')!='verify-full':raise ValueError('Runtime database requires sslmode=verify-full')
    origin=urlsplit(app.config['APP_ORIGIN']);issuer=urlsplit(app.config['OIDC_ISSUER'])
    if (origin.scheme!='https' or not origin.hostname or origin.username or origin.password or origin.path not in ('','/') or origin.query or origin.fragment
        or issuer.scheme!='https' or not issuer.hostname or issuer.username or issuer.password or issuer.query or issuer.fragment):
        raise ValueError('APP_ORIGIN must be an HTTPS origin; OIDC_ISSUER must be an HTTPS issuer')
    app.config['APP_ORIGIN']=app.config['APP_ORIGIN'].rstrip('/')
    if len(app.config['SECRET_KEY'])<32:raise ValueError('SECRET_KEY needs at least 32 random characters')
    days=int(app.config['RETENTION_DAYS'])
    if not 1<=days<=365:raise ValueError('RETENTION_DAYS must be between 1 and 365')
    app.config.update(SESSION_COOKIE_NAME='__Host-intake',SESSION_COOKIE_SECURE=True,SESSION_COOKIE_HTTPONLY=True,
      SESSION_COOKIE_SAMESITE='Lax',PERMANENT_SESSION_LIFETIME=timedelta(hours=1),SESSION_REFRESH_EACH_REQUEST=False,
      MAX_CONTENT_LENGTH=1_000_000,TRUSTED_HOSTS=[origin.hostname],PREFERRED_URL_SCHEME='https')
    oauth=OAuth(app)
    oauth.register('identity',client_id=app.config['OIDC_CLIENT_ID'],client_secret=app.config['OIDC_CLIENT_SECRET'],
      server_metadata_url=app.config['OIDC_ISSUER'].rstrip('/')+'/.well-known/openid-configuration',
      client_kwargs={'scope':'openid email','code_challenge_method':'S256','default_timeout':10},
      claims_options={'iss':{'essential':True,'value':app.config['OIDC_ISSUER']}})
    store=Store(app.config['DATABASE_URL']);spec=load_spec()

    @app.before_request
    def protect():
        public=request.endpoint in {'home','login','callback','health','static'}
        if public:return
        identity=session.get('identity')
        if not identity:abort(401)
        if identity.get('iss')!=app.config['OIDC_ISSUER'] or identity.get('email') not in emails(app.config['ALLOWED_EMAILS'])|emails(app.config['OPERATOR_EMAILS']):abort(403)
        g.subject=identity['sub'];g.operator=identity['email'] in emails(app.config['OPERATOR_EMAILS'])
        if request.method not in {'GET','HEAD','OPTIONS'}:
            token=request.headers.get('X-CSRF-Token') or request.form.get('csrf','')
            if (request.headers.get('Origin')!=app.config['APP_ORIGIN'] or not token
                or not hmac.compare_digest(token,session.get('csrf',''))):abort(403)

    @app.after_request
    def secure(response):
        response.headers.update({'Cache-Control':'no-store','X-Content-Type-Options':'nosniff','X-Frame-Options':'DENY',
          'Referrer-Policy':'no-referrer','Strict-Transport-Security':'max-age=31536000',
          'Permissions-Policy':'camera=(), microphone=(), geolocation=()'})
        scripts=[];styles=[]
        if response.mimetype=='text/html':
            html=response.get_data(as_text=True)
            scripts=["'sha256-"+base64.b64encode(hashlib.sha256(x.encode()).digest()).decode()+"'" for x in re.findall(r'<script>(.*?)</script>',html,re.S)]
            styles=["'sha256-"+base64.b64encode(hashlib.sha256(x.encode()).digest()).decode()+"'" for x in re.findall(r'<style>(.*?)</style>',html,re.S)]
        response.headers['Content-Security-Policy']="default-src 'none'; script-src 'self' "+' '.join(scripts)+"; style-src 'self' "+' '.join(styles)+"; connect-src 'self'; img-src 'self' data:; form-action 'self'; frame-ancestors 'none'; base-uri 'none'"
        return response

    @app.errorhandler(Exception)
    def error(exc):
        if isinstance(exc,HTTPException):return jsonify(error=exc.name),exc.code
        if isinstance(exc,RateLimited):return jsonify(error='Submission limit reached. Try again in an hour.'),429,{'Retry-After':'3600'}
        # No exception detail, raw SQL, tokens or response content in logs or errors.
        app.logger.error('Intake request failed (%s)',type(exc).__name__)
        return jsonify(error='Service unavailable. Contact the setup operator.'),503

    @app.get('/healthz')
    def health():return jsonify(status='ok')

    @app.get('/')
    def home():return render_template('home.jinja',signed_in=bool(session.get('identity')))

    @app.get('/login')
    def login():
        session.clear()
        return oauth.identity.authorize_redirect(app.config['APP_ORIGIN']+'/auth/callback',nonce=secrets.token_urlsafe(32))

    @app.get('/auth/callback')
    def callback():
        try:
            token=oauth.identity.authorize_access_token()
            identity=allowed_identity(token.get('userinfo',{}),app.config)
        except Exception:
            session.clear();abort(403)
        session.clear();session['identity']=identity;session['csrf']=secrets.token_urlsafe(32);session.permanent=True
        return redirect('/form')

    @app.post('/logout')
    def logout():session.clear();return redirect('/')

    @app.get('/form')
    def form():
        html=(ROOT/'setup/form.html').read_text()
        return Response(html.replace('</body>','<script src="/assets/online.js"></script></body>'),mimetype='text/html')

    @app.get('/api/session')
    def current_session():return jsonify(csrf=session['csrf'],operator=g.operator,retention_days=days)

    @app.route('/api/submissions',methods=['GET','POST'])
    def submissions():
        if request.method=='GET':return jsonify(submissions=store.list(g.subject,g.operator))
        if request.mimetype!='application/json':abort(415)
        try:data=json.loads(request.get_data(),parse_constant=reject_constant)
        except (ValueError,UnicodeDecodeError):abort(400)
        errors=validate(data,spec)
        if errors:return jsonify(errors=errors),400
        sid,created=store.submit(g.subject,g.operator,data,days)
        return jsonify(id=sid,status='received'),201 if created else 200

    @app.get('/api/submissions/<uuid:sid>/export')
    def export(sid):
        payload=store.export(g.subject,g.operator,sid)
        if payload is None:abort(404)
        return Response(json.dumps(payload,indent=2)+'\n',mimetype='application/json',headers={'Content-Disposition':'attachment; filename="bamboo-setup-submission.json"'})

    @app.post('/api/submissions/<uuid:sid>/delete')
    def delete(sid):
        if not store.change(g.subject,g.operator,sid):abort(404)
        return jsonify(deleted=True)

    @app.post('/api/submissions/<uuid:sid>/status')
    def status(sid):
        if not g.operator:abort(403)
        body=request.get_json(silent=True) if request.is_json else request.form
        if not hasattr(body,'get'):abort(400)
        status=body.get('status')
        if status not in {'received','reviewed','closed'}:abort(400)
        if not store.change(g.subject,g.operator,sid,status):abort(404)
        if not request.is_json:return redirect('/operator')
        return jsonify(status=status)

    @app.get('/operator')
    def operator():
        if not g.operator:abort(403)
        return render_template('operator.jinja',rows=store.list(g.subject,True),csrf=session['csrf'])

    @app.cli.command('purge-expired')
    def purge_expired():
        """Run daily from the scheduler using runtime credentials."""
        print(json.dumps(store.purge()))

    return app
