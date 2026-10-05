/*
 * friction atlas — svgkit.js
 *
 * Every picture in the atlas is a *string* of SVG.  That keeps one code path
 * for the page, for "save .svg", and for pictures that travel in shared
 * links, and lets the test suite check every picture without a browser.
 *
 *   frame  = { xr:[a,b], yr:[a,b], xlabel, ylabel, title, layers:[layer…],
 *              band:{lo,hi,label}?, hlines:[{y,label}]?, vlines:[{x,label}]? }
 *   layer  = { kind:'line'|'bars'|'dots', pts:[[x,y]…], color, width?, label? }
 *
 * `plot(frame)` draws one still.  `animate(frameAt, opts)` samples a frame
 * function over one loop and emits SMIL `<animate>` elements, so the result is
 * a self-contained animated SVG: it plays in an <img>, in a file viewer and
 * after download, with no script.
 */
(function (root, factory) {
  const mod = factory();
  root.FrictionSVG = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function () {
  'use strict';

  const W = 480, H = 300;
  const PAD = { l: 52, r: 16, t: 42, b: 40 };
  const THEME = {
    bg: '#070b18', grid: '#1b2440', axis: '#6b7aa6', text: '#cfe3ff', dim: '#8796c0',
    band: 'rgba(122,215,255,0.13)', bandEdge: '#7ad7ff',
  };
  const PALETTE = ['#7ad7ff', '#ffd479', '#9cff8f', '#ff8fb1', '#c39bff', '#ffa25c'];

  function esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  const clip = (s, n) => (String(s).length > n ? String(s).slice(0, n - 1) + '…' : String(s));
  const fmt = (v) => (Math.abs(v) < 1e-9 ? '0' : (+v.toFixed(2)).toString());
  const finite = (v) => Number.isFinite(v);

  function scaler(frame) {
    const [x0, x1] = frame.xr, [y0, y1] = frame.yr;
    const sx = (x) => PAD.l + (x - x0) / (x1 - x0 || 1) * (W - PAD.l - PAD.r);
    const sy = (y) => {
      const c = Math.min(Math.max(y, y0 - (y1 - y0)), y1 + (y1 - y0)); // keep paths sane
      return H - PAD.b - (c - y0) / (y1 - y0 || 1) * (H - PAD.t - PAD.b);
    };
    return { sx, sy };
  }

  function niceTicks(a, b, n) {
    const span = b - a;
    if (!(span > 0)) return [a];
    const raw = span / (n || 5);
    const mag = Math.pow(10, Math.floor(Math.log10(raw)));
    const step = [1, 2, 2.5, 5, 10].map((m) => m * mag).find((s) => s >= raw) || raw;
    const out = [];
    for (let v = Math.ceil(a / step) * step; v <= b + 1e-9; v += step) out.push(+v.toFixed(10));
    return out;
  }

  function linePath(pts, s) {
    let d = '';
    let pen = false;
    for (const [x, y] of pts) {
      if (!finite(y)) { pen = false; continue; }
      d += (pen ? 'L' : 'M') + s.sx(x).toFixed(1) + ' ' + s.sy(y).toFixed(1);
      pen = true;
    }
    return d || 'M0 0';
  }

  function axes(frame, s) {
    const out = [];
    const [x0, x1] = frame.xr, [y0, y1] = frame.yr;
    for (const v of niceTicks(x0, x1, 6)) {
      out.push(`<line x1="${s.sx(v).toFixed(1)}" y1="${PAD.t}" x2="${s.sx(v).toFixed(1)}" y2="${H - PAD.b}" stroke="${THEME.grid}"/>`);
      out.push(`<text x="${s.sx(v).toFixed(1)}" y="${H - PAD.b + 14}" fill="${THEME.dim}" font-size="10" text-anchor="middle">${fmt(v)}</text>`);
    }
    for (const v of niceTicks(y0, y1, 5)) {
      out.push(`<line x1="${PAD.l}" y1="${s.sy(v).toFixed(1)}" x2="${W - PAD.r}" y2="${s.sy(v).toFixed(1)}" stroke="${THEME.grid}"/>`);
      out.push(`<text x="${PAD.l - 6}" y="${(s.sy(v) + 3).toFixed(1)}" fill="${THEME.dim}" font-size="10" text-anchor="end">${fmt(v)}</text>`);
    }
    const zx = Math.min(Math.max(0, x0), x1), zy = Math.min(Math.max(0, y0), y1);
    out.push(`<line x1="${PAD.l}" y1="${s.sy(zy).toFixed(1)}" x2="${W - PAD.r}" y2="${s.sy(zy).toFixed(1)}" stroke="${THEME.axis}"/>`);
    out.push(`<line x1="${s.sx(zx).toFixed(1)}" y1="${PAD.t}" x2="${s.sx(zx).toFixed(1)}" y2="${H - PAD.b}" stroke="${THEME.axis}"/>`);
    if (frame.xlabel) out.push(`<text x="${W - PAD.r}" y="${H - 8}" fill="${THEME.text}" font-size="11" text-anchor="end">${esc(frame.xlabel)}</text>`);
    if (frame.ylabel) out.push(`<text x="14" y="${PAD.t - 8}" fill="${THEME.text}" font-size="11">${esc(frame.ylabel)}</text>`);
    return out.join('');
  }

  function decorations(frame, s) {
    const out = [];
    if (frame.band) {
      const yA = s.sy(frame.band.hi), yB = s.sy(frame.band.lo);
      out.push(`<rect x="${PAD.l}" y="${yA.toFixed(1)}" width="${W - PAD.l - PAD.r}" height="${Math.max(0, yB - yA).toFixed(1)}" fill="${THEME.band}" stroke="${THEME.bandEdge}" stroke-dasharray="4 3"/>`);
      if (frame.band.label) out.push(`<text x="${W - PAD.r - 4}" y="${(yA + 12).toFixed(1)}" fill="${THEME.bandEdge}" font-size="10" text-anchor="end">${esc(frame.band.label)}</text>`);
    }
    for (const h of frame.hlines || []) {
      out.push(`<line x1="${PAD.l}" y1="${s.sy(h.y).toFixed(1)}" x2="${W - PAD.r}" y2="${s.sy(h.y).toFixed(1)}" stroke="${h.color || '#ffd479'}" stroke-dasharray="5 4"/>`);
      if (h.label) out.push(`<text x="${PAD.l + 4}" y="${(s.sy(h.y) - 4).toFixed(1)}" fill="${h.color || '#ffd479'}" font-size="10">${esc(h.label)}</text>`);
    }
    for (const v of frame.vlines || []) {
      out.push(`<line x1="${s.sx(v.x).toFixed(1)}" y1="${PAD.t}" x2="${s.sx(v.x).toFixed(1)}" y2="${H - PAD.b}" stroke="${v.color || '#ff8fb1'}" stroke-dasharray="5 4"/>`);
      if (v.label) out.push(`<text x="${(s.sx(v.x) + 4).toFixed(1)}" y="${PAD.t + 12}" fill="${v.color || '#ff8fb1'}" font-size="10">${esc(v.label)}</text>`);
    }
    return out.join('');
  }

  function barGeom(layer, i, s, frame) {
    const n = layer.pts.length;
    const [x, y] = layer.pts[i];
    const span = (frame.xr[1] - frame.xr[0]) / Math.max(n, 1);
    const w = Math.max(1, (s.sx(frame.xr[0] + span) - s.sx(frame.xr[0])) * 0.72);
    const base = s.sy(Math.max(frame.yr[0], 0));
    const top = s.sy(finite(y) ? y : 0);
    return { x: s.sx(x) - w / 2, y: Math.min(top, base), w, h: Math.abs(base - top) };
  }

  function legend(frame) {
    const named = frame.layers.filter((l) => l.label);
    return named.map((l, i) => {
      const c = l.color || PALETTE[i % PALETTE.length];
      const y = PAD.t + 6 + i * 14;
      return `<rect x="${PAD.l + 8}" y="${y - 7}" width="10" height="3" fill="${c}"/>` +
        `<text x="${PAD.l + 22}" y="${y - 3}" fill="${THEME.text}" font-size="10">${esc(l.label)}</text>`;
    }).join('');
  }

  function open(frame, extraStyle) {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" font-family="ui-sans-serif,system-ui,sans-serif"${extraStyle || ''}>` +
      `<rect width="${W}" height="${H}" rx="10" fill="${THEME.bg}"/>` +
      (frame.title ? `<text x="14" y="20" fill="${THEME.text}" font-size="12.5" font-weight="600">${esc(clip(frame.title, 60))}</text>` : '');
  }

  /** A still picture of one frame. */
  function plot(frame) {
    const s = scaler(frame);
    const body = frame.layers.map((l, i) => {
      const c = l.color || PALETTE[i % PALETTE.length];
      if (l.kind === 'bars') {
        return l.pts.map((_, j) => {
          const g = barGeom(l, j, s, frame);
          return `<rect x="${g.x.toFixed(1)}" y="${g.y.toFixed(1)}" width="${g.w.toFixed(1)}" height="${g.h.toFixed(1)}" fill="${(l.colors && l.colors[j]) || c}" rx="1.5"/>`;
        }).join('');
      }
      if (l.kind === 'dots') {
        return l.pts.filter((p) => finite(p[1])).map(([x, y], j) =>
          `<circle cx="${s.sx(x).toFixed(1)}" cy="${s.sy(y).toFixed(1)}" r="${l.r || 4}" fill="${(l.colors && l.colors[j]) || c}"/>`).join('');
      }
      return `<path d="${linePath(l.pts, s)}" fill="none" stroke="${c}" stroke-width="${l.width || 2.5}" stroke-linejoin="round" stroke-linecap="round"${l.dash ? ` stroke-dasharray="${l.dash}"` : ''}/>`;
    }).join('');
    return open(frame) + axes(frame, s) + decorations(frame, s) + body + legend(frame) + notes(frame) + '</svg>';
  }

  function notes(frame) {
    return (frame.notes || []).map((n, i) =>
      `<text x="${W - PAD.r}" y="${H - PAD.b - 8 - i * 12}" fill="${n.color || THEME.dim}" font-size="10" text-anchor="end">${esc(clip(n.text, 60))}</text>`).join('');
  }

  /**
   * An animated picture.  `frameAt(u)` gives the frame at loop phase u ∈ [0,1];
   * the layer structure (kinds and point counts) must not depend on u — the
   * axes, band and labels are taken from u = 0.
   */
  function animate(frameAt, opts) {
    opts = opts || {};
    const K = opts.frames || 36;
    const dur = opts.duration || 6;
    const frames = [];
    for (let k = 0; k <= K; k++) frames.push(frameAt(k / K));
    const f0 = frames[0];
    const s = scaler(f0);
    const anim = (attr, values) =>
      `<animate attributeName="${attr}" dur="${dur}s" repeatCount="indefinite" calcMode="linear" values="${values.join(';')}"/>`;
    const body = f0.layers.map((l, i) => {
      const c = l.color || PALETTE[i % PALETTE.length];
      if (l.kind === 'bars') {
        return l.pts.map((_, j) => {
          const gs = frames.map((f) => barGeom(f.layers[i], j, s, f0));
          return `<rect x="${gs[0].x.toFixed(1)}" y="${gs[0].y.toFixed(1)}" width="${gs[0].w.toFixed(1)}" height="${gs[0].h.toFixed(1)}" fill="${(l.colors && l.colors[j]) || c}" rx="1.5">` +
            anim('y', gs.map((g) => g.y.toFixed(1))) + anim('height', gs.map((g) => g.h.toFixed(1))) + '</rect>';
        }).join('');
      }
      if (l.kind === 'dots') {
        return l.pts.map((_, j) => {
          const xs = frames.map((f) => s.sx(f.layers[i].pts[j][0]).toFixed(1));
          const ys = frames.map((f) => { const y = f.layers[i].pts[j][1]; return s.sy(finite(y) ? y : f0.yr[0]).toFixed(1); });
          const rs = frames.map((f) => (finite(f.layers[i].pts[j][1]) ? (l.r || 4) : 0));
          const still = (a) => a.every((v) => v === a[0]);
          return `<circle cx="${xs[0]}" cy="${ys[0]}" r="${rs[0]}" fill="${(l.colors && l.colors[j]) || c}">` +
            (still(xs) ? '' : anim('cx', xs)) + (still(ys) ? '' : anim('cy', ys)) +
            (still(rs) ? '' : `<animate attributeName="r" dur="${dur}s" repeatCount="indefinite" calcMode="discrete" values="${rs.join(';')}"/>`) + '</circle>';
        }).join('');
      }
      const ds = frames.map((f) => linePath(f.layers[i].pts, s));
      const sameShape = ds.every((d) => (d.match(/[ML]/g) || []).join('') === (ds[0].match(/[ML]/g) || []).join(''));
      if (!sameShape) {
        // segments appear/disappear: fall back to discrete frames
        return `<path d="${ds[0]}" fill="none" stroke="${c}" stroke-width="${l.width || 2.5}" stroke-linejoin="round">` +
          `<animate attributeName="d" dur="${dur}s" repeatCount="indefinite" calcMode="discrete" values="${ds.join(';')}"/></path>`;
      }
      return `<path d="${ds[0]}" fill="none" stroke="${c}" stroke-width="${l.width || 2.5}" stroke-linejoin="round" stroke-linecap="round"${l.dash ? ` stroke-dasharray="${l.dash}"` : ''}>` +
        anim('d', ds) + '</path>';
    }).join('');
    const progress = `<rect x="${PAD.l}" y="${H - 6}" width="0" height="3" fill="${THEME.bandEdge}" opacity="0.7">` +
      `<animate attributeName="width" dur="${dur}s" repeatCount="indefinite" values="0;${W - PAD.l - PAD.r}"/></rect>`;
    return open(f0) + axes(f0, s) + decorations(f0, s) + body + legend(f0) + notes(f0) + progress + '</svg>';
  }

  /**
   * Knowledge graph: nodes placed on a ring (or given x,y in [0,1]), edges
   * with a travelling dash so the direction of "builds on" is visible.
   */
  function graph(nodes, edges, opts) {
    opts = opts || {};
    const GW = opts.width || 900, GH = opts.height || 560;
    const pos = {};
    nodes.forEach((n, i) => {
      const a = (i / nodes.length) * Math.PI * 2 - Math.PI / 2;
      pos[n.id] = n.pos
        ? { x: 60 + n.pos[0] * (GW - 120), y: 40 + n.pos[1] * (GH - 90) }
        : n.x != null
        ? { x: 40 + n.x * (GW - 80), y: 40 + n.y * (GH - 80) }
        : { x: GW / 2 + Math.cos(a) * (GW / 2 - 110), y: GH / 2 + Math.sin(a) * (GH / 2 - 60) };
    });
    const e = edges.filter(([a, b]) => pos[a] && pos[b]).map(([a, b], i) => {
      const p = pos[a], q = pos[b];
      return `<path d="M${p.x.toFixed(1)} ${p.y.toFixed(1)} L${q.x.toFixed(1)} ${q.y.toFixed(1)}" stroke="#3b4a7a" stroke-width="1.6" fill="none" stroke-dasharray="6 6" marker-end="url(#arrow)">` +
        `<animate attributeName="stroke-dashoffset" from="24" to="0" dur="${1.2 + (i % 5) * 0.2}s" repeatCount="indefinite"/></path>`;
    }).join('');
    const nd = nodes.map((n, i) => {
      const p = pos[n.id];
      const c = n.color || PALETTE[i % PALETTE.length];
      const label = esc(n.short || n.title);
      return `<g class="node" data-id="${esc(n.id)}" tabindex="0" role="button" aria-label="${esc(n.title)}" style="cursor:pointer">` +
        `<circle cx="${p.x.toFixed(1)}" cy="${p.y.toFixed(1)}" r="11" fill="${THEME.bg}" stroke="${c}" stroke-width="3">` +
        `<animate attributeName="r" values="10;13;10" dur="${3 + (i % 4) * 0.5}s" repeatCount="indefinite"/></circle>` +
        `<text x="${p.x.toFixed(1)}" y="${(p.y + 27).toFixed(1)}" fill="${THEME.text}" font-size="12" text-anchor="middle">${label}</text></g>`;
    }).join('');
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${GW} ${GH}" font-family="ui-sans-serif,system-ui,sans-serif">` +
      `<defs><marker id="arrow" viewBox="0 0 10 10" refX="22" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="#5b6ea8"/></marker></defs>` +
      `<rect width="${GW}" height="${GH}" rx="14" fill="${THEME.bg}"/>` + e + nd + '</svg>';
  }

  /** A card-like SVG for text-only representations (so every cell can be saved as .svg). */
  function card(title, lines, opts) {
    opts = opts || {};
    const wrap = (s, n) => {
      const words = String(s).split(/\s+/); const out = []; let cur = '';
      for (const w of words) { if ((cur + ' ' + w).trim().length > n) { out.push(cur); cur = w; } else cur = (cur + ' ' + w).trim(); }
      if (cur) out.push(cur);
      return out;
    };
    const ls = [].concat(...lines.map((l) => wrap(l, opts.mono ? 58 : 66)));
    const shown = ls.slice(0, 15);
    const txt = shown.map((l, i) => `<text x="22" y="${62 + i * 15}" fill="${THEME.text}" font-size="12"${opts.mono ? ' font-family="ui-monospace,Menlo,monospace"' : ''}>${esc(l)}</text>`).join('');
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" font-family="ui-sans-serif,system-ui,sans-serif">` +
      `<rect width="${W}" height="${H}" rx="10" fill="${THEME.bg}"/>` +
      `<text x="22" y="34" fill="#ffd479" font-size="14" font-weight="600">${esc(title)}</text>` + txt + '</svg>';
  }

  return { W, H, THEME, PALETTE, esc, plot, animate, graph, card, niceTicks };
});
