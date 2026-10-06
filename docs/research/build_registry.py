"""Reproducible evidence registry; run with deep-research's isolated Python."""
import hashlib
import json
from pathlib import Path
from datetime import datetime, timezone
from urllib.parse import urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parent
DATE = "2026-10-05"
SOURCES = [
    ("Uber", "How to request a ride", "https://help.uber.com/en/riders/article/how-to-request-a-ride?nodeId=e9862b49-81c6-4c6a-a9d3-3c05bf42e82e", "Your default pickup point is set to your current GPS location.", "Steps 1–7", "Destination first; editable GPS pickup; choose vehicle; request; confirm pickup; driver arrival ETA after acceptance."),
    ("Uber", "Ride Prices and Rates - How It Works", "https://www.uber.com/us/en/ride/how-it-works/upfront-pricing/", "including the estimated trip time and distance from origin to destination", "How are prices determined?", "Upfront price uses estimated time, distance, demand, taxes/tolls/fees; guidance may vary by region."),
    ("MapLibre", "Flutter MapLibre GL", "https://github.com/maplibre/flutter-maplibre-gl", "no account or API key required to get started.", "README Quick start and Feature support", "Vector rendering, styles, camera, gestures and GeoJSON on mobile/web; renderer neutrality does not imply free providers."),
    ("OpenFreeMap", "OpenFreeMap", "https://openfreemap.org/", "There’s no registration, no user database, no API keys, and no cookies.", "Public instance; SLA; Attribution", "Public tiles need no key/registration, no request/view limits declared; no SLA; OpenMapTiles and OSM attribution required."),
    ("OpenFreeMap", "OpenFreeMap Quick Start Guide", "https://openfreemap.org/quick_start/", "For mobile apps, you can use the same styles with MapLibre Native.", "Mobile Apps and Custom styles", "MapLibre Native can use same styles; custom styles may remove labels/POIs or change colours and use hosted JSON."),
    ("komoot", "photon: an open source geocoder for openstreetmap data", "https://github.com/komoot/photon", "We do not give guarantees for availability", "Features and Demo server", "Search-as-you-type, multilingual, location bias and reverse geocode; public demo only reasonable request volume; throttling possible."),
    ("komoot", "photon API", "https://github.com/komoot/photon/blob/master/docs/api-v1.md", "Use the lat and lon parameters to set a focus point", "Search, Location Bias, Reverse", "Forward /api?q=, reverse /reverse?lat=&lon=, location bias, bbox and limit; API GeoJSON place results."),
    ("OSRM", "OSRM API Documentation v5.24.0", "https://project-osrm.org/docs/v5.24.0/api/", "The estimated travel time, in float number of seconds.", "Route service and Route object", "Route distance float metres, duration float seconds and geometry; full GeoJSON overview supported; speed sources configurable."),
    ("FOSSGIS", "About routing.openstreetmap.de", "https://routing.openstreetmap.de/about.html", "One request per second max.", "Usage policy", "OSRM server based on OSM; valid UA/referrer, attribution plus fix-map link; no scraping/heavy use."),
    ("Flutter", "Architecture recommendations and resources", "https://docs.flutter.dev/app-architecture/recommendations", "Use immutable data models.", "Separation of concerns, Handling data, App structure", "UI/data separation, repositories, MVVM, abstract repos, dependency injection and immutable data strongly recommended; ChangeNotifier conditional."),
    ("OSMF", "Nominatim Usage Policy (aka Geocoding Policy)", "https://operations.osmfoundation.org/policies/nominatim/", "you must not implement such a service on the client side using the API.", "Unacceptable Use: Auto-complete search", "Policy applies to nominatim.openstreetmap.org; client autocomplete forbidden; max 1rps and identification/attribution requirements."),
    ("CARTO", "Get your CARTO Basemaps API key", "https://carto.com/basemaps/apikey/", "Add it to your tile URLs and the \"API key required\" watermark goes away.", "Intro and The terms, 29 September 2026", "Current CARTO basemaps require API key in tile URLs and attribution; old keyless assumptions invalid for new setup."),
    ("Google", "Set up a Flutter Project", "https://developers.google.com/maps/flutter-package/config", "This application targets iOS, Android and Web.", "Step 2 and Step 4", "Maps Flutter supports 3 platforms; billing/API key prerequisites; platform-specific credential setup; recommend separate restricted keys."),
    ("Google", "Get a route", "https://developers.google.com/maps/documentation/routes/compute_route_directions", "a traffic-aware driving route", "Example request and Field mask", "Routes DRIVE/TRAFFIC_AWARE returns duration, distanceMeters and encodedPolyline when requested."),
    ("Google", "Places API Usage and Billing", "https://developers.google.com/maps/documentation/places/web-service/usage-and-billing", "include an API key or OAuth token with all API or SDK requests.", "Usage and billing reminder", "Places requires billing and API credential; request fields/SKU and volume determine usage."),
    ("Mapbox", "Get Started | Maps SDK for Flutter", "https://docs.mapbox.com/flutter/maps/guides/install/", "The Mapbox Maps SDK for Flutter brings web support alongside iOS and Android", "Web support and Configure credentials", "v3.0.0 install example supports 3 platforms; public token via dart-define; web core APIs incomplete parity."),
    ("Mapbox", "Directions API", "https://docs.mapbox.com/api/navigation/directions/", "This profile factors in current and historic traffic conditions to avoid slowdowns.", "Routing profiles and Restrictions", "driving-traffic estimates use traffic in supported areas; reverts to driving outside coverage; requests billed; distance metres duration seconds."),
    ("Mapbox", "Set a style", "https://docs.mapbox.com/flutter/maps/guides/styles/set-a-style/", "You can also create your own custom styles using the Mapbox Studio style editor.", "Custom styles", "Custom Style URL/JSON and runtime layers supported; Standard exposes limited configurations."),
    ("Flutter", "disableAnimations property - MediaQueryData", "https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html", "On iOS, reduced motion is exposed separately", "Property description", "disableAnimations corresponds to Android Remove animations; iOS AccessibilityFeatures.reduceMotion separate; custom animation should adapt."),
    ("MapLibre", "maplibre_gl 0.27.1", "https://pub.dev/packages/maplibre_gl/versions/0.27.1", "Interactive, fully styleable vector maps on Android, iOS and Web", "README Quick start and Feature support", "Version 0.27.1 published by maplibre.org; Flutter3.29/Dart3.7/JDK21/Android21/iOS13/WebGL2 minimums stated; no native desktop."),
]

