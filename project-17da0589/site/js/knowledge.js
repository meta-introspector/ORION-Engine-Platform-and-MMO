/*
 * friction atlas — knowledge.js
 *
 * The knowledge elements of the friction examination (FRICTION_EXAMINATION.md).
 * Each element carries
 *   · five depths of explanation — everyday, image, mechanism, formal, limits —
 *     each with a sentence (`text`), a formula (`formula`) and a scenario (`p`);
 *   · a model `frame(p, u, d)` that turns a scenario, a loop phase u ∈ [0,1]
 *     and the depth d into a picture frame for svgkit;
 *   · one slider parameter for the interactive form;
 *   · a narration line for the spoken tour;
 *   · the Lean theorem it rests on, if any, and the elements it builds on.
 *
 * `status` is honest about evidence: 'proved' means a Lean theorem in this
 * project, 'interpretive' means an illustrative model with no measurement behind it.
 */
(function (root, factory) {
  const mod = factory();
  root.FrictionKnowledge = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function () {
  'use strict';

  const DEPTHS = [
    { id: 'everyday', name: 'Everyday', blurb: 'a body, a floor, a conversation' },
    { id: 'image', name: 'Image', blurb: 'the picture the source texts use' },
    { id: 'mechanism', name: 'Mechanism', blurb: 'the physics or mathematics' },
    { id: 'formal', name: 'Formal', blurb: 'the Lean theorem' },
    { id: 'limits', name: 'Limits', blurb: 'what it does not show' },
  ];

  /** Loop phase u → a value swinging around the scenario value p (u == null: p itself). */
  const sweep = (p, lo, hi, u) => (u == null ? p : Math.min(hi, Math.max(lo, p + (hi - lo) * 0.3 * Math.sin(2 * Math.PI * u))));
  const wave = (u) => 0.5 - 0.5 * Math.cos(2 * Math.PI * u);
  const range = (a, b, n) => Array.from({ length: n + 1 }, (_, i) => a + (b - a) * i / n);
  const G = 9.8;

  /** RK4 for x'' + c x' + x = F cos(w t), from (x0, v0). Returns [[t, x, v]…]. */
  function oscillate(c, F, w, x0, v0, T, n) {
    const out = [[0, x0, v0]];
    let x = x0, v = v0, t = 0;
    const h = T / n;
    const acc = (t, x, v) => F * Math.cos(w * t) - c * v - x;
    for (let i = 0; i < n; i++) {
      const k1x = v, k1v = acc(t, x, v);
      const k2x = v + h / 2 * k1v, k2v = acc(t + h / 2, x + h / 2 * k1x, v + h / 2 * k1v);
      const k3x = v + h / 2 * k2v, k3v = acc(t + h / 2, x + h / 2 * k2x, v + h / 2 * k2v);
      const k4x = v + h * k3v, k4v = acc(t + h, x + h * k3x, v + h * k3v);
      x += h / 6 * (k1x + 2 * k2x + 2 * k3x + k4x);
      v += h / 6 * (k1v + 2 * k2v + 2 * k3v + k4v);
      t += h;
      out.push([t, x, v]);
    }
    return out;
  }

  function digitalRoot(n) { return n === 0 ? 0 : 1 + (n - 1) % 9; }
  function isPrime(n) { if (n < 2) return false; for (let d = 2; d * d <= n; d++) if (n % d === 0) return false; return true; }
  const CONSTANTS = [1, 2, 3, 4, 5, 6, 8, 12, 20, 24, 30, 60, 144];
  function covered(n, consts, k) {
    // n is a sum of at most k (≥1) members of consts (with repetition)
    let reach = new Set([0]);
    const all = new Set();
    for (let i = 0; i < k; i++) {
      const next = new Set();
      for (const r of reach) for (const c of consts) if (r + c <= 400) { next.add(r + c); all.add(r + c); }
      reach = next;
    }
    return all.has(n);
  }
  const ALPHABETS = [[22, 'Hebrew'], [24, 'Greek'], [26, 'Latin'], [28, 'Arabic'], [33, 'Russian'], [38, 'Armenian']];

  const ELEMENTS = [
    // ------------------------------------------------------------------ 1
    {
      id: 'kinetic-friction', pos: [0.04, 0.08], title: 'Kinetic friction stops a slide', short: 'kinetic stop',
      status: 'proved', theorem: 'Friction.kinetic_friction_stops', file: 'RequestProject/Friction/Mechanics.lean',
      builds: [],
      narration: 'Kinetic friction is what lets a moving body stop. With a friction coefficient mu above zero, a slide ends after a finite distance, v zero squared over two mu g. With mu equal to zero, it never ends.',
      param: { key: 'mu', label: 'friction coefficient μ', min: 0, max: 1, step: 0.01 },
      depths: [
        { text: 'A shoe skidding on a wooden floor stops within a few metres; a skate on ice keeps going much further.', formula: 'v(t) = v₀ − μ g t   until v = 0', p: { mu: 0.3 } },
        { text: 'The Fae without an iron anchor: a body with no grip glides forever and cannot come to rest where it chooses.', formula: 'μ = 0  ⇒  v(t) = v₀ for all t', p: { mu: 0 } },
        { text: 'Coulomb kinetic friction removes speed at the constant rate μg, so speed falls linearly and distance grows as a parabola until the stop.', formula: 'x(t) = v₀ t − μ g t²/2,   T = v₀/(μ g)', p: { mu: 0.5 } },
        { text: 'Lean: with μ > 0 and g > 0, speed is 0 at time v₀/(μg) and the distance travelled is v₀²/(2μg).', formula: 'kinetic_friction_stops : slideSpeed v₀ μ g (v₀/(μ g)) = 0 ∧ slideDist … = v₀²/(2 μ g)', p: { mu: 0.2 } },
        { text: 'Real friction is not exactly constant and depends on speed and surface state; the linear model is a first approximation, and it says nothing by itself about minds or language.', formula: 'μ = μ(v, surface, temperature) in practice', p: { mu: 0.05 } },
      ],
      frame(p, u, d) {
        const v0 = 4, T = 3, mu = p.mu;
        const v = (t) => Math.max(v0 - mu * G * t, 0);
        const stop = mu > 0 ? v0 / (mu * G) : Infinity;
        const tt = u == null ? Math.min(stop, T) : T * u;
        const f = {
          title: `slide at v₀ = 4 m/s, μ = ${mu.toFixed(2)}`, xr: [0, T], yr: [0, 4.4], xlabel: 'time t (s)', ylabel: 'speed v (m/s)',
          layers: [
            { kind: 'line', pts: range(0, T, 90).map((t) => [t, v(t)]), label: 'speed' },
            { kind: 'dots', pts: [[tt, v(tt)]], color: '#ffd479', r: 6 },
          ],
          notes: [{ text: stop < Infinity ? `stops at t = ${stop.toFixed(2)} s after ${(v0 * v0 / (2 * mu * G)).toFixed(2)} m` : 'never stops' }],
        };
        if (d >= 2 && stop < Infinity && stop <= T) f.vlines = [{ x: stop, label: 'T = v₀/(μg)' }];
        return f;
      },
    },
    // ------------------------------------------------------------------ 2
    {
      id: 'traction', pos: [0.24, 0.08], title: 'Traction bounds control', short: 'traction',
      status: 'proved', theorem: 'Friction.traction_bound', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['kinetic-friction'],
      narration: 'The ground can push you sideways only as hard as friction allows. Your acceleration is capped at mu times g, so with mu zero you cannot start, stop or turn. A frictionless avatar is not free; it cannot steer.',
      param: { key: 'mu', label: 'friction coefficient μ', min: 0, max: 1, step: 0.01 },
      depths: [
        { text: 'Walking on ice: you ask your legs for a quick turn and your feet slip. The turn you wanted is clipped to what the ground will give.', formula: 'achieved = clip(requested, −μg, μg)', p: { mu: 0.1 } },
        { text: 'The Tri-Sphere\'s Driver needs a road to grip; without grip the wheel turns and the vehicle does not.', formula: 'μ = 0  ⇒  a = 0', p: { mu: 0 } },
        { text: 'Static friction supplies at most μ m g of horizontal force, and Newton\'s law turns that into an acceleration bound independent of mass.', formula: '|F| ≤ μ m g,  F = m a  ⇒  |a| ≤ μ g', p: { mu: 0.4 } },
        { text: 'Lean: if m > 0 and |m a| ≤ μ m g then |a| ≤ μ g, and μ = 0 forces a = 0.', formula: 'traction_bound : |a| ≤ μ * g ∧ (μ = 0 → a = 0)', p: { mu: 0.6 } },
        { text: 'Grip is necessary, not sufficient: high friction also costs energy and wear. The bound says nothing about how much friction is best, only that zero is too little.', formula: 'bound only: no optimum is claimed', p: { mu: 0.9 } },
      ],
      frame(p, u, d) {
        const cap = p.mu * G;
        const req = (t) => 6 * Math.sin(t + 2 * Math.PI * (u || 0)) + 2 * Math.sin(2.3 * t);
        const ts = range(0, 10, 100);
        const f = {
          title: `requested vs achieved acceleration, μ = ${p.mu.toFixed(2)}`, xr: [0, 10], yr: [-9, 9], xlabel: 'time', ylabel: 'acceleration (m/s²)',
          layers: [
            { kind: 'line', pts: ts.map((t) => [t, req(t)]), color: '#6b7aa6', width: 1.5, dash: '4 3', label: 'requested' },
            { kind: 'line', pts: ts.map((t) => [t, Math.max(-cap, Math.min(cap, req(t)))]), color: '#9cff8f', label: 'achieved' },
          ],
        };
        if (d >= 2) f.hlines = [{ y: cap, label: '+μg' }, { y: -cap, label: '−μg' }];
        return f;
      },
    },
    // ------------------------------------------------------------------ 3
    {
      id: 'resonance-runaway', pos: [0.04, 0.4], title: 'No friction: runaway resonance', short: 'runaway',
      status: 'proved', theorem: 'Friction.undampedResponse_unbounded', file: 'RequestProject/Friction/Mechanics.lean',
      builds: [],
      narration: 'Drive a frictionless oscillator at its own frequency and the swing grows without bound: t sine t over two. This is the exact mechanical counterpart of what the texts call Octave inflation. Energy keeps coming in, and nothing takes it out.',
      param: { key: 'w', label: 'driving frequency ω', min: 0.5, max: 1.5, step: 0.01 },
      depths: [
        { text: 'Pushing a swing exactly in time with it: each push adds a little, and with no friction the swing would climb forever.', formula: 'push in rhythm ⇒ amplitude grows', p: { w: 0.8 } },
        { text: 'The Nephilim\'s Octave inflation: doubling with nothing to cap it consumes everything.', formula: 'x(t) = t·sin t / 2', p: { w: 1 } },
        { text: 'Off resonance the response only beats and stays bounded; as ω approaches 1 the beat period and height grow without limit.', formula: 'x(t) = (cos ωt − cos t)/(1 − ω²),  ω ≠ 1', p: { w: 0.9 } },
        { text: 'Lean: t·sin t/2 satisfies x″ + x = cos t, and for every bound M there is a time t with x(t) > M.', formula: 'undampedResponse_unbounded : ∀ M, ∃ t, M < t * sin t / 2', p: { w: 1 } },
        { text: 'Real systems always have some damping and nonlinearity, so infinite growth is an idealisation. The mythic reading is an analogy, not a derivation.', formula: 'every real c > 0 caps the amplitude at 1/c', p: { w: 1.3 } },
      ],
      frame(p, u, d) {
        const w = p.w, T = 40;
        const x = (t) => Math.abs(w - 1) < 1e-6 ? t * Math.sin(t) / 2 : (Math.cos(w * t) - Math.cos(t)) / (1 - w * w);
        const Tu = u == null ? T : Math.max(0.5, T * (0.15 + 0.85 * u));
        const f = {
          title: `x″ + x = cos(ωt), ω = ${w.toFixed(2)}, no friction`, xr: [0, T], yr: [-22, 22], xlabel: 'time t', ylabel: 'x(t)',
          layers: [{ kind: 'line', pts: range(0, Tu, 240).map((t) => [t, x(t)]), color: '#ff8fb1' }],
        };
        if (d === 3) {
          f.layers.push({ kind: 'line', pts: range(0, T, 20).map((t) => [t, t / 2]), color: '#ffd479', width: 1, dash: '3 3', label: '±t/2 envelope' });
          f.layers.push({ kind: 'line', pts: range(0, T, 20).map((t) => [t, -t / 2]), color: '#ffd479', width: 1, dash: '3 3' });
        }
        return f;
      },
    },
    // ------------------------------------------------------------------ 4
    {
      id: 'damped-response', pos: [0.22, 0.4], title: 'Friction bounds the response', short: 'damped',
      status: 'proved', theorem: 'Friction.dampedResponse_amplitude', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['resonance-runaway'],
      narration: 'Add damping c and the same resonant push settles to a steady swing of height exactly one over c. A little friction turns runaway into rhythm.',
      param: { key: 'c', label: 'damping c', min: 0.02, max: 2, step: 0.01 },
      depths: [
        { text: 'A swing in air: pushed in rhythm it grows, then settles at a height where each push just replaces what the air takes.', formula: 'input per cycle = loss per cycle', p: { c: 0.3 } },
        { text: 'The 5:2 container holding the Toroidal Breath: the flow continues, but within bounds.', formula: 'x(t) → sin t / c', p: { c: 0.12 } },
        { text: 'Starting from rest, the response grows and approaches the steady solution sin t / c; the transient dies out like e^(−ct/2).', formula: 'x″ + c x′ + x = cos t', p: { c: 0.2 } },
        { text: 'Lean: sin t / c solves the damped equation for c ≠ 0, never exceeds 1/c for c > 0, and equals 1/c at t = π/2.', formula: 'dampedResponse_amplitude : (∀ t, |sin t / c| ≤ 1/c) ∧ …', p: { c: 0.5 } },
        { text: 'Large damping also shrinks the response the system is meant to have. Bounded is not the same as good; see the Goldilocks band.', formula: 'c → ∞  ⇒  amplitude 1/c → 0', p: { c: 1.6 } },
      ],
      frame(p, u, d) {
        const c = p.c, T = 50;
        const sol = oscillate(c, 1, 1, 0, 0, T, 1000);
        const Tu = u == null ? T : Math.max(1, T * (0.15 + 0.85 * u));
        const idx = sol.filter((r) => r[0] <= Tu);
        const pts = range(0, 1, 240).map((s) => { const r = idx[Math.round(s * (idx.length - 1))]; return [r[0], r[1]]; });
        const A = 1 / c;
        const ymax = Math.min(Math.max(A * 1.2, 2), 30);
        const f = {
          title: `x″ + ${c.toFixed(2)}·x′ + x = cos t, from rest`, xr: [0, T], yr: [-ymax, ymax], xlabel: 'time t', ylabel: 'x(t)',
          layers: [{ kind: 'line', pts, color: '#7ad7ff' }],
        };
        if (d >= 2) f.hlines = [{ y: A, label: 'amplitude 1/c = ' + A.toFixed(2) }, { y: -A }];
        return f;
      },
    },
    // ------------------------------------------------------------------ 5
    {
      id: 'energy-dissipation', pos: [0.42, 0.25], title: 'Friction never adds energy', short: 'dissipation',
      status: 'proved', theorem: 'Friction.energy_antitone', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['damped-response'],
      narration: 'With damping, the energy of a free oscillator can only go down. Without damping it is conserved: it has nowhere to go.',
      param: { key: 'c', label: 'damping c', min: 0, max: 3, step: 0.01 },
      depths: [
        { text: 'A pendulum released in a room swings lower each time; the missing energy has become a little heat in the air and the pivot.', formula: 'energy → heat', p: { c: 0.2 } },
        { text: 'The Rind that takes a share of every breath: without it, nothing settles; with too much, nothing moves.', formula: 'c = 0 ⇒ E constant', p: { c: 0 } },
        { text: 'Along any solution the energy changes at rate −c·v², which is never positive when c ≥ 0.', formula: "E = (v² + x²)/2,   E′ = −c v²", p: { c: 0.1 } },
        { text: 'Lean: for x′ = v, v′ = −cv − x with c ≥ 0, the energy (v² + x²)/2 is antitone; with c = 0 it is constant.', formula: 'energy_antitone : Antitone (fun t => (v t^2 + x t^2)/2)', p: { c: 0.4 } },
        { text: 'Too much damping (c ≥ 2, overdamped) kills the oscillation entirely: the system creeps back without a single swing.', formula: 'c ≥ 2: no oscillation', p: { c: 2.5 } },
      ],
      frame(p, u, d) {
        const c = p.c, T = 30;
        const sol = oscillate(c, 0, 0, 1, 0, T, 600);
        const Tu = u == null ? T : Math.max(0.5, T * (0.1 + 0.9 * u));
        const idx = sol.filter((r) => r[0] <= Tu);
        const pick = (k) => range(0, 1, 200).map((s) => { const r = idx[Math.round(s * (idx.length - 1))]; return [r[0], k(r)]; });
        const f = {
          title: `free oscillator, c = ${c.toFixed(2)}`, xr: [0, T], yr: [-1.1, 1.1], xlabel: 'time t', ylabel: 'x, E',
          layers: [
            { kind: 'line', pts: pick((r) => r[1]), color: '#7ad7ff', label: 'position x' },
            { kind: 'line', pts: pick((r) => (r[1] * r[1] + r[2] * r[2]) / 2), color: '#ffd479', label: 'energy E' },
          ],
        };
        if (d >= 2) f.hlines = [{ y: 0.5, label: 'E(0) = 1/2', color: '#6b7aa6' }];
        return f;
      },
    },
    // ------------------------------------------------------------------ 6
    {
      id: 'goldilocks-band', pos: [0.42, 0.58], title: 'The Goldilocks band', short: 'goldilocks',
      status: 'proved', theorem: 'Friction.goldilocks_band', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['damped-response'],
      narration: 'The steady amplitude one over c lands in a target band from a to b exactly when the damping lies between one over b and one over a. Too little friction runs away; too much smothers the signal.',
      param: { key: 'c', label: 'damping c', min: 0.05, max: 3, step: 0.01 },
      depths: [
        { text: 'A car\'s shock absorbers: too soft and it bounces down the road, too stiff and every bump hits your spine. Good ones sit in between.', formula: 'too soft · just right · too stiff', p: { c: 0.8 } },
        { text: 'Between the Nephilim (no cap) and the Box Trap (all cap) lies the balanced state the Antiquities call the necessary anchor.', formula: 'Octave inflation ← band → Box Trap', p: { c: 0.12 } },
        { text: 'Amplitude A(c) = 1/c is decreasing, so the set of dampings giving A ∈ [a, b] is an interval.', formula: 'a ≤ 1/c ≤ b  ⇔  1/b ≤ c ≤ 1/a', p: { c: 0.55 } },
        { text: 'Lean: for a, b, c > 0, (a ≤ 1/c ∧ 1/c ≤ b) ↔ (1/b ≤ c ∧ c ≤ 1/a).', formula: 'goldilocks_band a b c ha hb hc', p: { c: 1.0 } },
        { text: 'The band is chosen by whoever sets the goal. Mathematics gives the interval once a and b are fixed; it does not say which amplitude a life or a language should have.', formula: 'the choice of [a, b] is not mathematics', p: { c: 2.6 } },
      ],
      frame(p, u, d) {
        const a = 0.8, b = 2.5;
        const cs = range(0.05, 3, 150);
        const cc = sweep(p.c, 0.05, 3, u);
        const where = cc < 1 / b ? 'runaway side' : cc > 1 / a ? 'suppressed side' : 'in the band';
        return {
          title: `steady amplitude 1/c; band [${a}, ${b}]`, xr: [0, 3], yr: [0, 6], xlabel: 'damping c', ylabel: 'amplitude',
          band: { lo: a, hi: b, label: 'target band' },
          vlines: d >= 2 ? [{ x: 1 / b, label: '1/b' }, { x: 1 / a, label: '1/a' }] : [],
          layers: [
            { kind: 'line', pts: cs.map((c) => [c, 1 / c]), color: '#7ad7ff' },
            { kind: 'dots', pts: [[cc, 1 / cc]], color: '#ffd479', r: 6 },
          ],
          notes: [{ text: `c = ${cc.toFixed(2)}: ${where}` }],
        };
      },
    },
    // ------------------------------------------------------------------ 7
    {
      id: 'impedance-matching', pos: [0.64, 0.58], title: 'Matched, not zero', short: 'matching',
      status: 'proved', theorem: 'Friction.max_power_transfer', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['goldilocks-band'],
      narration: 'A zero-resistance load receives no power at all. The power delivered is largest when the load matches the source. Clean transfer means matched impedance, not no impedance.',
      param: { key: 'R', label: 'load resistance R (source Rs = 1)', min: 0, max: 6, step: 0.01 },
      depths: [
        { text: 'A bicycle in the wrong gear: too low and your legs spin without pushing, too high and you cannot turn the pedals. The right gear matches your legs to the road.', formula: 'gear ratio matched to rider', p: { R: 0.5 } },
        { text: 'A frictionless load is a short circuit: all the flow, none of the work. The Open Channel cannot mean zero resistance.', formula: 'R = 0  ⇒  P = 0', p: { R: 0 } },
        { text: 'Power into the load is V²R/(Rs+R)²; it rises from 0, peaks at R = Rs, and falls towards 0 again.', formula: 'P(R) = V² R / (Rs + R)²', p: { R: 2 } },
        { text: 'Lean: P(0) = 0, P(Rs) = V²/(4Rs), and P(R) ≤ P(Rs) for every R ≥ 0.', formula: 'max_power_transfer : loadPower V Rs R ≤ loadPower V Rs Rs', p: { R: 1 } },
        { text: 'Maximum power is not maximum efficiency: at the match half the power heats the source. Which quantity to maximise is a choice.', formula: 'efficiency at match = 50%', p: { R: 5 } },
      ],
      frame(p, u, d) {
        const V = 2, Rs = 1;
        const P = (R) => V * V * R / ((Rs + R) * (Rs + R));
        const RR = sweep(p.R, 0, 6, u);
        const f = {
          title: 'power into the load, V = 2, Rs = 1', xr: [0, 6], yr: [0, 1.2], xlabel: 'load R', ylabel: 'power P',
          layers: [
            { kind: 'line', pts: range(0, 6, 150).map((R) => [R, P(R)]), color: '#9cff8f' },
            { kind: 'dots', pts: [[RR, P(RR)]], color: '#ffd479', r: 6 },
          ],
          notes: [{ text: `R = ${RR.toFixed(2)}: P = ${P(RR).toFixed(3)}` }],
        };
        if (d >= 2) f.vlines = [{ x: Rs, label: 'R = Rs' }];
        if (d === 4) f.layers.push({ kind: 'line', pts: range(0, 6, 150).map((R) => [R, R / (Rs + R)]), color: '#c39bff', dash: '4 3', label: 'efficiency R/(Rs+R)' });
        return f;
      },
    },
    // ------------------------------------------------------------------ 8
    {
      id: 'open-channel', pos: [0.86, 0.42], title: 'Open Channel as a matched channel', short: 'open channel',
      status: 'proved', theorem: 'Friction.max_power_transfer', file: 'RequestProject/Friction/Mechanics.lean',
      builds: ['impedance-matching', 'energy-dissipation'],
      narration: 'Read the Open Channel, one hundred forty-four equals zero zero zero, as a matched channel: nothing is reflected back as interference, yet the load still does work. That removes the tension between the frictionless avatar and the claim that frictionless existence is unsustainable.',
      param: { key: 'r', label: 'mismatch R/Rs', min: 0.05, max: 6, step: 0.01 },
      depths: [
        { text: 'Two people talking at the same pace and vocabulary: little has to be repeated, and nothing bounces back as "what?".', formula: 'little reflected, most delivered', p: { r: 0.6 } },
        { text: 'State 4, 144 = 000: Source passes without being reflected into the Box Trap — without being frictionless.', formula: '144 = 000  ↦  Γ = 0', p: { r: 1 } },
        { text: 'The reflected fraction is Γ² with Γ = (R − Rs)/(R + Rs); the delivered fraction is 1 − Γ² = 4RRs/(R+Rs)² = P/Pmax.', formula: '1 − Γ² = 4 R Rs / (R + Rs)²', p: { r: 3 } },
        { text: 'Lean: this delivered fraction is P(R)/P(Rs) from max_power_transfer, which is at most 1, with equality at the match.', formula: 'loadPower V Rs R ≤ loadPower V Rs Rs', p: { r: 0.25 } },
        { text: 'This is a proposed reading of the framework\'s State 4, not something the source texts or physics establish about consciousness (Layer D).', formula: 'interpretation, Layer D', p: { r: 5 } },
      ],
      frame(p, u, d) {
        const rs = range(0.05, 6, 160);
        const G2 = (r) => Math.pow((r - 1) / (r + 1), 2);
        const rr = sweep(p.r, 0.05, 6, u);
        return {
          title: 'delivered vs reflected share of the flow', xr: [0, 6], yr: [0, 1.05], xlabel: 'mismatch R/Rs', ylabel: 'share',
          vlines: d >= 1 ? [{ x: 1, label: 'matched', color: '#9cff8f' }] : [],
          layers: [
            { kind: 'line', pts: rs.map((r) => [r, 1 - G2(r)]), color: '#9cff8f', label: 'delivered 1 − Γ²' },
            { kind: 'line', pts: rs.map((r) => [r, G2(r)]), color: '#ff8fb1', label: 'reflected Γ²' },
            { kind: 'dots', pts: [[rr, 1 - G2(rr)], [rr, G2(rr)]], colors: ['#9cff8f', '#ff8fb1'], r: 5 },
          ],
        };
      },
    },
    // ------------------------------------------------------------------ 9
    {
      id: 'compression-merge', pos: [0.2, 0.94], title: 'Compression merges intents', short: 'compression',
      status: 'proved', theorem: 'Friction.encoding_must_merge', file: 'RequestProject/Friction/Channel.lean',
      builds: [],
      narration: 'If there are more distinct intents than words to carry them, every encoding merges two different intents into one expression. This compression friction cannot be avoided, and it is what makes a meaning shareable.',
      param: { key: 'N', label: 'vocabulary size N (12 intents)', min: 1, max: 14, step: 1 },
      depths: [
        { text: 'Trying to describe twelve shades of feeling with six words: some shades have to share a word.', formula: '12 intents → 6 words', p: { N: 6 } },
        { text: 'High-bandwidth Phase forced through a low-bandwidth channel: the texts\' "catastrophic data loss".', formula: 'Phase → finite symbols', p: { N: 3 } },
        { text: 'Pigeonhole principle: an injective map from M things to N < M things cannot exist, so some word carries two or more intents.', formula: 'N < M  ⇒  ∃ i ≠ j, f(i) = f(j)', p: { N: 9 } },
        { text: 'Lean: for N < M, every f : Fin M → Fin N has i ≠ j with f i = f j.', formula: 'encoding_must_merge (h : N < M) f : ∃ i j, i ≠ j ∧ f i = f j', p: { N: 11 } },
        { text: 'The loss comes from finiteness, not from a particular language. Spoken languages are reported to reach broadly similar information rates, so this does not rank English or Sanskrit.', formula: 'finiteness, not a language ranking', p: { N: 12 } },
      ],
      frame(p, u, d) {
        const N = Math.max(1, Math.round(p.N));
        const M = u == null ? 12 : Math.max(1, Math.round(1 + 13 * wave(u)));
        const load = Array.from({ length: N }, (_, w) => Math.floor(M / N) + (w < M % N ? 1 : 0));
        return {
          title: `${M} intents spread over ${N} words`, xr: [0.5, N + 0.5], yr: [0, 6], xlabel: 'word', ylabel: 'intents per word',
          hlines: d >= 2 ? [{ y: 1, label: 'one intent per word', color: '#9cff8f' }] : [],
          layers: [{ kind: 'bars', pts: load.map((k, w) => [w + 1, k]), colors: load.map((k) => (k > 1 ? '#ff8fb1' : '#7ad7ff')) }],
          notes: [{ text: M > N ? 'merges are forced' : 'no merge needed' }],
        };
      },
    },
    // ------------------------------------------------------------------ 10
    {
      id: 'redundancy-majority', pos: [0.42, 0.94], title: 'Over-explaining as error correction', short: 'redundancy',
      status: 'proved', theorem: 'Friction.majority_corrects_one', file: 'RequestProject/Friction/Channel.lean',
      builds: ['compression-merge'],
      narration: 'Say a bit three times and take the majority: any single corruption is corrected. Two corruptions defeat it, and it costs three symbols per bit. Redundancy is friction that pays for itself, up to the noise level.',
      param: { key: 'q', label: 'corruption probability q', min: 0, max: 0.5, step: 0.005 },
      depths: [
        { text: 'Repeating an important instruction in three ways, so one mis-heard version is outvoted by the other two.', formula: 'say it three times', p: { q: 0.1 } },
        { text: 'The Languanaut\'s caveats and context: rebuilding intent against a noisy channel (a Layer C reading of over-explaining).', formula: 'redundancy against noise', p: { q: 0.3 } },
        { text: 'With independent corruption probability q, one copy fails with probability q, a majority of three with 3q² − 2q³, which is smaller whenever q < 1/2.', formula: 'P_fail = 3q² − 2q³  <  q   (0 < q < ½)', p: { q: 0.05 } },
        { text: 'Lean: majority of the three received copies equals the sent bit whenever at most one copy was flipped; with two flipped it returns the wrong bit.', formula: 'majority_corrects_one · majority_fails_two', p: { q: 0.2 } },
        { text: 'Correlated errors (the same bias every time) are not fixed by repetition, and the rate drops to 1/3. Beyond the noise level, redundancy is just drag.', formula: 'rate = 1/3; correlated errors survive', p: { q: 0.45 } },
      ],
      frame(p, u, d) {
        const qs = range(0, 0.5, 100);
        const qq = sweep(p.q, 0, 0.5, u);
        const maj = (q) => 3 * q * q - 2 * q * q * q;
        const f = {
          title: 'error rate: one copy vs majority of three', xr: [0, 0.5], yr: [0, 0.55], xlabel: 'corruption probability q', ylabel: 'error rate',
          layers: [
            { kind: 'line', pts: qs.map((q) => [q, q]), color: '#ff8fb1', label: 'say it once: q' },
            { kind: 'line', pts: qs.map((q) => [q, maj(q)]), color: '#9cff8f', label: 'say it thrice: 3q² − 2q³' },
            { kind: 'dots', pts: [[qq, qq], [qq, maj(qq)]], colors: ['#ff8fb1', '#9cff8f'], r: 5 },
          ],
        };
        if (d === 4) f.hlines = [{ y: 1 / 3, label: 'cost: rate 1/3', color: '#c39bff' }];
        return f;
      },
    },
    // ------------------------------------------------------------------ 11
    {
      id: 'babel-placement', pos: [0.64, 0.86], title: 'Babel: where friction sits', short: 'Babel',
      status: 'interpretive', theorem: null, file: 'FRICTION_EXAMINATION.md',
      builds: ['compression-merge', 'goldilocks-band'],
      narration: 'The two Babel readings in the texts are two sides of one friction. One imposed language met no resistance, like an undamped system amplifying itself. Fragmentation added damping, and becomes harmful only when nobody can understand anybody.',
      param: { key: 'f', label: 'fragmentation f', min: 0, max: 1, step: 0.01 },
      depths: [
        { text: 'A meeting where one voice may speak is fast and brittle; a meeting where nobody shares a language is safe and useless. Good meetings sit between.', formula: 'one voice · many voices · no shared voice', p: { f: 0.4 } },
        { text: 'Antiquities: Babel as imposed impedance. Blog: Babel as the end of a coerced, class-based unity. Both are true of different amounts of friction.', formula: 'harmful friction  vs  protective friction', p: { f: 0.1 } },
        { text: 'Illustrative model only: shared understanding falls with fragmentation, resistance to coercion rises, and their product peaks in the middle.', formula: 'health(f) = (1 − f)·f  (illustrative)', p: { f: 0.5 } },
        { text: 'No Lean theorem applies: this is interpretation (Layers C/D). The shape borrows the Goldilocks structure, which is proved for the oscillator only.', formula: 'no theorem — see goldilocks_band for the mechanical analogue', p: { f: 0.7 } },
        { text: 'The curves are invented to show a shape, not measured. Treat any number on this chart as a picture, not data.', formula: 'not measured', p: { f: 0.95 } },
      ],
      frame(p, u, d) {
        const fs = range(0, 1, 100);
        const ff = sweep(p.f, 0, 1, u);
        return {
          title: 'illustrative (not measured): friction placement', xr: [0, 1], yr: [0, 1.05], xlabel: 'fragmentation f', ylabel: 'relative level',
          layers: [
            { kind: 'line', pts: fs.map((f) => [f, 1 - f]), color: '#7ad7ff', label: 'shared understanding', dash: '5 3' },
            { kind: 'line', pts: fs.map((f) => [f, f]), color: '#ffd479', label: 'resistance to coercion', dash: '5 3' },
            { kind: 'line', pts: fs.map((f) => [f, 4 * f * (1 - f)]), color: '#9cff8f', label: 'both at once (scaled)' },
            { kind: 'dots', pts: [[ff, 4 * ff * (1 - ff)]], color: '#9cff8f', r: 6 },
          ],
        };
      },
    },
    // ------------------------------------------------------------------ 12
    {
      id: 'tesla-cipher', pos: [0.64, 0.1], title: 'The ×6 cipher is about 3, not English', short: '×6 cipher',
      status: 'proved', theorem: 'Friction.tesla_cipher_digital_root', file: 'RequestProject/Friction/NumericalClaims.lean',
      builds: [],
      narration: 'Multiply letter positions by six and every digital root is three, six or nine. But the same happens for every positive number and any multiplier divisible by three, so it says nothing about English.',
      param: { key: 'm', label: 'multiplier m', min: 1, max: 12, step: 1 },
      depths: [
        { text: 'Multiply your house number by three and add up the digits until one digit is left: you always get 3, 6 or 9.', formula: 'digital root of 3n ∈ {3, 6, 9}', p: { m: 3 } },
        { text: 'The Manifesto\'s claim: the ×6 cipher "proves the English language is built upon the Tri-Torus frequency engine".', formula: 'A=6, B=12, …, G=42', p: { m: 6 } },
        { text: 'Digit sums preserve the remainder mod 9; a multiple of 3 has remainder 0, 3 or 6, so its digital root is 9, 3 or 6.', formula: 'digitSum n ≡ n (mod 9)', p: { m: 9 } },
        { text: 'Lean: for any positive m with 3 ∣ m and any n > 0, every single digit reached from m·n by repeated digit sums is 3, 6 or 9.', formula: 'tesla_cipher_digital_root m n r hm hmpos hn hr hr10', p: { m: 12 } },
        { text: 'With a multiplier not divisible by 3 (say 7), all nine roots appear. The pattern belongs to the multiplier.', formula: 'm = 7: roots 1…9 all occur', p: { m: 7 } },
      ],
      frame(p, u, d) {
        const m = Math.round(p.m) * (u == null ? 1 : 1 + Math.floor(u * 5.999));
        const roots = Array.from({ length: 26 }, (_, i) => digitalRoot(m * (i + 1)));
        return {
          title: `digital root of ${m}·n for letters n = 1…26`, xr: [0.5, 26.5], yr: [0, 9.8], xlabel: 'letter position n (A = 1)', ylabel: 'digital root',
          hlines: d >= 2 ? [{ y: 3, color: '#6b7aa6' }, { y: 6, color: '#6b7aa6' }, { y: 9, label: '3 · 6 · 9', color: '#6b7aa6' }] : [],
          layers: [{ kind: 'bars', pts: roots.map((r, i) => [i + 1, r]), colors: roots.map((r) => (r % 3 === 0 ? '#ffd479' : '#7ad7ff')) }],
          notes: [{ text: m % 3 === 0 ? 'm divisible by 3: only 3, 6, 9' : 'm not divisible by 3: all roots' }],
        };
      },
    },
    // ------------------------------------------------------------------ 13
    {
      id: 'look-elsewhere', pos: [0.88, 0.02], title: 'Alphabet–geometry matches are expected', short: 'look-elsewhere',
      status: 'proved', theorem: 'Friction.framework_constants_cover_alphabet_sizes', file: 'RequestProject/Friction/NumericalClaims.lean',
      builds: ['tesla-cipher'],
      narration: 'Every whole number from twenty to thirty-six is one of the framework\'s own constants, or the sum of two of them. So finding a geometric match for an alphabet size is expected by chance. The fix is the texts\' own Blind Mapping Test: fix the rule first.',
      param: { key: 'k', label: 'summands allowed k', min: 1, max: 3, step: 1 },
      depths: [
        { text: 'With enough coins of different sizes you can pay almost any price. With enough constants you can "explain" almost any count.', formula: 'many constants ⇒ many matches', p: { k: 3, c: 6 } },
        { text: 'Greek 24 ↔ cube rotations, Hebrew 22 ↔ icosahedron 20 + 2, Latin 62 ↔ 12 + 20 + 30.', formula: '24 = 24,  22 = 20 + 2,  62 = 12 + 20 + 30', p: { k: 2 } },
        { text: 'Using the constants {1, 2, 3, 4, 5, 6, 8, 12, 20, 24, 30, 60, 144}, count which sizes are a constant or a sum of k of them.', formula: 'n = c₁ + … + cₖ,  k ≤ 2', p: { k: 1 } },
        { text: 'Lean (by exhaustive check): every n in 20…36 is a constant or a sum of two constants.', formula: 'framework_constants_cover_alphabet_sizes', p: { k: 2 } },
        { text: 'A mapping becomes evidence only if the rule is fixed before looking at the data and would have failed on other data.', formula: 'Blind Mapping Test', p: { k: 3 } },
      ],
      frame(p, u, d) {
        const k = Math.round(p.k);
        const nMax = p.c || CONSTANTS.length;
        const nConst = u == null ? nMax : Math.max(1, Math.round(nMax * wave(u)));
        const cs = CONSTANTS.slice(0, nConst);
        const ns = range(10, 45, 35);
        const ok = ns.map((n) => covered(n, cs, k));
        return {
          title: `sizes 10…45 reachable with ${nConst} constants, ≤ ${k} summand(s)`, xr: [9.5, 45.5], yr: [0, 1.5], xlabel: 'alphabet size', ylabel: 'matched?',
          vlines: d >= 2 ? [{ x: 20, label: '20', color: '#6b7aa6' }, { x: 36, label: '36', color: '#6b7aa6' }] : [],
          layers: [
            { kind: 'bars', pts: ns.map((n, i) => [n, ok[i] ? 1 : 0.05]), colors: ok.map((o) => (o ? '#9cff8f' : '#ff8fb1')) },
            { kind: 'dots', pts: ALPHABETS.map(([n]) => [n, 1.25]), color: '#ffd479', r: 4 },
          ],
          notes: [{ text: 'yellow dots: Hebrew, Greek, Latin, Arabic, Russian, Armenian' }],
        };
      },
    },
    // ------------------------------------------------------------------ 14
    {
      id: 'octave-prime', pos: [0.88, 0.2], title: 'Octaves and primes share only 2', short: 'octave ∩ prime',
      status: 'proved', theorem: 'Friction.octave_prime_iff', file: 'RequestProject/Friction/NumericalClaims.lean',
      builds: ['tesla-cipher'],
      narration: 'A power of two is prime exactly when the exponent is one. The fluid octave family and the rigid prime family share exactly one number, two, which is also one of the two numbers in five to two.',
      param: { key: 'n', label: 'range up to n', min: 8, max: 128, step: 1 },
      depths: [
        { text: 'Keep doubling from 1: 2, 4, 8, 16… Only the first step lands on a prime.', formula: '1, 2, 4, 8, 16, 32, …', p: { n: 32 } },
        { text: 'The Musical Matrix: Octaves as fluid Phase (Voynichese), Primes as rigid anchors (Cuneiform), and the 5:2 container built from primes.', formula: 'Octave ≠ Prime ?', p: { n: 16 } },
        { text: '2ᵏ has divisor 2, so for k ≥ 2 it is composite; 2¹ = 2 is prime; 2⁰ = 1 is not prime.', formula: '2ᵏ prime ⇔ k = 1', p: { n: 64 } },
        { text: 'Lean: Nat.Prime (2 ^ k) ↔ k = 1.', formula: 'octave_prime_iff k', p: { n: 128 } },
        { text: 'The two families are not disjoint, so any argument needing them to be separate categories fails — although 2 as "anchor and flow" is a pleasing reading.', formula: '{2ᵏ} ∩ Primes = {2}', p: { n: 100 } },
      ],
      frame(p, u, d) {
        const N = u == null ? Math.round(p.n) : Math.round(8 + (p.n - 8) * wave(u));
        const xs = range(1, 128, 127).map(Math.round);
        return {
          title: `primes and powers of two up to ${N}`, xr: [0, 130], yr: [0, 3], xlabel: 'n', ylabel: '',
          layers: [
            { kind: 'dots', pts: xs.map((n) => [n, n <= N && isPrime(n) ? 1 : NaN]), color: '#7ad7ff', r: 3 },
            { kind: 'dots', pts: xs.map((n) => [n, n <= N && (n & (n - 1)) === 0 ? 2 : NaN]), color: '#ffd479', r: 4 },
            { kind: 'dots', pts: [[2, d >= 2 ? 1.5 : NaN]], color: '#ff8fb1', r: 7 },
          ],
          notes: [{ text: 'row 1: primes · row 2: powers of two' }, { text: d >= 2 ? 'pink: 2, in both' : '' }],
        };
      },
    },
  ];

  const byId = Object.fromEntries(ELEMENTS.map((e) => [e.id, e]));
  const EDGES = [];
  for (const e of ELEMENTS) for (const b of e.builds) EDGES.push([b, e.id]);

  return { DEPTHS, ELEMENTS, EDGES, byId, oscillate, digitalRoot, isPrime, covered, CONSTANTS };
});
