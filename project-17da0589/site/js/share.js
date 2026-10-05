/*
 * friction atlas — share.js
 *
 * Community representations travel as links; there is no server.
 *
 *   · `encode(payload)` / `decode(fragment)` pack a submission into a URL
 *     fragment: JSON → UTF-8 → raw deflate (when the browser has
 *     CompressionStream) → base64url, prefixed `z` (deflated) or `u` (plain).
 *     A fragment never reaches a web server, so the link *is* the submission.
 *   · `validate(payload)` checks the shape and size of a submission and, for
 *     SVG, rejects anything that could run code or load from elsewhere
 *     (`checkSVG`).  The page additionally shows submitted SVG only through an
 *     <img> element, where browsers run no scripts at all.
 *   · `renderSubmission(payload)` turns a validated submission into SVG: a
 *     formula y = f(x, t) becomes an animated plot through the safe expression
 *     language in expr.js; pasted SVG is passed through unchanged.
 *   · the gallery keeps received and authored submissions in localStorage.
 */
(function (root, factory) {
  const req = (n, g) => root[g] || (typeof require === 'function' ? require(n) : null);
  const mod = factory(req('./expr.js', 'FrictionExpr'), req('./svgkit.js', 'FrictionSVG'), req('./knowledge.js', 'FrictionKnowledge'), req('./grid.js', 'FrictionGrid'));
  root.FrictionShare = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function (E, SVG, K, GR) {
  'use strict';

  const VERSION = 1;
  const GALLERY_KEY = 'friction.atlas.gallery.v1';
  const LIMITS = { title: 120, author: 80, note: 1200, svg: 60000, text: 2000 };

  // ------------------------------------------------------------ base64url
  function bytesToB64url(bytes) {
    let bin = '';
    for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
    const b64 = typeof btoa === 'function' ? btoa(bin) : Buffer.from(bytes).toString('base64');
    return b64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }
  function b64urlToBytes(s) {
    if (!/^[A-Za-z0-9_-]*$/.test(s)) throw new Error('link is damaged (bad characters)');
    const b64 = s.replace(/-/g, '+').replace(/_/g, '/');
    const padded = b64 + '==='.slice((b64.length + 3) % 4);
    if (typeof atob === 'function') {
      const bin = atob(padded);
      const out = new Uint8Array(bin.length);
      for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
      return out;
    }
    return new Uint8Array(Buffer.from(padded, 'base64'));
  }
  async function pipe(bytes, Stream, mode) {
    if (typeof Stream === 'undefined') return null;
    const s = new Stream(mode);
    return new Uint8Array(await new Response(new Blob([bytes]).stream().pipeThrough(s)).arrayBuffer());
  }
  const CS = () => (typeof CompressionStream !== 'undefined' ? CompressionStream : undefined);
  const DS = () => (typeof DecompressionStream !== 'undefined' ? DecompressionStream : undefined);

  /** payload → fragment text (`z…` deflated or `u…` plain). */
  async function encode(payload) {
    const raw = new TextEncoder().encode(JSON.stringify(payload));
    try {
      const z = await pipe(raw, CS(), 'deflate-raw');
      if (z && z.length < raw.length) return 'z' + bytesToB64url(z);
    } catch (e) { /* use the plain form */ }
    return 'u' + bytesToB64url(raw);
  }

  /** fragment text → payload (not yet validated). */
  async function decode(frag) {
    if (typeof frag !== 'string' || frag.length < 2) throw new Error('empty link');
    if (frag.length > 200000) throw new Error('link is too long');
    const kind = frag[0];
    let bytes = b64urlToBytes(frag.slice(1));
    if (kind === 'z') {
      const out = await pipe(bytes, DS(), 'deflate-raw');
      if (!out) throw new Error('this browser cannot open compressed links');
      bytes = out;
    } else if (kind !== 'u') throw new Error('unknown link format');
    if (bytes.length > 400000) throw new Error('link content is too large');
    return JSON.parse(new TextDecoder().decode(bytes));
  }

  // ------------------------------------------------------------ SVG safety
  const FORBIDDEN = [
    [/<\s*script/i, 'scripts'],
    [/<\s*foreignObject/i, 'foreignObject'],
    [/<\s*(iframe|object|embed|audio|video|image|use|a)\b/i, 'embedded, linked or external content'],
    [/<!\s*(DOCTYPE|ENTITY)/i, 'DOCTYPE/ENTITY declarations'],
    [/<\?/i, 'processing instructions'],
    [/\son[a-z]+\s*=/i, 'event handlers'],
    [/javascript\s*:/i, 'javascript: URLs'],
    [/(href|src)\s*=/i, 'links'],
    [/@import/i, 'CSS imports'],
    [/url\s*\(\s*['"]?\s*(?!#)/i, 'external url() references'],
    [/<\s*set\b[^>]*attributeName\s*=\s*['"]?(href|xlink:href|on)/i, 'animated links or handlers'],
    [/<\s*animate[^>]*attributeName\s*=\s*['"]?(href|xlink:href|on)/i, 'animated links or handlers'],
  ];

  /** Reject (never repair) SVG that could run code or fetch anything. */
  function checkSVG(svg) {
    if (typeof svg !== 'string') return { ok: false, reason: 'SVG must be text' };
    if (svg.length > LIMITS.svg) return { ok: false, reason: `SVG is larger than ${LIMITS.svg} characters` };
    const t = svg.trim();
    if (!/^<svg[\s>]/i.test(t) || !/<\/svg>\s*$/i.test(t)) return { ok: false, reason: 'must be a single <svg>…</svg> element' };
    for (const [re, what] of FORBIDDEN) if (re.test(t)) return { ok: false, reason: `contains ${what}, which submissions may not use` };
    return { ok: true };
  }

  // ------------------------------------------------------------ payloads
  const str = (v, max) => typeof v === 'string' && v.length <= max;
  const num = (v) => typeof v === 'number' && Number.isFinite(v);
  const pair = (v) => Array.isArray(v) && v.length === 2 && num(v[0]) && num(v[1]) && v[0] < v[1];

  /**
   * Payload shape (v = 1):
   *   { v, type: 'rep',
   *     el: '<element id>' | null,  newElement?: { title, text }   (when el is null)
   *     depth: '<depth id>', title, author?, note?,
   *     body: { kind: 'svg', svg } | { kind: 'formula', expr, xr:[a,b], yr:[a,b], T } }
   */
  function validate(p) {
    const bad = (reason) => ({ ok: false, reason });
    if (!p || typeof p !== 'object') return bad('not a submission');
    if (p.v !== VERSION) return bad('made by a different version of the atlas');
    if (p.type !== 'rep') return bad('unknown submission type');
    if (p.el != null && !K.byId[p.el]) return bad('refers to an unknown knowledge element');
    if (p.el == null) {
      const ne = p.newElement;
      if (!ne || !str(ne.title, LIMITS.title) || !ne.title.trim() || !str(ne.text || '', LIMITS.text)) return bad('a new element needs a title (and at most ' + LIMITS.text + ' characters of text)');
    }
    if (!K.DEPTHS.some((d) => d.id === p.depth)) return bad('unknown depth');
    if (!str(p.title, LIMITS.title) || !p.title.trim()) return bad('needs a title of at most ' + LIMITS.title + ' characters');
    if (p.author != null && !str(p.author, LIMITS.author)) return bad('author name is too long');
    if (p.note != null && !str(p.note, LIMITS.note)) return bad('note is too long');
    const b = p.body;
    if (!b || typeof b !== 'object') return bad('missing body');
    if (b.kind === 'svg') {
      const c = checkSVG(b.svg);
      return c.ok ? { ok: true } : bad(c.reason);
    }
    if (b.kind === 'formula') {
      if (!str(b.expr, 400)) return bad('formula missing or too long');
      if (!pair(b.xr) || !pair(b.yr)) return bad('ranges must be [low, high] with low < high');
      if (!num(b.T) || b.T <= 0 || b.T > 1000) return bad('loop length T must be between 0 and 1000');
      try {
        const f = E.compile(b.expr);
        const extra = f.variables.filter((v) => v !== 'x' && v !== 't');
        if (extra.length) return bad('formula may only use x and t (found ' + extra.join(', ') + ')');
      } catch (e) { return bad('formula: ' + e.message); }
      return { ok: true };
    }
    return bad('body must be svg or formula');
  }

  /** Render a validated submission to SVG text. */
  function renderSubmission(p) {
    const b = p.body;
    if (b.kind === 'svg') return b.svg.trim();
    const f = E.compile(b.expr);
    const xs = Array.from({ length: 161 }, (_, i) => b.xr[0] + (b.xr[1] - b.xr[0]) * i / 160);
    const at = (t) => xs.map((x) => { let y; try { y = f({ x, t }); } catch (e) { y = NaN; } return [x, y]; });
    const frame = (u) => ({
      title: p.title, xr: b.xr, yr: b.yr, xlabel: 'x', ylabel: 'y = ' + b.expr.slice(0, 60),
      layers: [{ kind: 'line', pts: at((u == null ? 0 : u) * b.T), color: '#ffd479' }],
      notes: [{ text: p.author ? 'by ' + p.author : 'community submission' }],
    });
    return SVG.animate(frame, { frames: 40, duration: Math.min(20, Math.max(2, b.T)) });
  }

  /** Full shareable URL for a payload, relative to a base page URL. */
  async function linkFor(payload, base) {
    const clean = String(base || '').split('#')[0];
    return clean + '#share=' + (await encode(payload));
  }

  // ------------------------------------------------------------ addresses
  /** '#at=el/depth/form&n=3' ⇄ { el, r, c, n } */
  function parseHash(hash) {
    const h = String(hash || '').replace(/^#/, '');
    const out = {};
    for (const part of h.split('&')) {
      const i = part.indexOf('=');
      if (i < 0) continue;
      out[decodeURIComponent(part.slice(0, i))] = part.slice(i + 1);
    }
    const res = {};
    if (out.share) res.share = out.share;
    if (out.tour != null) res.tour = Math.max(0, parseInt(out.tour, 10) || 0);
    if (out.n) res.n = GR.clampLevel(parseInt(out.n, 10));
    if (out.at) {
      const [el, depth, form] = decodeURIComponent(out.at).split('/');
      const r = K.DEPTHS.findIndex((d) => d.id === depth);
      const c = GR.FORMS.findIndex((f) => f.id === form);
      if (K.byId[el]) res.at = { el, r: r < 0 ? null : r, c: c < 0 ? null : c };
    }
    return res;
  }
  function addressHash(el, r, c, n) {
    let h = '#at=' + encodeURIComponent(el + (r != null ? '/' + K.DEPTHS[r].id + (c != null ? '/' + GR.FORMS[c].id : '') : ''));
    if (n) h += '&n=' + n;
    return h;
  }

  // ------------------------------------------------------------ gallery
  function storage() {
    try { return typeof localStorage !== 'undefined' ? localStorage : null; } catch (e) { return null; }
  }
  function loadGallery() {
    const s = storage();
    if (!s) return [];
    try {
      const arr = JSON.parse(s.getItem(GALLERY_KEY) || '[]');
      return Array.isArray(arr) ? arr.filter((it) => it && validate(it.payload).ok) : [];
    } catch (e) { return []; }
  }
  function saveGallery(items) {
    const s = storage();
    if (s) s.setItem(GALLERY_KEY, JSON.stringify(items));
  }
  const keyOf = (p) => JSON.stringify(p);
  function addToGallery(payload, origin) {
    const items = loadGallery();
    if (!items.some((it) => keyOf(it.payload) === keyOf(payload))) {
      items.unshift({ payload, origin: origin || 'authored', added: new Date().toISOString() });
      saveGallery(items);
    }
    return items;
  }
  function removeFromGallery(i) {
    const items = loadGallery();
    items.splice(i, 1);
    saveGallery(items);
    return items;
  }

  return {
    VERSION, LIMITS, encode, decode, checkSVG, validate, renderSubmission, linkFor,
    parseHash, addressHash, loadGallery, addToGallery, removeFromGallery, saveGallery,
    _b64: { bytesToB64url, b64urlToBytes },
  };
});
