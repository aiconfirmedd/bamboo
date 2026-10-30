#!/usr/bin/env python3
"""Validate a submitted setup form and generate a local configuration/next-step pack.
No network calls, credential storage, service provisioning or app implementation.
"""
import argparse
import hashlib
from html.parser import HTMLParser
import json
import math
from pathlib import Path
import re
from urllib.parse import urlsplit
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError
ROOT=Path(__file__).resolve().parents[1]
class Spec(HTMLParser):
    def __init__(self):super().__init__();self.active=False;self.parts=[]
    def handle_starttag(self,tag,attrs):
        if tag=='script' and dict(attrs).get('id')=='setup-spec':self.active=True
    def handle_endtag(self,tag):
        if tag=='script':self.active=False
    def handle_data(self,data):
        if self.active:self.parts.append(data)
def load_spec():
    parser=Spec();parser.feed((ROOT/'setup/form.html').read_text());spec=json.loads(''.join(parser.parts))
    keys=[f['key'] for f in spec['fields']]
    if len(keys)!=len(set(keys)):raise ValueError('Duplicate form field definition')
    return spec
def reject_constant(value):raise ValueError('Non-finite JSON number')
def validate(data,spec):
    errors=[]
    if not isinstance(data,dict) or set(data)-{'schema_version','submitted_at','answers'}:return ['Invalid submission structure']
    if type(data.get('schema_version')) is not int or data.get('schema_version')!=1 or not isinstance(data.get('answers'),dict):return ['Unsupported form version or missing answers']
    a=data['answers'];allowed={f['key'] for f in spec['fields']}
    if set(a)-allowed:errors.append('Unknown answer keys; use the supplied form')
    if not isinstance(data.get('submitted_at'),str) or len(data['submitted_at'])>60:errors.append('Missing or invalid submission timestamp')
    raw=json.dumps(a)
    if any(re.search(pattern,raw) for pattern in spec['credential_patterns']):errors.append('Credential-like content detected; supply references only')
    for f in spec['fields']:
        k=f['key'];v=a.get(k)
        if f['required'] and (v is None or v=='' or f['type']=='checkbox' and v is not True):errors.append('Required: '+k);continue
        if v is None or v=='':continue
        if f['type']=='checkbox':
            if not isinstance(v,bool):errors.append('Expected boolean: '+k)
            continue
        if f['type']=='number':
            if isinstance(v,bool) or not isinstance(v,(int,float)) or not math.isfinite(v) or v<f.get('min',0) or k=='retention_days' and isinstance(v,float) and not v.is_integer():errors.append('Invalid numeric value: '+k)
            continue
        if not isinstance(v,str):errors.append('Expected text: '+k);continue
        if '\x00' in v or len(v)>f.get('maxlength',500) or f['type']!='textarea' and any(c in v for c in '\r\n\x00'):errors.append('Invalid text length/characters: '+k)
        if f['type']=='select' and v not in f['options']:errors.append('Invalid choice: '+k)
        if f.get('pattern') and not re.fullmatch(f['pattern'],v):errors.append('Invalid format: '+k)
        if f['type']=='email' and not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+',v):errors.append('Invalid email: '+k)
        if f['type']=='url':
            try:
                u=urlsplit(v)
                if not u.hostname or u.username or u.password or u.scheme!='https' and not(u.scheme=='http' and u.hostname in ('localhost','127.0.0.1')):errors.append('Invalid URL or embedded credentials: '+k)
                if k=='repository_url' and (u.hostname!='github.com' or len(u.path.strip('/').split('/'))!=2):errors.append('Expected GitHub owner/repository HTTPS URL')
            except ValueError:errors.append('Invalid URL: '+k)
    try:ZoneInfo(a.get('time_zone',''))
    except (ZoneInfoNotFoundError,ValueError,TypeError):errors.append('Invalid or unavailable IANA time zone')
    return errors
def unresolved(a):
    issues=[]
    needed={'repository_url':'Select/create target GitHub repo','app_url':'Choose canonical staging URL','secret_manager_reference':'Arrange secure credential handover','oidc_issuer':'Resolve IdP issuer','oidc_provider_id':'Resolve Auth.js provider ID','scanner_plan':'Select file scanning/quarantine approach','sender_address':'Choose/verify sending domain/address','test_recipient':'Name approved staging mail recipient','dns_owner':'Assign DNS/domain owner','content_owner':'Assign original-content owner','retention_days':'Review retention policy','backup_rpo_hours':'Set backup recovery-point target','restore_rto_hours':'Set restore-time target'}
    for key,text in needed.items():
        if a.get(key) is None or a.get(key)=='':issues.append({'field':key,'action':text})
    if a.get('identity_provider')=='to_be_decided':issues.append({'field':'identity_provider','action':'Select OIDC provider'})
    if a.get('auth_adapter')!='custom_mapping_reviewed':issues.append({'field':'auth_adapter','action':'Implement/review compatibility with proposed auth tables'})
    return issues
