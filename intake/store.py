"""PostgreSQL transaction context; every web query runs as a non-owner RLS role."""
from contextlib import contextmanager
import hashlib
import json
import uuid
import psycopg
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb

class RateLimited(Exception):pass

class Store:
    def __init__(self,url):self.url=url

    @contextmanager
    def transaction(self,subject,operator):
        with psycopg.connect(self.url,row_factory=dict_row,connect_timeout=10) as db:
            role=db.execute("SELECT r.rolname,r.rolsuper,r.rolbypassrls,pg_has_role(current_user,c.relowner,'USAGE') AS owns_table FROM pg_roles r JOIN pg_class c ON c.oid='setup_intake.submissions'::regclass WHERE r.rolname=current_user").fetchone()
            if role['rolname']!='intake_runtime' or role['rolsuper'] or role['rolbypassrls'] or role['owns_table']:
                raise RuntimeError('Runtime database role must not own tables or bypass RLS')
            db.execute("SELECT set_config('app.subject',%s,true),set_config('app.operator',%s,true),set_config('statement_timeout','10000',true)",(subject,'true' if operator else 'false'))
            yield db

    def audit(self,db,subject,sid,action):
        db.execute('INSERT INTO setup_intake.audit(actor,submission_id,action) VALUES (%s,%s,%s)',(subject,sid,action))

    def submit(self,subject,operator,payload,days):
        digest=hashlib.sha256(json.dumps(payload['answers'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
        with self.transaction(subject,operator) as db:
            db.execute('SELECT pg_advisory_xact_lock(hashtextextended(%s,0))',(subject,))
            count=db.execute("SELECT count(*) AS n FROM setup_intake.audit WHERE actor=%s AND action='submit' AND created_at>now()-interval '1 hour'",(subject,)).fetchone()['n']
            if count>=30:raise RateLimited()
            old=db.execute('SELECT id FROM setup_intake.submissions WHERE subject=%s AND input_hash=%s AND expires_at>now()',(subject,digest)).fetchone()
            if old:sid=old['id'];created=False
            else:
                # Remove an expired duplicate before inserting a new receipt.
                db.execute('DELETE FROM setup_intake.submissions WHERE subject=%s AND input_hash=%s',(subject,digest))
                sid=uuid.uuid4();created=True
                db.execute("INSERT INTO setup_intake.submissions(id,subject,input_hash,payload,expires_at) VALUES (%s,%s,%s,%s,now()+(%s * interval '1 day'))",(sid,subject,digest,Jsonb(payload),days))
            self.audit(db,subject,sid,'submit')
            return str(sid),created

    def list(self,subject,operator):
        with self.transaction(subject,operator) as db:
            return db.execute('SELECT id,status,created_at,expires_at FROM setup_intake.submissions WHERE expires_at>now() ORDER BY created_at DESC LIMIT 100').fetchall()

    def export(self,subject,operator,sid):
        with self.transaction(subject,operator) as db:
            row=db.execute('SELECT payload FROM setup_intake.submissions WHERE id=%s AND expires_at>now()',(sid,)).fetchone()
            if not row:return None
            self.audit(db,subject,sid,'export');return row['payload']

    def change(self,subject,operator,sid,status=None):
        with self.transaction(subject,operator) as db:
            # Read visibility excludes expired records and blocks guessed identifiers.
            if not db.execute('SELECT id FROM setup_intake.submissions WHERE id=%s AND expires_at>now()',(sid,)).fetchone():return False
            if status:
                db.execute('UPDATE setup_intake.submissions SET status=%s WHERE id=%s',(status,sid))
            else:db.execute('DELETE FROM setup_intake.submissions WHERE id=%s',(sid,))
            self.audit(db,subject,sid,status or 'delete');return True

    def purge(self):
        with self.transaction('maintenance',True) as db:
            # Operator context permits deletion across owners; time predicates remain explicit.
            expired=db.execute('DELETE FROM setup_intake.submissions WHERE expires_at<=now()').rowcount
            audit=db.execute("DELETE FROM setup_intake.audit WHERE created_at<now()-interval '90 days'").rowcount
            return {'expired_submissions_deleted':expired,'old_audit_events_deleted':audit}
