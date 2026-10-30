#!/usr/bin/env python3
"""Regenerate portable reference catalogs/gallery/upload packet and file hashes."""
import csv, hashlib, html, json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
INV = ROOT / "docs/inventory"
EXCLUDED = {".git", "node_modules", "__pycache__", "work"}
IMAGE_EXT = {".png", ".jpg", ".jpeg", ".webp"}
def files():
    return sorted(p for p in ROOT.rglob("*") if p.is_file() and not (set(p.relative_to(ROOT).parts) & EXCLUDED) and p.name != ".DS_Store")
def csvwrite(path, fields, rows):
    with path.open("w", newline="") as f:
        w=csv.DictWriter(f, fieldnames=fields); w.writeheader(); w.writerows(rows)
def category(path):
    name = path.name
    if name.endswith("-blank.png"): return "transient blank attempt; NOT loaded screen proof"
    if name == "performance.png" and "browser-recon-7" in path.parts: return "loading attempt; use review-cycles for loaded list"
    if name in {"live-orgchart.png","live-performance.png","live-onboarding.png","live-satisfaction.png"}: return "404 attempt; NOT intended feature UI (audit6)"
    if name == "live-people-empty.png": return "FILLED employee list; filename does not prove empty (audit6)"
    if name.startswith("packet-preview-info"): return "template placeholder; actual employee fields withheld"
    if name.startswith("packet-preview-tasks"): return "template placeholder; actual tasks withheld"
    if name.startswith("live-demo-request"): return "public prospect form; audit5 required"
    if "browser-recon-8" in path.parts: return "browser8 comparison; read audit8"
    if "browser-recon-7" in path.parts: return "owner trial/sample evidence; read audit7"
    if name.startswith("hc-"): return "help artifact/icon; NOT screen proof"
    if name.startswith("mkt-"): return "public marketing"
    if name.startswith(("ios-", "play-")): return "public app store/mobile"
    if name.startswith("live-tour-"): return "public interactive tour; historical shell"
    if name.startswith("live-demo-"): return "demo attempt/gate; audit2-4 required"
    if name.startswith("live-careers-"): return "public careers; audit3-5"
    if name.startswith(("live-demo", "live-signup", "live-prepare")): return "prospect funnel; audit5 required"
    return "owner trial/sample or mixed source; audit6 required"
def main():
    INV.mkdir(parents=True, exist_ok=True)
    images = [p for p in files() if p.suffix.lower() in IMAGE_EXT]
    assets=[{"file":str(p.relative_to(ROOT)), "category":category(p), "bytes":p.stat().st_size, "sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in images]
    csvwrite(INV/"assets.csv", ["file","category","bytes","sha256"], assets)
    screens=[]
    for line in (ROOT/"replica/recon.md").read_text().splitlines():
        if re.match(r"^\| S\d+ \|",line):
            cols=[x.strip() for x in line.strip().strip("|").split("|")]
            screens.append(dict(zip(["id","screen","navigation","purpose","components","evidence"],cols[:6])))
    csvwrite(INV/"screens.csv",["id","screen","navigation","purpose","components","evidence"],screens)
    routes={}
    metrics=ROOT/"replica/evidence/opencode-original/live-metrics.json"
    for row in json.loads(metrics.read_text()):
        routes[(row["url"],str(metrics.relative_to(ROOT)))]={"url":row["url"],"source":str(metrics.relative_to(ROOT)),"kind":"original capture route; audit6 may show404", "auth":"owner trial"}
    for p in (ROOT/"replica/evidence").rglob("*.txt"):
        for u in re.findall(r"https?://[^\s<>]+|(?:aiconfirmed|advantagedemo|oicr)\.bamboohr\.com/[^\s<>]*",p.read_text()):
            if "bamboohr.com" not in u: continue
            u=u.rstrip(",;.)");u=u if u.startswith("http") else "https://"+u
            if any(x in u for x in ("token=","password=","session=")):continue
            rel=str(p.relative_to(ROOT));routes[(u,rel)]={"url":u,"source":rel,"kind":"navigation reference; not necessarily successful result", "auth":"public" if any(x in u for x in ("advantagedemo.","oicr.")) else "owner trial"}
    unique={}
    for row in routes.values():
        if row["url"] not in unique: unique[row["url"]]={**row,"source":set()}
        unique[row["url"]]["source"].add(row["source"])
    for row in unique.values(): row["source"]="; ".join(sorted(row["source"]))
    csvwrite(INV/"routes.csv",["url","source","kind","auth"],sorted(unique.values(),key=lambda x:x["url"]))
    # Self-contained gallery: no CDN, analytics, framework or network fetch required.
    cards="".join('<figure><a href="'+html.escape(a["file"],quote=True)+'"><img loading="lazy" src="'+html.escape(a["file"],quote=True)+'" alt="'+html.escape(Path(a["file"]).name,quote=True)+'"></a><figcaption><code>'+html.escape(Path(a["file"]).name)+'</code><br>'+html.escape(a["category"])+'</figcaption></figure>' for a in assets)
    page='<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Bamboo reference archive</title><style>body{font:16px/1.5 system-ui;margin:0;color:#24313d;background:#f5f5f2}header,main{max-width:1200px;margin:auto;padding:28px}a{color:#174c82}h1{font-size:36px;margin:0}nav{display:flex;gap:20px;flex-wrap:wrap;margin:16px 0}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px}figure{margin:0;background:white;border:1px solid #ccd2d6;border-radius:10px;overflow:hidden}img{width:100%;height:240px;object-fit:contain;background:#eee}figcaption{padding:12px;font-size:13px;overflow-wrap:anywhere}.notice{padding:16px;background:#fff;border-left:4px solid #475569}</style><header><h1>Bamboo reference archive</h1><p>39 screens · 12 flows · 80 features · design and architecture contracts</p><nav><a href="START_HERE.md">Start here</a><a href="docs/CAPTURE-COMPARISON.md">Comparison</a><a href="docs/GAPS.csv">Gaps</a><a href="docs/inventory/screens.csv">Screens</a><a href="UPLOAD.md">Upload</a><a href="setup/form.html">Setup form</a></nav><p class="notice">Reference evidence only. No HR application is implemented. Read audit provenance before using a capture: gates, icons,404 attempts, historical tours, mobile and current trial are distinct evidence. Never ship these images in your app.</p><p>'+str(len(assets))+' image assets. Open a thumbnail for its original file.</p></header><main><div class="grid">'+cards+'</div></main></html>'
    (ROOT/"index.html").write_text(page)
    entries=[]
    for p in files():
        rel=str(p.relative_to(ROOT))
        if rel=="docs/inventory/files.json":continue
        entries.append({"file":rel,"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()})
    (INV/"files.json").write_text(json.dumps(entries,indent=2)+"\n")
    print(json.dumps({"files":len(entries)+1,"images":len(assets),"screens":len(screens),"route_references":len(unique)}))
if __name__=="__main__": main()