def prepare(data,spec,output):
    a=data['answers'];output=output.resolve()
    if output.exists():raise ValueError('Output directory already exists; use a new path')
    if output.is_relative_to(ROOT) and output.relative_to(ROOT).parts[0]!='work':raise ValueError('Keep generated responses/configuration outside versioned source or under ignored work/')
    env={}
    for line in (ROOT/'.env.example').read_text().splitlines():
        if line and not line.startswith('#') and '=' in line:k,v=line.split('=',1);env[k]=v
    mapping={'APP_URL':'app_url','AUTH_URL':'app_url','OIDC_PROVIDER_ID':'oidc_provider_id','OIDC_ISSUER':'oidc_issuer','OIDC_CLIENT_ID':'oidc_client_id','R2_ACCOUNT_ID':'r2_account_id','R2_BUCKET':'r2_bucket','RESEND_FROM':'sender_address'}
    for name,key in mapping.items():
        if a.get(key):env[name]=a[key]
    if a.get('r2_account_id') and re.fullmatch('[A-Za-z0-9]+',a['r2_account_id']):env['R2_ENDPOINT']='https://'+a['r2_account_id']+'.r2.cloudflarestorage.com'
    flags=json.loads((ROOT/'config/connections.json').read_text())['feature_flags']
    for flag in flags:env[flag]='false'
    plan={'schema_version':1,'stage':'inputs-validated','live_verified':False,'network_calls':0,'reference_ref':a.get('reference_ref'),'submitted_at':data['submitted_at'],'input_sha256':hashlib.sha256(json.dumps(data,sort_keys=True).encode()).hexdigest(),'choices':a,'brand':{'appName':a['project_name'],'companyName':a['company_name'],'timeZone':a['time_zone'],'accent':a.get('brand_accent') or '#475569'},'unresolved_actions':unresolved(a),'service_status':'All connections remain planned until operator provisions resources and app integration tests pass.','feature_flags':flags}
    output.mkdir(parents=True)
    (output/'setup-plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    (output/'.env.setup.example').write_text('# Prepared nonsecret inputs; replace secret placeholders via secret manager.\n# No app currently loads this file; do not source it as a shell script.\n'+'\n'.join(k+'='+json.dumps(v) for k,v in env.items())+'\n')
    text='# Setup next steps\n\nInputs validated. No services have been activated.\n\n1. Review setup-plan.json and confirm the actual reference commit/repository.\n2. Resolve the actions below with the named setup contact.\n3. Follow docs/CONNECTIONS.md in the reference repo; use recipient-owned staging accounts.\n4. Supply credentials through the named secret manager; keep them out of the uploaded response and Git.\n5. Implement the app callbacks/adapters before registering or testing live integrations.\n6. Run staging acceptance gates from docs/REBUILD_RUNBOOK.md before enabling deferred features.\n\n## Unresolved inputs\n\n'
    text+='\n'.join('- '+i['action'] for i in plan['unresolved_actions']) or '- None at intake level; live verification and implementation are still required.'
    (output/'SETUP_NEXT_STEPS.md').write_text(text+'\n')
    return plan
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('submission',nargs='?',type=Path);ap.add_argument('--output',type=Path);ap.add_argument('--check-only',action='store_true');ap.add_argument('--check-template',action='store_true');args=ap.parse_args()
    spec=load_spec()
    if args.check_template:print(json.dumps({'template_valid':True,'fields':len(spec['fields']),'schema_version':1}));return 0
    if not args.submission:ap.error('Supply exported submission JSON or --check-template')
    try:
        if args.submission.stat().st_size>1000000:raise ValueError('Submission exceeds size limit')
        data=json.loads(args.submission.read_text(),parse_constant=reject_constant)
    except (OSError,ValueError):print(json.dumps({'valid':False,'errors':['Cannot read valid submission JSON']}));return 1
    errors=validate(data,spec)
    if errors:print(json.dumps({'valid':False,'errors':errors},indent=2));return 1
    if args.check_only:print(json.dumps({'valid':True,'unresolved_actions':len(unresolved(data['answers'])),'live_verified':False,'network_calls':0}));return 0
    if not args.output:ap.error('--output is required to generate configuration')
    try:plan=prepare(data,spec,args.output)
    except (OSError,ValueError):print(json.dumps({'valid':True,'generated':False,'error':'Use a new output directory outside versioned files (ignored work/ is allowed)'}));return 1
    print(json.dumps({'valid':True,'generated':True,'files':3,'unresolved_actions':len(plan['unresolved_actions']),'live_verified':False,'network_calls':0}));return 0
if __name__=='__main__':raise SystemExit(main())
