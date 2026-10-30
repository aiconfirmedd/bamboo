#!/usr/bin/env python3
"""Offline completeness, link, inventory and known-boundary checks; stdlib only."""
import csv, hashlib, json, re
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
ROOT=Path(__file__).resolve().parents[1]
errors=[]
def check(value, message):
    if not value: errors.append(message)
def anchors(path):
    seen={}; result=set()
    for heading in re.findall(r"^#{1,6}\s+(.+)$",path.read_text(),re.M):
        slug=re.sub(r"[^\w\- ]","",heading.lower()).replace(" ","-")
        n=seen.get(slug,0);seen[slug]=n+1;result.add(slug+("-"+str(n) if n else ""))
    return result
def local_link(source, url):
    if not url or url.startswith(("https:","http:","mailto:","tel:","data:")):return
    parsed=urlsplit(url);target=unquote(parsed.path)
    check(not target.startswith(("/Users/","file:")),f"Machine-specific link: {source}: {url}")
    p=(source.parent/target).resolve() if target else source
    check(p.is_relative_to(ROOT),f"Link outside package: {source}: {url}")
    check(p.exists(),f"Missing link: {source.relative_to(ROOT)} -> {url}")
    if parsed.fragment and p.suffix==".md" and p.exists():
        check(unquote(parsed.fragment) in anchors(p),f"Missing anchor: {source.relative_to(ROOT)} -> {url}")
class Links(HTMLParser):
    def __init__(self):super().__init__();self.urls=[]
    def handle_starttag(self,tag,attrs):
        self.urls += [v for k,v in attrs if k in ("href","src") and v]
def main():
    manifest=json.loads((ROOT/"docs/inventory/files.json").read_text())
    listed={x["file"] for x in manifest}
    actual={str(p.relative_to(ROOT)) for p in ROOT.rglob("*") if p.is_file() and not ({".git","node_modules","__pycache__","work"}&set(p.relative_to(ROOT).parts)) and p.name!=".DS_Store" and str(p.relative_to(ROOT))!="docs/inventory/files.json"}
    check(actual==listed,"Inventory file set changed; run python3 scripts/build_catalog.py")
    links=0
    for entry in manifest:
        p=ROOT/entry["file"]
        check(p.exists(),"Missing inventoried file: "+entry["file"])
        if not p.exists():continue
        check(hashlib.sha256(p.read_bytes()).hexdigest()==entry["sha256"],"Hash changed: "+entry["file"])
        if p.suffix.lower() not in {".png",".jpg",".jpeg",".webp"}:
            text=p.read_text(errors="ignore")
            patterns=[r"\bxpl_[A-Za-z0-9]{25,}",r"\bsk-(?:proj-)?[A-Za-z0-9_-]{35,}",r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"]
            check(not any(re.search(pattern,text) for pattern in patterns),"Credential-like material: "+entry["file"])
        if p.suffix==".md":
            text=p.read_text(); text=re.sub(r"(?ms)^(`{3,}|~{3,}).*?^\1\s*$","",text)
            for url in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)",text):
                local_link(p,url.strip("<>"));links+=1
        if p.suffix==".html":
            parser=Links();parser.feed(p.read_text())
            for url in parser.urls:local_link(p,url);links+=1
    features=list(csv.DictReader((ROOT/"replica/features.csv").open()))
    check(len(features)==80,"Expected80 features")
    check(all(x["clone"]=="no" for x in features),"Reference package must not claim implemented features")
    check(all(x["priority"] in {"must","should","could","skip"} for x in features),"Invalid feature priority")
    screens=list(csv.DictReader((ROOT/"docs/inventory/screens.csv").open()))
    check(len(screens)==39 and len({s["id"] for s in screens})==39,"Expected39 unique stable screen IDs")
    metrics=json.loads((ROOT/"replica/evidence/opencode-original/live-metrics.json").read_text())
    check(len(metrics)==16,"Expected16 recovered metric entries")
    tokens=json.loads((ROOT/"replica/design/tokens.json").read_text())
    check(len(tokens["pairs"])==62,"Expected62 contrast pairs")
    measured=tokens["_measurements"]["trial"]["screens"]
    check(all(row["id"] in measured and measured[row["id"]]["url"]==row["url"] and measured[row["id"]]["elements"]==row["metrics"] for row in metrics),"Recovered metrics differ from token provenance")
    sql=(ROOT/"docs/architecture/schema.sql").read_text()
    check(len(re.findall(r"^CREATE TABLE ",sql,re.M))==92,"Expected92 proposed tables")
    api=(ROOT/"docs/architecture/api-plan.md").read_text()
    contracts=re.findall(r"^\| (GET|POST|PUT|PATCH|DELETE) ([^|]+?) \|",api,re.M)
    check(len(contracts)==215 and len(set(contracts))==215,"Expected215 unique authored API contracts")
    coverage=list(csv.DictReader((ROOT/"docs/STATE_COVERAGE.csv").open()))
    check({x["id"] for x in coverage}=={x["id"] for x in screens},"State coverage must include every stable screen")
    image_rows=list(csv.DictReader((ROOT/"docs/inventory/assets.csv").open()))
    check(len({x["sha256"] for x in image_rows})==len(image_rows),"Duplicate image contents remain")
    for alias in csv.DictReader((ROOT/"docs/inventory/deduplication.csv").open()):
        p=ROOT/alias["canonical"]
        check(p.exists() and hashlib.sha256(p.read_bytes()).hexdigest()==alias["sha256"],"Invalid deduplication alias: "+alias["removed"])
    for row in csv.DictReader((ROOT/"docs/inventory/assets.csv").open()):
        p=ROOT/row["file"];check(p.exists(),"Missing image "+row["file"])
    for p in (ROOT/"replica/evidence/browser-recon-7").glob("*.txt"):
        check("TOP 50" not in p.read_text().splitlines()[0],"Unrelated active-tab snapshot included")
    connections=json.loads((ROOT/"config/connections.json").read_text())
    example_names={line.split("=",1)[0] for line in (ROOT/".env.example").read_text().splitlines() if "=" in line and not line.startswith("#")}
    check(all(k in example_names for c in connections["connections"] for k in c["env"]),"Connection variable missing from env example")
    check(all(not c["configured"] and not c["live_verified"] for c in connections["connections"]),"Reference must not claim live integrations")
    report={"ok":not errors,"files":len(manifest),"links_checked":links,"features":len(features),"screens":len(screens),"errors":errors}
    print(json.dumps(report,indent=2));return 1 if errors else 0
if __name__=="__main__":raise SystemExit(main())
