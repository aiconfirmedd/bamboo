#!/usr/bin/env python3
"""Offline connection-contract validation. Never connects or prints secret values."""
import argparse, json, re
from pathlib import Path
from urllib.parse import urlsplit
ROOT=Path(__file__).resolve().parents[1]
def parse_env(path):
    values={}
    for line in path.read_text().splitlines():
        line=line.strip()
        if not line or line.startswith("#"): continue
        if line.startswith("export "): line=line[7:]
        key,sep,value=line.partition("=")
        if not sep or not re.fullmatch(r"[A-Z][A-Z0-9_]*",key.strip()):raise ValueError("Invalid environment-file syntax")
        value=value.strip()
        if len(value)>1 and value[0]==value[-1] and value[0] in (chr(34),chr(39)):value=value[1:-1]
        if key.strip() in values:raise ValueError("Duplicate environment variable: "+key.strip())
        values[key.strip()]=value
    return values
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument("--env-file",type=Path);args=ap.parse_args()
    manifest=json.loads((ROOT/"config/connections.json").read_text())
    example=parse_env(ROOT/".env.example")
    ids=[x["id"] for x in manifest["connections"]];errors=[]
    for c in manifest["connections"]:
        if any(d not in ids for d in c["depends_on"]):errors.append("Unknown dependency: "+c["id"])
        if any(k not in example for k in c["env"]):errors.append("Example missing declared variable: "+c["id"])
        if c["status"]!="planned" or c["configured"] or c["live_verified"]:errors.append("Reference manifest must not claim live connectivity: "+c["id"])
    if len(ids)!=len(set(ids)):errors.append("Duplicate connection ID")
    graph={c["id"]:c["depends_on"] for c in manifest["connections"]}
    visited=set();active=set()
    def visit(node):
        if node in active:raise ValueError("Dependency cycle")
        if node in visited:return
        active.add(node)
        for dep in graph.get(node,[]):visit(dep)
        active.remove(node);visited.add(node)
    try:
        for node in ids:visit(node)
    except ValueError:errors.append("Connection dependency cycle")
    for flag,value in manifest["feature_flags"].items():
        if value is not False or example.get(flag)!="false":errors.append("Deferred feature must default off: "+flag)
    if errors:print(json.dumps({"contract_valid":False,"errors":errors}));return 1
    if args.env_file is None:
        print(json.dumps({"contract_valid":True,"connections":len(ids),"stage":"reference-only","live_verified":False,"network_calls":0}));return 0
    try:values=parse_env(args.env_file)
    except (OSError,ValueError):print(json.dumps({"configuration_present":False,"error":"Cannot read valid environment file"}));return 2
    required={k for c in manifest["connections"] for k in c["env"]}
    absent=sorted(k for k in required if not values.get(k) or re.search(r"REPLACE_|example\.invalid|YOUR_|DB_HOST",values[k],re.I))
    invalid=[]
    for k in ("APP_URL","AUTH_URL","OIDC_ISSUER","R2_ENDPOINT"):
        value=values.get(k,"")
        if value and k not in absent:
            try:
                u=urlsplit(value)
                if not u.hostname or (u.scheme!="https" and not (u.scheme=="http" and u.hostname in ("localhost","127.0.0.1"))):invalid.append(k)
            except ValueError:invalid.append(k)
    for k in ("DATABASE_URL","DATABASE_MIGRATION_URL"):
        if values.get(k) and k not in absent:
            try:
                if urlsplit(values[k]).scheme not in ("postgres","postgresql"):invalid.append(k)
            except ValueError:invalid.append(k)
    flags={k:values.get(k,"false") for k in manifest["feature_flags"]}
    invalid += [k for k,v in flags.items() if v not in ("true","false")]
    print(json.dumps({"configuration_present":not absent and not invalid,"missing_or_placeholder_names":absent,"invalid_format_names":sorted(invalid),"enabled_deferred_features":[k for k,v in flags.items() if v=="true"],"live_verified":False,"network_calls":0,"note":"Presence/shape only. Implement and execute staging integration tests before claiming readiness."},indent=2))
    return 1 if absent or invalid else 0
if __name__=="__main__":raise SystemExit(main())
