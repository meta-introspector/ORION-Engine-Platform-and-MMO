"""Independent checks of weaver_consolidated_core_v0_5_rehearsal_evidence.zip (ORION R9 Live).

Usage: python3 weaver_v05_evidence_check.py ZIP SHA256_FILE
Needs the `cryptography` package for the Ed25519 check.
"""
import sys, json, hashlib, base64, zipfile, io
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

zpath, shapath = sys.argv[1], sys.argv[2]
data = open(zpath, 'rb').read()
want = open(shapath).read().split()[0]
print("outer sha256 matches .sha256 file:", hashlib.sha256(data).hexdigest() == want)
z = zipfile.ZipFile(io.BytesIO(data))
rd = lambda n: z.read(n)
J = lambda n: json.loads(rd(n))
canon = lambda o: json.dumps(o, sort_keys=True, separators=(',', ':')).encode()

r = J('reproduction/reproduction_receipt.json')
st = J('REHEARSAL_STATUS.json')
pk = base64.b64decode(r['public_key_b64'])
print("public key hash matches receipt:", hashlib.sha256(pk).hexdigest() == r['public_key_sha256'])
print("public key hash matches witness record:", J('rehearsal-public.json')['public_key_sha256'] == r['public_key_sha256'])
for s in r['steps']:
    for k in ('stdout', 'stderr'):
        ok = hashlib.sha256(rd(f"reproduction/logs/{s['name']}.{k}")).hexdigest() == s[k + '_sha256']
        print(f"log {s['name']}.{k} hash matches receipt:", ok, "| exit", s['exit_code'])
print("environment digest = sha256(canonical environment.json):",
      hashlib.sha256(canon(J('reproduction/environment.json'))).hexdigest() == r['environment_digest'])
body = {k: v for k, v in r.items() if k not in ('signature_b64', 'receipt_digest', 'public_key_b64', 'public_key_sha256')}
print("receipt digest = sha256(canonical receipt body):", hashlib.sha256(canon(body)).hexdigest() == r['receipt_digest'])
key = Ed25519PublicKey.from_public_bytes(pk)
sig = base64.b64decode(r['signature_b64'])
try:
    key.verify(sig, canon(body)); print("Ed25519 signature over receipt body: VALID")
except Exception:
    print("Ed25519 signature over receipt body: INVALID")
def tamper(field, val):
    b = dict(body); b[field] = val
    try: key.verify(sig, canon(b)); return "accepted"
    except Exception: return "rejected"
print("signature with wrong challenge:", tamper('challenge_nonce', 'WRONG'))
print("signature with wrong subject:", tamper('subject_sha256', '0' * 64))
print("rebuilt == subject == frozen v0.4:", r['rebuilt_sha256'] == r['subject_sha256'] == st['frozen_parent_v0_4_sha256']
      == rd('reproduction/rebuilt.sha256').split()[0].decode() == rd('baseline/weaver_consolidated_core_v0_4.zip.sha256').split()[0].decode())
print("v0.5 release hash consistent:", st['release_v0_5_sha256'] == rd('baseline/weaver_consolidated_core_v0_5.zip.sha256').split()[0].decode())
t = rd('reproduction/logs/tests.stdout').decode().strip().splitlines()[-1]
m = json.loads(rd('reproduction/logs/mutations.stdout').decode()[rd('reproduction/logs/mutations.stdout').decode().index('{'):])
b = json.loads(rd('reproduction/logs/bundle_verify.stdout'))
print("reproduction run (v0.4 subject):", t, "| mutations", m['killed'], "/", m['total'], "| bundle entries", b['checked'], "passed", b['passed'])
t5 = rd('baseline/v05_tests.txt').decode().strip().splitlines()[-1]
mt = rd('baseline/v05_mutation_report.json').decode(); m5 = json.loads(mt[mt.index('{'):])
b5 = J('baseline/canonical_v05_verify_bundle.txt')
print("baseline run (v0.5):", t5, "| mutations", m5['killed'], "/", m5['total'], "| bundle entries", b5['checked'], "passed", b5['passed'])
q = J('quorum_single_origin.txt')
print("quorum (min 2) with one origin-controlled receipt: passed =", q['passed'], "| valid non-origin receipts", q['valid_non_origin_receipts'])
print("status claims: independent reproduction", st['independent_reproduction_established'], "| independent quorum",
      st['independent_quorum_established'], "| E4 claimed", st['e4_claimed'], "| authority", st['production_authority'])
