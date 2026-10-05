/*
 * friction atlas — grid.js
 *
 * **n² representations at knowledge level n.**  Every knowledge element can be
 * shown in FORMS (words, graph, symbols, animation, interactive) at DEPTHS
 * (everyday, image, mechanism, formal, limits).  At level n a reader sees the
 * first n forms × the first n depths — an n × n grid, so exactly n² distinct
 * representations — and moving up a level only *adds* the 2n + 1 cells of the
 * new row and column; nothing already learnt disappears.
 *
 * The arithmetic (cell count n², row-major index r·n + c < n², the level-n grid
 * sitting inside the level-(n+1) grid, 2n + 1 new cells) is specified and proved
 * in Lean: `RequestProject/Site/Grid.lean`.  `test/run.mjs` checks this file
 * against those statements and checks that all n² pictures really differ.
 */
(function (root, factory) {
  const mod = factory(root.FrictionSVG || (typeof require === 'function' ? require('./svgkit.js') : null),
    root.FrictionKnowledge || (typeof require === 'function' ? require('./knowledge.js') : null));
  root.FrictionGrid = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function (SVG, K) {
  'use strict';

  const FORMS = [
    { id: 'words', name: 'Words', icon: '¶' },
    { id: 'graph', name: 'Graph', icon: '⌁' },
    { id: 'symbols', name: 'Symbols', icon: '∑' },
    { id: 'animation', name: 'Animation', icon: '▶' },
    { id: 'interactive', name: 'Interactive', icon: '⇆' },
  ];
  const MAX_LEVEL = Math.min(FORMS.length, K.DEPTHS.length);

  const clampLevel = (n) => Math.max(1, Math.min(MAX_LEVEL, Math.floor(Number(n) || 1)));

  /** The cells of level n, row-major: row = depth, column = form. */
  function cells(n) {
    n = clampLevel(n);
    const out = [];
    for (let r = 0; r < n; r++) for (let c = 0; c < n; c++) out.push({ r, c, index: r * n + c });
    return out;
  }
  const cellIndex = (n, r, c) => r * n + c;
  const cellAt = (n, i) => ({ r: Math.floor(i / n), c: i % n });
  /** Cells present at level n + 1 but not at level n. */
  const newCells = (n) => cells(n + 1).filter(({ r, c }) => r >= n || c >= n);

  /** Stable address of one representation, usable in a link. */
  const address = (el, r, c) => `${el.id}/${K.DEPTHS[r].id}/${FORMS[c].id}`;

  /**
   * Render one representation.  Returns
   *   { kind: 'svg', svg, caption }           for words, graph, symbols, animation
   *   { kind: 'interactive', param, p, d, caption } for the interactive form
   * The interactive form is drawn live by the page with `interactiveSVG`.
   */
  function render(el, r, c) {
    const depth = el.depths[r];
    const D = K.DEPTHS[r];
    const F = FORMS[c];
    const caption = `${el.title} · ${D.name} · ${F.name}`;
    switch (F.id) {
      case 'words':
        return { kind: 'svg', caption, svg: SVG.card(`${D.name}: ${el.title}`, [depth.text]) };
      case 'symbols': {
        const lines = [depth.formula];
        if (D.id === 'formal') lines.push('', el.theorem ? `theorem ${el.theorem}` : 'no theorem: interpretive', `in ${el.file}`);
        return { kind: 'svg', caption, svg: SVG.card(`${D.name} symbols: ${el.short}`, lines, { mono: true }) };
      }
      case 'graph':
        return { kind: 'svg', caption, svg: SVG.plot(el.frame(depth.p, null, r)) };
      case 'animation':
        return { kind: 'svg', caption, svg: SVG.animate((u) => el.frame(depth.p, u, r), { frames: 36, duration: 6 }) };
      case 'interactive':
        return { kind: 'interactive', caption, param: el.param, p: Object.assign({}, depth.p), d: r };
    }
    throw new Error('unknown form');
  }

  /** The live picture for the interactive form at slider value v and phase u. */
  function interactiveSVG(el, r, v, u) {
    const p = Object.assign({}, el.depths[r].p, { [el.param.key]: v });
    const f = el.frame(p, u == null ? null : u, r);
    f.title = '⇆ ' + (f.title || el.title);
    f.notes = (f.notes || []).concat([{ text: `${el.param.label} = ${(+v).toFixed(2)}`, color: '#ffd479' }]);
    return SVG.plot(f);
  }

  /** A text fingerprint of a representation (used by tests to check the n² cells differ). */
  function fingerprint(el, r, c) {
    const rep = render(el, r, c);
    if (rep.kind === 'svg') return rep.svg;
    const v0 = rep.p[rep.param.key];
    return 'interactive:' + interactiveSVG(el, r, v0, null);
  }

  return { FORMS, MAX_LEVEL, clampLevel, cells, cellIndex, cellAt, newCells, address, render, interactiveSVG, fingerprint };
});
