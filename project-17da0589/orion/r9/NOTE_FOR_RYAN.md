# Note for Ryan (approved 👍 on ORION R9 Live)

Short, ready to paste. Written 2026-10-04.

---

Hi Ryan, three things from the checks on your packages.

**1. POSM v0.4 doesn't build as shipped.**
The Python tests and `SHA256SUMS.txt` pass, but the Lean code fails to compile, including on the Lean version the
package names. There are three errors:
- a line that fails with "no goals";
- one case left unproved;
- no `main` function, which the package's build target needs.

The package's own build-status file says Lean was never run. With three small fixes every theorem is proved, and no
statement changes. The patch is `orion/r8b/posm-v0.4-fixes.patch`. After applying it, `SHA256SUMS.txt` needs
regenerating.

**2. Artemis/VPH v0.1 README wording.**
The README says a mesh resting point "need not be consensus". For the mesh game in `kernel.mesh`, every resting point
*is* a consensus. This is proved in Lean (`fixed_point_consensus`, `RequestProject/RoundEight/SecondPassEight.lean`),
and 3,000 random runs agree. Suggested wording: "In this mesh game every fixed point is a consensus; which consensuses
are fixed points is characterised in the proof notes."

**3. Weaver Consolidated Core v0.5 rehearsal evidence: checks out.**
Checked independently (`orion/r9/weaver-v0.5-rehearsal-checks.log`, script `orion/r9/weaver_v05_evidence_check.py`):
- outer SHA-256 matches;
- all ten step logs match their hashes in the receipt;
- the environment digest and receipt digest recompute exactly;
- the Ed25519 signature verifies, and it fails if the challenge or the subject is changed;
- rebuilt = subject = frozen v0.4 hash.

The headline numbers are 125 tests, 83 bundle entries and 26/26 mutations, which come from the v0.5 baseline run. The
reproduction run itself was against the v0.4 subject: 108 tests, 67 entries and 22/22 mutations. The report doesn't
claim otherwise, but a sentence making the split explicit would help readers.

The v0.4 and v0.5 ZIPs themselves aren't on the page, so the code wasn't re-run here, only the evidence packet. The
claim boundary (origin-controlled, no independent quorum, E4 not claimed) matches the files.
