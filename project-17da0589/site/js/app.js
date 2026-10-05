/*
 * friction atlas — app.js
 *
 * The page.  All pictures come from grid.js / svgkit.js as SVG strings.
 * Built-in pictures are drawn inline or as images; community submissions are
 * shown only as <img src="data:image/svg+xml…">, where browsers run no scripts
 * and fetch nothing.  All user text is inserted with textContent.
 */
(function () {
  'use strict';
  const SVG = window.FrictionSVG, K = window.FrictionKnowledge, GR = window.FrictionGrid;
  const S = window.FrictionShare, T = window.FrictionTour;
  const $ = (id) => document.getElementById(id);
  const h = (tag, attrs, ...kids) => {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) {
      if (k === 'class') e.className = v;
      else if (k === 'text') e.textContent = v;
      else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
      else e.setAttribute(k, v);
    }
    for (const kid of kids) if (kid != null) e.append(kid);
    return e;
  };
  const dataURL = (svg) => 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
  const img = (svg, alt) => h('img', { src: dataURL(svg), alt: alt || '', loading: 'lazy', decoding: 'async' });

  const state = { el: K.ELEMENTS[0].id, n: 2, focus: null, tourI: 0, touring: false, received: null, interactiveTimer: null };
  const cache = new Map();
  const rep = (el, r, c) => {
    const key = el.id + '|' + r + '|' + c;
    if (!cache.has(key)) cache.set(key, GR.render(el, r, c));
    return cache.get(key);
  };
  const speaker = new T.Speaker();

  // ------------------------------------------------------------ helpers
  async function copy(text, btn) {
    try { await navigator.clipboard.writeText(text); flash(btn, 'copied'); }
    catch (e) { window.prompt('Copy this link:', text); }
  }
  function flash(btn, msg) {
    if (!btn) return;
    const old = btn.textContent;
    btn.textContent = msg;
    setTimeout(() => { btn.textContent = old; }, 1200);
  }
  function download(name, text, type) {
    const a = h('a', { href: URL.createObjectURL(new Blob([text], { type })), download: name });
    document.body.append(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 2000);
  }
  const pageBase = () => location.href.split('#')[0];
  const speakable = (s) => String(s)
    .replace(/→/g, ' gives ').replace(/⇒/g, ' implies ').replace(/⇔|↔/g, ' if and only if ')
    .replace(/≤/g, ' at most ').replace(/≥/g, ' at least ').replace(/≠/g, ' not equal to ')
    .replace(/μ/g, 'mu').replace(/ω/g, 'omega').replace(/Γ/g, 'gamma').replace(/²/g, ' squared').replace(/₀/g, ' nought')
    .replace(/∧/g, ' and ').replace(/∀/g, 'for all ').replace(/∃/g, 'there is ').replace(/∣/g, ' divides ').replace(/·/g, ' times ');

  function showCaption(stepLabel, text) {
    $('caption').hidden = false;
    $('captionStep').textContent = stepLabel || '';
    $('captionText').textContent = text;
  }
  function hideCaption() { $('caption').hidden = true; }

  // ------------------------------------------------------------ graph
  function renderGraph() {
    const nodes = K.ELEMENTS.map((e) => ({ id: e.id, title: e.title, short: e.short, pos: e.pos, color: e.status === 'proved' ? '#9cff8f' : '#ff8fb1' }));
    $('graph').innerHTML = SVG.graph(nodes, K.EDGES); // our own markup; all labels are escaped by svgkit
    for (const g of $('graph').querySelectorAll('.node')) {
      const go = () => { stopTour(); selectElement(g.getAttribute('data-id')); document.getElementById('element').scrollIntoView({ behavior: 'smooth', block: 'start' }); };
      g.addEventListener('click', go);
      g.addEventListener('keydown', (ev) => { if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); go(); } });
    }
    markGraph();
  }
  function markGraph() {
    for (const g of $('graph').querySelectorAll('.node')) g.classList.toggle('active', g.getAttribute('data-id') === state.el);
  }

  // ------------------------------------------------------------ element + n × n grid
  function setLevel(n, fromUser) {
    const old = state.n;
    state.n = GR.clampLevel(n);
    $('level').value = state.n;
    $('levelOut').textContent = `n = ${state.n} · n² = ${state.n * state.n} representation${state.n > 1 ? 's' : ''}`;
    if (state.focus && (state.focus.r >= state.n || state.focus.c >= state.n)) closeFocus();
    renderElement(state.n > old ? old : null);
    if (fromUser) updateHash();
  }

  function selectElement(id, keepFocus) {
    if (!K.byId[id]) return;
    if (state.el !== id && !keepFocus) closeFocus();
    state.el = id;
    markGraph();
    renderElement(null);
    renderCommunity();
  }

  function renderElement(prevLevel) {
    const el = K.byId[state.el];
    $('elTitle').textContent = el.title;
    const meta = $('elMeta');
    meta.textContent = '';
    meta.append(h('span', { class: 'badge ' + el.status, text: el.status }));
    if (el.theorem) meta.append(h('code', { text: el.theorem }), document.createTextNode(' in ' + el.file));
    else meta.append(document.createTextNode('illustrative model · no theorem · see ' + el.file));
    if (el.builds.length) {
      meta.append(document.createTextNode(' · builds on '));
      el.builds.forEach((b, i) => {
        if (i) meta.append(document.createTextNode(', '));
        meta.append(h('a', { href: S.addressHash(b, null, null, state.n), text: K.byId[b].short, onclick: (ev) => { ev.preventDefault(); selectElement(b); } }));
      });
    }

    const n = state.n;
    const grid = $('grid');
    grid.textContent = '';
    grid.style.gridTemplateColumns = `90px repeat(${n}, minmax(0, 1fr))`;
    grid.append(h('div', { class: 'hdr' }));
    for (let c = 0; c < n; c++) grid.append(h('div', { class: 'hdr' }, h('b', { text: GR.FORMS[c].icon + ' ' + GR.FORMS[c].name })));
    const fresh = prevLevel ? new Set(GR.newCells(prevLevel).map((x) => x.r + ',' + x.c)) : new Set();
    for (let r = 0; r < n; r++) {
      grid.append(h('div', { class: 'rowhdr' }, h('b', { text: K.DEPTHS[r].name }), document.createTextNode(K.DEPTHS[r].blurb)));
      for (let c = 0; c < n; c++) {
        const R = rep(el, r, c);
        const svg = R.kind === 'svg' ? R.svg : GR.interactiveSVG(el, r, R.p[R.param.key], null);
        const cell = h('div', {
          class: 'cell' + (fresh.has(r + ',' + c) ? ' new' : ''), role: 'gridcell', tabindex: '0',
          'data-r': r, 'data-c': c, 'aria-label': R.caption,
          onclick: () => { stopTour(); openFocus(r, c); },
          onkeydown: (ev) => { if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); stopTour(); openFocus(r, c); } },
        }, img(svg, R.caption), R.kind === 'interactive' ? h('span', { class: 'tagline', text: 'open to drag' }) : null);
        grid.append(cell);
      }
    }
    if (state.focus) openFocus(state.focus.r, state.focus.c, true);
  }

  function highlightCell(r, c) {
    for (const x of $('grid').querySelectorAll('.cell')) x.classList.toggle('tourfocus', +x.dataset.r === r && +x.dataset.c === c);
  }

  // ------------------------------------------------------------ focus view
  function openFocus(r, c, quiet) {
    const el = K.byId[state.el];
    if (r >= state.n || c >= state.n) return;
    state.focus = { r, c };
    clearInterval(state.interactiveTimer);
    const R = rep(el, r, c);
    $('focus').hidden = false;
    $('focusTitle').textContent = R.caption;
    const body = $('focusBody');
    body.textContent = '';
    if (R.kind === 'svg') {
      body.append(img(R.svg, R.caption));
      state.focusSVG = R.svg;
    } else {
      const holder = h('div');
      const prm = R.param;
      const val = h('output', { text: (+R.p[prm.key]).toFixed(2) });
      const slider = h('input', { type: 'range', min: prm.min, max: prm.max, step: prm.step, value: R.p[prm.key], 'aria-label': prm.label });
      const draw = () => {
        state.focusSVG = GR.interactiveSVG(el, r, +slider.value, null);
        holder.innerHTML = state.focusSVG; // generated by svgkit from numbers and escaped labels
        val.textContent = (+slider.value).toFixed(2);
      };
      slider.addEventListener('input', draw);
      let dir = 1;
      const play = h('button', {
        type: 'button', text: '▶ sweep',
        onclick: () => {
          if (state.interactiveTimer) { clearInterval(state.interactiveTimer); state.interactiveTimer = null; play.textContent = '▶ sweep'; return; }
          play.textContent = '⏸ sweep';
          state.interactiveTimer = setInterval(() => {
            let v = +slider.value + dir * (prm.max - prm.min) / 80;
            if (v >= prm.max || v <= prm.min) { dir = -dir; v = Math.min(prm.max, Math.max(prm.min, v)); }
            slider.value = v; draw();
          }, 60);
        },
      });
      body.append(holder, h('div', { class: 'slider' }, h('span', { text: prm.label }), slider, val, play));
      draw();
    }
    const d = el.depths[r];
    $('focusText').textContent = `${K.DEPTHS[r].name}: ${d.text}  —  ${d.formula}`;
    highlightCell(r, c);
    if (!quiet) { updateHash(); $('focus').scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
  }
  function closeFocus() {
    state.focus = null;
    clearInterval(state.interactiveTimer); state.interactiveTimer = null;
    $('focus').hidden = true;
    highlightCell(-1, -1);
    updateHash();
  }

  // ------------------------------------------------------------ community
  function communityCard(item, idx, onChange) {
    const p = item.payload;
    const el = p.el ? K.byId[p.el] : null;
    const depth = K.DEPTHS.find((d) => d.id === p.depth);
    let svg;
    try { svg = S.renderSubmission(p); } catch (e) { svg = SVG.card('could not render', [e.message]); }
    const shareBtn = h('button', { type: 'button', text: '🔗 share' });
    shareBtn.addEventListener('click', async () => copy(await S.linkFor(p, pageBase()), shareBtn));
    return h('div', { class: 'card' },
      img(svg, p.title),
      h('p', { class: 't', text: p.title }),
      h('p', { class: 'm', text: `${el ? el.short : 'new: ' + p.newElement.title} · ${depth ? depth.name : ''}${p.author ? ' · by ' + p.author : ''} · ${item.origin}` }),
      p.note ? h('p', { class: 'm', text: p.note }) : null,
      h('div', { class: 'b' }, shareBtn,
        h('button', { type: 'button', text: '⤓ .svg', onclick: () => download(slug(p.title) + '.svg', svg, 'image/svg+xml') }),
        h('button', { type: 'button', text: '✎ remix', onclick: () => openSubmit(p) }),
        idx != null ? h('button', { type: 'button', text: '✕', title: 'remove from my gallery', onclick: () => { S.removeFromGallery(idx); onChange(); } }) : null));
  }
  const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 60) || 'representation';

  function renderCommunity() {
    const list = $('community');
    list.textContent = '';
    const items = S.loadGallery();
    $('galleryCount').textContent = items.length;
    const mine = items.map((it, i) => [it, i]).filter(([it]) => it.payload.el === state.el);
    if (!mine.length) list.append(h('p', { class: 'empty', text: 'None yet for this element. Use “＋ submit” to draw one; open a shared link to receive one.' }));
    for (const [it, i] of mine) list.append(communityCard(it, i, renderCommunity));
  }

  function openGallery() {
    const list = $('galleryList');
    const draw = () => {
      list.textContent = '';
      const items = S.loadGallery();
      $('galleryCount').textContent = items.length;
      if (!items.length) list.append(h('p', { class: 'empty', text: 'Your gallery is empty.' }));
      items.forEach((it, i) => list.append(communityCard(it, i, () => { draw(); renderCommunity(); })));
    };
    draw();
    $('galleryDlg').showModal();
  }

  // ------------------------------------------------------------ submit
  function fillSelects() {
    const sEl = $('sEl');
    for (const e of K.ELEMENTS) sEl.append(h('option', { value: e.id, text: e.title }));
    sEl.append(h('option', { value: '__new', text: '— a new knowledge element —' }));
    for (const d of K.DEPTHS) $('sDepth').append(h('option', { value: d.id, text: d.name + ' — ' + d.blurb }));
    $('sSvgText').value = EXAMPLE_SVG;
  }
  const EXAMPLE_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 300">
  <rect width="480" height="300" rx="10" fill="#070b18"/>
  <line x1="40" y1="220" x2="440" y2="220" stroke="#6b7aa6" stroke-width="3"/>
  <rect x="60" y="180" width="60" height="40" rx="6" fill="#7ad7ff">
    <animate attributeName="x" values="60;330;330;60" keyTimes="0;0.55;0.8;1" dur="4s" repeatCount="indefinite"/>
  </rect>
  <text x="40" y="40" fill="#ffd479" font-size="16" font-family="sans-serif">a block sliding to a stop</text>
