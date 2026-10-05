/*
 * friction atlas — tour.js
 *
 * **The spoken tour.**  An ordered script of steps.  Each step has one or more
 * sentences to speak and, optionally, a place to show: a knowledge element, a
 * cell of its n × n grid, and a level n.  While a step is spoken, its picture is
 * on screen, so every sentence has something to look at.
 *
 *   · `STEPS`         — the script (built from the knowledge elements);
 *   · `step(i)`       — the step at a cursor, with the cursor clamped;
 *   · `next / prev`   — moving the cursor, which never leaves the script;
 *   · `targetAt(i)`   — what is on stage at step i: a step without a target of
 *     its own keeps the most recent one, so the stage is never blank;
 *   · `Speaker`       — Web Speech synthesis with captions, pause/resume, rate,
 *     voice choice, and a silent timed fallback when the browser cannot speak.
 *
 * The cursor and "never blank" properties are specified and proved in Lean:
 * `RequestProject/Site/Tour.lean`.
 */
(function (root, factory) {
  const mod = factory(root.FrictionKnowledge || (typeof require === 'function' ? require('./knowledge.js') : null));
  root.FrictionTour = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function (K) {
  'use strict';

  const DEPTH_ORDER = [2, 0, 1, 3, 4];
  const intro = [
    { say: 'Welcome to the friction atlas. It is a spoken tour of one idea: a body in motion needs some friction, but not too much, and language is one of the ways we set how much.', target: { view: 'graph' } },
    { say: 'Each node in this graph is one piece of knowledge from the examination. Arrows show which piece builds on which. You can click any node, or just listen.' },
    { say: 'Every piece can be shown in five forms: words, graph, symbols, animation and an interactive slider. It can also be told at five depths: everyday, image, mechanism, formal and limits. At knowledge level n you see n forms times n depths, so n squared representations. Going up a level adds cells and never takes any away.', target: { el: 'kinetic-friction', r: 0, c: 0, n: 1 } },
  ];

  function buildSteps() {
    const steps = intro.slice();
    K.ELEMENTS.forEach((el, i) => {
      const n = 2 + (i % 4);
      const r = Math.min(n - 1, DEPTH_ORDER[i % 5]);
      const c = n >= 4 ? 3 : 1;
      steps.push({ say: el.narration, target: { el: el.id, r, c, n } });
      if (el.status === 'interpretive') steps.push({ say: 'A caution: that picture is illustrative. It is not measured, and no theorem stands behind it.' });
      else steps.push({ say: `This one is checked in Lean, as ${el.theorem.replace('Friction.', '').replace(/_/g, ' ')}. ${el.depths[4].text}`, target: { el: el.id, r: 3, c: 2, n: 4 } });
    });
    steps.push({ say: 'Your turn. Open the submit panel, draw a representation as a formula or as an SVG animation, and press share. The link you get holds the whole submission. Anyone who opens it sees your picture and can keep it in their gallery.', target: { view: 'submit' } });
    steps.push({ say: 'That is the tour. Friction is not the enemy. The aim is friction that is matched to what it carries.' });
    return steps;
  }
  const STEPS = buildSteps();

  const clamp = (i) => Math.max(0, Math.min(STEPS.length - 1, Math.floor(Number(i) || 0)));
  const step = (i) => STEPS[clamp(i)];
  const next = (i) => clamp(clamp(i) + 1);
  const prev = (i) => clamp(clamp(i) - 1);
  function targetAt(i) {
    for (let j = clamp(i); j >= 0; j--) if (STEPS[j].target) return STEPS[j].target;
    return { view: 'graph' };
  }

  /** Split narration into speakable sentences (long utterances are cut off by some engines). */
  function sentences(text) {
    return String(text).match(/[^.!?]+[.!?]*/g).map((s) => s.trim()).filter(Boolean);
  }

  /**
   * Speaker: speaks a step sentence by sentence and calls `onSentence(text)` for
   * captions and `onDone()` at the end.  Without speech synthesis it shows the
   * captions on a reading timer instead.
   */
  class Speaker {
    constructor(opts) {
      this.synth = (typeof speechSynthesis !== 'undefined') ? speechSynthesis : null;
      this.rate = 1;
      this.voiceName = null;
      this.token = 0;
      this.timer = null;
      this.opts = opts || {};
    }
    get canSpeak() { return !!this.synth && typeof SpeechSynthesisUtterance !== 'undefined'; }
    voices() { return this.canSpeak ? this.synth.getVoices().filter((v) => /^en/i.test(v.lang)) : []; }
    stop() {
      this.token++;
      if (this.timer) { clearTimeout(this.timer); this.timer = null; }
      if (this.canSpeak) this.synth.cancel();
    }
    pause() { if (this.canSpeak) this.synth.pause(); }
    resume() { if (this.canSpeak) this.synth.resume(); }
    speak(text, onSentence, onDone) {
      this.stop();
      const my = ++this.token;
      const parts = sentences(text);
      let k = 0;
      const nextPart = () => {
        if (my !== this.token) return;
        if (k >= parts.length) { if (onDone) onDone(); return; }
        const s = parts[k++];
        if (onSentence) onSentence(s);
        if (this.canSpeak) {
          const u = new SpeechSynthesisUtterance(s);
          u.rate = this.rate;
          const v = this.voices().find((x) => x.name === this.voiceName);
          if (v) u.voice = v;
          u.onend = () => nextPart();
          u.onerror = () => { this.timer = setTimeout(nextPart, readingTime(s, this.rate)); };
          this.synth.speak(u);
        } else {
          this.timer = setTimeout(nextPart, readingTime(s, this.rate));
        }
      };
      nextPart();
    }
  }
  const readingTime = (s, rate) => Math.max(1600, (s.split(/\s+/).length / 2.6) * 1000 / (rate || 1));

  return { STEPS, step, next, prev, clamp, targetAt, sentences, Speaker, readingTime };
});