def digest(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()[:16]

def write_jsonl(name, rows):
    path = ROOT / name
    # Evidence and registry remain append-only, with stable IDs preventing duplicates.
    old = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()] if path.exists() else []
    key = "evidence_id" if name == "evidence.jsonl" else "claim_id" if name == "claims.jsonl" else "source_id"
    ids = {row[key] for row in old}
    with path.open("a", encoding="utf-8") as f:
        for row in rows:
            if row[key] not in ids:
                f.write(json.dumps(row, ensure_ascii=False) + "\n")

now = datetime.now(timezone.utc).isoformat()
sources, evidence, claims, display = [], [], [], {}
for n, (org, title, url, quote, locator, fact) in enumerate(SOURCES, 1):
    assert len(quote.split()) <= 20
    parsed = urlsplit(url)
    canonical = urlunsplit((parsed.scheme.lower(), parsed.netloc.lower(), parsed.path.rstrip("/"), parsed.query, ""))
    sid = digest(canonical)
    display[sid] = n
    sources.append({"source_id":sid,"canonical_locator":canonical,"raw_url":url,"url":url,"title":title,"author":org,"source_type":"official_documentation","retrieved_at":now,"retrieved_date":DATE,"year":None,"credibility_score":95,"credibility_note":"Primary maintainer/provider documentation; authoritative for own API/policy, not independent performance comparison."})
    eid = digest(sid + " ".join(quote.strip().lower().split()) + locator)
    pid = digest(sid + fact + locator)
    evidence.extend([
        {"evidence_id":eid,"source_id":sid,"retrieval_query":url,"locator":locator,"quote":quote,"evidence_type":"direct_quote","captured_at":now},
        {"evidence_id":pid,"source_id":sid,"retrieval_query":url,"locator":locator,"quote":fact,"evidence_type":"paraphrase","captured_at":now},
    ])
    claims.append({"claim_id":digest(sid+fact),"claim":fact,"source_ids":[sid],"evidence_ids":[eid,pid],"support_status":"supported","verification":"manual_meaning_check","triangulation":"single_source_feature_or_policy_fact","confidence":0.95,"limitations":"Describes maintainer documentation at retrieval, not measured app behaviour."})