</svg>`;

  function openSubmit(from) {
    $('sLinkBox').hidden = true;
    $('sError').textContent = '';
    if (from) {
      $('sEl').value = from.el || '__new';
      $('sDepth').value = from.depth;
      $('sTitle').value = from.title && from.title.startsWith('Remix') ? from.title : 'Remix of ' + (from.title || '');
      $('sAuthor').value = '';
      $('sNote').value = from.note || '';
      if (from.newElement) { $('sNewTitle').value = from.newElement.title; $('sNewText').value = from.newElement.text || ''; }
      const kind = from.body ? from.body.kind : 'formula';
      document.querySelector(`input[name=sKind][value=${kind}]`).checked = true;
      if (from.body && kind === 'formula') {
        $('sExpr').value = from.body.expr; $('sX0').value = from.body.xr[0]; $('sX1').value = from.body.xr[1];
        $('sY0').value = from.body.yr[0]; $('sY1').value = from.body.yr[1]; $('sT').value = from.body.T;
      } else if (from.body) $('sSvgText').value = from.body.svg;
    } else {
      $('sEl').value = state.el;
      $('sDepth').value = K.DEPTHS[state.focus ? state.focus.r : 0].id;
    }
    syncSubmitForm();
    previewSubmission();
    $('submitDlg').showModal();
  }
  function syncSubmitForm() {
    const kind = document.querySelector('input[name=sKind]:checked').value;
    $('sFormula').hidden = kind !== 'formula';
    $('sSvg').hidden = kind !== 'svg';
    $('sNewEl').hidden = $('sEl').value !== '__new';
  }
  function gatherPayload() {
    const kind = document.querySelector('input[name=sKind]:checked').value;
    const isNew = $('sEl').value === '__new';
    const p = { v: S.VERSION, type: 'rep', el: isNew ? null : $('sEl').value, depth: $('sDepth').value, title: $('sTitle').value.trim() };
    if (isNew) p.newElement = { title: $('sNewTitle').value.trim(), text: $('sNewText').value.trim() };
    if ($('sAuthor').value.trim()) p.author = $('sAuthor').value.trim();
    if ($('sNote').value.trim()) p.note = $('sNote').value.trim();
    p.body = kind === 'formula'
      ? { kind, expr: $('sExpr').value.trim(), xr: [+$('sX0').value, +$('sX1').value], yr: [+$('sY0').value, +$('sY1').value], T: +$('sT').value }
      : { kind, svg: $('sSvgText').value.trim() };
    return p;
  }
  function previewSubmission() {
    const p = gatherPayload();
    if (!p.title) p.title = '(untitled)';
    const v = S.validate(p);
    $('sPreview').textContent = '';
    if (!v.ok) { $('sError').textContent = v.reason; return null; }
    $('sError').textContent = '';
    $('sPreview').append(img(S.renderSubmission(p), p.title));
    return p;
  }
  async function shareSubmission() {
    const p = gatherPayload();
    const v = S.validate(p);
    if (!v.ok) { $('sError').textContent = v.reason; return; }
    previewSubmission();
    const link = await S.linkFor(p, pageBase());
    $('sLink').value = link;
    $('sOpen').href = link;
    $('sLinkBox').hidden = false;
    S.addToGallery(p, 'authored');
    renderCommunity();
    if (location.protocol === 'file:') $('sError').textContent = 'Note: this page is opened from a file, so the link points to a file on this computer. Put the site folder on any web host to get links others can open.';
    else if (link.length > 8000) $('sError').textContent = 'The link works but is long (' + link.length + ' characters); some chat apps shorten or cut long links. A simpler SVG gives a shorter link.';
  }

  // ------------------------------------------------------------ received links
  async function receive(frag) {
    $('rError').textContent = '';
    $('rPreview').textContent = '';
    $('rNote').textContent = '';
    $('rMeta').textContent = '';
    state.received = null;
    let p;
    try { p = await S.decode(frag); } catch (e) { $('rError').textContent = 'This link could not be opened: ' + e.message; $('receivedDlg').showModal(); return; }
    const v = S.validate(p);
    if (!v.ok) { $('rError').textContent = 'This link was not accepted: ' + v.reason; $('receivedDlg').showModal(); return; }
    state.received = p;
    const el = p.el ? K.byId[p.el] : null;
    $('rMeta').textContent = `“${p.title}”${p.author ? ' by ' + p.author : ''} · ${el ? el.title : 'proposed new element: ' + p.newElement.title} · ${K.DEPTHS.find((d) => d.id === p.depth).name}`;
    $('rPreview').append(img(S.renderSubmission(p), p.title));
    $('rNote').textContent = [p.newElement && p.newElement.text, p.note].filter(Boolean).join(' — ');
    $('rGo').hidden = !el;
    $('receivedDlg').showModal();
  }

  // ------------------------------------------------------------ tour
  function tourGo(i) {
    state.tourI = T.clamp(i);
    const st = T.step(state.tourI);
    const tg = T.targetAt(state.tourI);
    applyTarget(tg);
    const label = `${state.tourI + 1}/${T.STEPS.length}`;
    speaker.speak(st.say, (s) => showCaption(label, s), () => {
      if (!state.touring) return;
      if (state.tourI >= T.STEPS.length - 1) { state.touring = false; $('tourPlay').textContent = '▶ tour'; return; }
      tourGo(T.next(state.tourI));
    });
  }
  function applyTarget(tg) {
    if (tg.view === 'graph') { $('graph').scrollIntoView({ behavior: 'smooth', block: 'nearest' }); return; }
    if (tg.view === 'submit') { $('openSubmit').classList.add('tourfocus'); setTimeout(() => $('openSubmit').classList.remove('tourfocus'), 6000); return; }
    if (tg.el) {
      if (tg.n && tg.n !== state.n) setLevel(tg.n);
      if (tg.el !== state.el) selectElement(tg.el);
      highlightCell(tg.r, tg.c);
      const cell = $('grid').querySelector(`.cell[data-r="${tg.r}"][data-c="${tg.c}"]`);
      if (cell) cell.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }
  function startTour() {
    if (state.touring) { speaker.resume(); return; }
    state.touring = true;
    $('tourPlay').textContent = '▶ playing';
    tourGo(state.tourI);
  }
  function stopTour() {
    if (!state.touring) return;
    state.touring = false;
    speaker.stop();
    $('tourPlay').textContent = '▶ tour';
    hideCaption();
  }
  function populateVoices() {
    const sel = $('tourVoice');
    const cur = sel.value;
    sel.textContent = '';
    sel.append(h('option', { value: '', text: speaker.canSpeak ? 'default voice' : 'no speech: captions only' }));
    for (const v of speaker.voices()) sel.append(h('option', { value: v.name, text: `${v.name} (${v.lang})` }));
    sel.value = cur;
  }

  // ------------------------------------------------------------ links
  let applyingHash = false;
  function updateHash() {
    if (applyingHash) return;
    const f = state.focus;
    const hash = S.addressHash(state.el, f ? f.r : null, f ? f.c : null, state.n);
    if (location.hash !== hash) history.replaceState(null, '', hash);
  }
  function applyHash() {
    const hs = S.parseHash(location.hash);
    applyingHash = true;
    try {
      if (hs.n) setLevel(hs.n);
      if (hs.at) {
        selectElement(hs.at.el);
        if (hs.at.r != null && hs.at.c != null) {
          if (hs.at.r >= state.n || hs.at.c >= state.n) setLevel(Math.max(hs.at.r, hs.at.c) + 1);
          openFocus(hs.at.r, hs.at.c, true);
        }
      }
      if (hs.tour != null) {
        state.tourI = T.clamp(hs.tour);
        applyTarget(T.targetAt(state.tourI));
        showCaption(`${state.tourI + 1}/${T.STEPS.length}`, 'Press ▶ tour to hear this step: ' + T.step(state.tourI).say);
      }
    } finally { applyingHash = false; }
    if (hs.share) receive(hs.share);
  }

  // ------------------------------------------------------------ wiring
  function wire() {
    $('level').addEventListener('input', (e) => setLevel(+e.target.value, true));
    $('tourPlay').addEventListener('click', startTour);
    $('tourPause').addEventListener('click', () => speaker.pause());
    $('tourStop').addEventListener('click', stopTour);
    $('tourNext').addEventListener('click', () => { state.touring = true; $('tourPlay').textContent = '▶ playing'; tourGo(T.next(state.tourI)); });
    $('tourPrev').addEventListener('click', () => { state.touring = true; $('tourPlay').textContent = '▶ playing'; tourGo(T.prev(state.tourI)); });
    $('tourRate').addEventListener('input', (e) => { speaker.rate = +e.target.value; });
    $('tourVoice').addEventListener('change', (e) => { speaker.voiceName = e.target.value || null; });
    if (speaker.canSpeak && 'onvoiceschanged' in speechSynthesis) speechSynthesis.addEventListener('voiceschanged', populateVoices);
    populateVoices();

    $('elSpeak').addEventListener('click', () => {
      stopTour();
      const el = K.byId[state.el];
      speaker.speak(el.narration, (s) => showCaption(el.short, s), () => setTimeout(hideCaption, 1500));
    });
    $('elLink').addEventListener('click', (e) => copy(pageBase() + S.addressHash(state.el, null, null, state.n), e.currentTarget));
    $('focusClose').addEventListener('click', closeFocus);
    $('focusSpeak').addEventListener('click', () => {
      stopTour();
      const el = K.byId[state.el], f = state.focus;
      const d = el.depths[f.r];
      speaker.speak(d.text + ' ' + speakable(d.formula) + '.', (s) => showCaption(K.DEPTHS[f.r].name, s), () => setTimeout(hideCaption, 1500));
    });
    $('focusLink').addEventListener('click', (e) => copy(pageBase() + S.addressHash(state.el, state.focus.r, state.focus.c, state.n), e.currentTarget));
    $('focusSave').addEventListener('click', () => {
      const f = state.focus;
      download(`${state.el}-${K.DEPTHS[f.r].id}-${GR.FORMS[f.c].id}.svg`, state.focusSVG, 'image/svg+xml');
    });
    $('focusRemix').addEventListener('click', () => {
      const el = K.byId[state.el], f = state.focus;
      openSubmit({ el: el.id, depth: K.DEPTHS[f.r].id, title: `Remix of ${el.short} · ${K.DEPTHS[f.r].name} · ${GR.FORMS[f.c].name}` });
    });

    $('openSubmit').addEventListener('click', () => openSubmit());
    $('openGallery').addEventListener('click', openGallery);
    $('openHelp').addEventListener('click', () => $('helpDlg').showModal());
    for (const r of document.querySelectorAll('input[name=sKind]')) r.addEventListener('change', () => { syncSubmitForm(); previewSubmission(); });
    $('sEl').addEventListener('change', syncSubmitForm);
    $('sPreviewBtn').addEventListener('click', previewSubmission);
    $('sShare').addEventListener('click', shareSubmission);
    $('sCopy').addEventListener('click', (e) => copy($('sLink').value, e.currentTarget));
    for (const id of ['sExpr', 'sX0', 'sX1', 'sY0', 'sY1', 'sT']) $(id).addEventListener('change', previewSubmission);

    $('rKeep').addEventListener('click', () => {
      if (state.received) { S.addToGallery(state.received, 'received'); renderCommunity(); flash($('rKeep'), 'kept ✓'); }
    });
    $('rGo').addEventListener('click', () => {
      if (state.received && state.received.el) { selectElement(state.received.el); $('receivedDlg').close(); }
    });
    $('receivedDlg').addEventListener('close', () => { if (/share=/.test(location.hash)) updateHash(); });

    $('gExport').addEventListener('click', () => download('friction-atlas-gallery.json', JSON.stringify(S.loadGallery(), null, 2), 'application/json'));
    $('gImport').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const arr = JSON.parse(await file.text());
        let n = 0;
        for (const it of Array.isArray(arr) ? arr : []) if (it && S.validate(it.payload).ok) { S.addToGallery(it.payload, 'imported'); n++; }
        openGallery(); renderCommunity();
        alert(`Imported ${n} item(s).`);
      } catch (err) { alert('That file could not be read: ' + err.message); }
      e.target.value = '';
    });
    window.addEventListener('hashchange', applyHash);
  }

  // ------------------------------------------------------------ start
  fillSelects();
  wire();
  renderGraph();
  setLevel(2);
  renderCommunity();
  applyHash();
})();