for claim, refs in [
    ("Choose MapLibre plus OpenFreeMap for a credential-free educational vector-map demo; keep replaceable search/routing repositories.",[3,4,5,6,8,10]),
    ("Google Maps plus Places plus Routes is an alternative for Places and traffic-aware routing after credentials and billing configuration.",[13,14,15]),
    ("Uber-inspired flow should expose destination, editable pickup, route overview, upfront demo fare and confirmation before simulation.",[1,2,8]),
    ("Demo fare must be labelled simulated and route duration must not be sold as real-time traffic ETA.",[2,8,9,14,17]),
    ("Do not use public Nominatim for autocomplete or assume CARTO tiles remain keyless.",[6,11,12]),
]:
    ids=[sources[n-1]["source_id"] for n in refs]
    claims.append({"claim_id":digest(claim),"claim":claim,"source_ids":ids,"evidence_ids":[e["evidence_id"] for e in evidence if e["source_id"] in ids],"support_status":"supported_inference","verification":"manual_cross_source_synthesis","triangulation":"cross_source_recommendation","confidence":0.9,"limitations":"Engineering judgement, not a vendor benchmark or guarantee."})
write_jsonl("sources.jsonl",sources)
write_jsonl("evidence.jsonl",evidence)
write_jsonl("claims.jsonl",claims)
(ROOT/"display_numbers.json").write_text(json.dumps(display,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
manifest={"version":"3.0.0","query":"Rebuild Flutter mobile map demo with Uber-inspired booking flow, no auth; maps, places, route, distance, time and transparent demo fare.","mode":"standard","started_at":now,"finished_at":None,"client_date":DATE,"client_timezone":"Asia/Saigon","assumptions":["User wants code and a reviewable local web preview, with mobile source; educational HCMC scope.","No provider keys available for core demo; public endpoint usage stays small.","Official source facts may have one authoritative source; architectural recommendation triangulated across maintainers.","No mobile build/benchmark assertions in research; runtime test outcomes belong to implementation report."],"provider_config":{"primary":"Codex native web search/open","scholarly":None},"report_dir":str(ROOT),"artifact_paths":{"report":"report.md","sources":"sources.jsonl","evidence":"evidence.jsonl","claims":"claims.jsonl","display_numbers":"display_numbers.json","html":"report.html"},"scope_adaptations":["Current Mapbox Flutter v3 has web support; removed older mobile-only premise.","Current CARTO keys required; selected OpenFreeMap.","Nominatim public autocomplete forbidden; selected Photon.","OSRM speed sources can be configured, but this public-demo integration lacks live traffic evidence; label duration accordingly."],"quality":{"source_count":len(sources),"quoted_words_max_per_source":20,"claim_support":"manual inspected, flags in claims.jsonl","source_diversity_note":"Primary technical docs, provider policies, and official Uber product guidance. No third-party marketing or academic benchmarks needed for this API choice."}}
(ROOT/"run_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(f"Persisted {len(sources)} sources, {len(evidence)} evidence rows, {len(claims)} claims")
