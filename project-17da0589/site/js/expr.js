/*
 * friction atlas — expr.js
 *
 * A small, safe expression language for community formulas such as
 * `exp(-c*t)*sin(x - t)`.  Text is tokenised and parsed into a tree; nothing
 * is ever passed to `eval` or `Function`, so a formula arriving in a shared
 * link can only compute numbers.
 *
 *   number · identifier · + - * / ^ · unary - · f(args) · parentheses
 *
 * Identifiers are variables supplied by the caller (x, t, and any parameters)
 * or the constants pi, e, tau.  Functions are a fixed whitelist.
 */
(function (root, factory) {
  const mod = factory();
  root.FrictionExpr = mod;
  if (typeof module === 'object' && module.exports) module.exports = mod;
})(typeof self !== 'undefined' ? self : globalThis, function () {
  'use strict';

  const FUNCS = {
    sin: Math.sin, cos: Math.cos, tan: Math.tan, exp: Math.exp, log: Math.log,
    sqrt: Math.sqrt, abs: Math.abs, floor: Math.floor, ceil: Math.ceil,
    atan: Math.atan, tanh: Math.tanh, sign: Math.sign,
    min: Math.min, max: Math.max, pow: Math.pow,
    clamp: (v, a, b) => Math.min(Math.max(v, a), b),
    mod: (a, b) => ((a % b) + b) % b,
  };
  const CONSTS = { pi: Math.PI, e: Math.E, tau: 2 * Math.PI };
  const MAX_LEN = 400;
  const MAX_DEPTH = 64;
  const has = (o, k) => Object.prototype.hasOwnProperty.call(o, k);

  function tokenize(src) {
    if (typeof src !== 'string') throw new Error('formula must be text');
    if (src.length > MAX_LEN) throw new Error('formula is longer than ' + MAX_LEN + ' characters');
    const out = [];
    let i = 0;
    while (i < src.length) {
      const ch = src[i];
      if (/\s/.test(ch)) { i++; continue; }
      if (/[0-9.]/.test(ch)) {
        const m = /^(\d+\.?\d*|\.\d+)(e[+-]?\d+)?/i.exec(src.slice(i));
        if (!m) throw new Error('bad number at position ' + i);
        out.push({ k: 'num', v: parseFloat(m[0]) });
        i += m[0].length;
        continue;
      }
      if (/[A-Za-z_]/.test(ch)) {
        const m = /^[A-Za-z_][A-Za-z_0-9]*/.exec(src.slice(i));
        out.push({ k: 'id', v: m[0] });
        i += m[0].length;
        continue;
      }
      if ('+-*/^(),'.includes(ch)) { out.push({ k: ch }); i++; continue; }
      throw new Error('unexpected character "' + ch + '"');
    }
    out.push({ k: 'end' });
    return out;
  }

  /** Parse text into a tree.  Throws a readable Error on bad input. */
  function parse(src) {
    const toks = tokenize(src);
    let p = 0;
    let depth = 0;
    const peek = () => toks[p];
    const eat = (k) => {
      if (toks[p].k !== k) throw new Error('expected "' + k + '"');
      return toks[p++];
    };
    const enter = () => { if (++depth > MAX_DEPTH) throw new Error('formula is nested too deeply'); };
    const leave = () => { depth--; };
    function expr() {
      enter();
      let n = term();
      while (peek().k === '+' || peek().k === '-') {
        const op = toks[p++].k;
        n = { op, a: n, b: term() };
      }
      leave();
      return n;
    }
    function term() {
      let n = unary();
      while (peek().k === '*' || peek().k === '/') {
        const op = toks[p++].k;
        n = { op, a: n, b: unary() };
      }
      return n;
    }
    function unary() {
      if (peek().k === '-') { p++; enter(); const n = { op: 'neg', a: unary() }; leave(); return n; }
      if (peek().k === '+') { p++; enter(); const n = unary(); leave(); return n; }
      return power();
    }
    function power() {
      const base = atom();
      if (peek().k === '^') { p++; enter(); const n = { op: '^', a: base, b: unary() }; leave(); return n; }
      return base;
    }
    function atom() {
      const t = peek();
      if (t.k === 'num') { p++; return { num: t.v }; }
      if (t.k === '(') { p++; const n = expr(); eat(')'); return n; }
      if (t.k === 'id') {
        p++;
        if (peek().k === '(') {
          if (!has(FUNCS, t.v)) throw new Error('unknown function ' + t.v);
          p++;
          const args = [];
          if (peek().k !== ')') {
            args.push(expr());
            while (peek().k === ',') { p++; args.push(expr()); }
          }
          eat(')');
          return { fn: t.v, args };
        }
        return { id: t.v };
      }
      throw new Error('unexpected ' + (t.k === 'end' ? 'end of formula' : '"' + t.k + '"'));
    }
    const tree = expr();
    if (peek().k !== 'end') throw new Error('unexpected "' + peek().k + '"');
    return tree;
  }

  function evaluate(n, env) {
    if (n.num !== undefined) return n.num;
    if (n.id !== undefined) {
      if (env && has(env, n.id)) return env[n.id];
      if (has(CONSTS, n.id)) return CONSTS[n.id];
      throw new Error('unknown variable ' + n.id);
    }
    if (n.fn !== undefined) return FUNCS[n.fn].apply(null, n.args.map((a) => evaluate(a, env)));
    const a = evaluate(n.a, env);
    switch (n.op) {
      case 'neg': return -a;
      case '+': return a + evaluate(n.b, env);
      case '-': return a - evaluate(n.b, env);
      case '*': return a * evaluate(n.b, env);
      case '/': return a / evaluate(n.b, env);
      case '^': return Math.pow(a, evaluate(n.b, env));
    }
    throw new Error('bad node');
  }

  /** Free variables of a tree (constants excluded). */
  function variables(n, acc) {
    acc = acc || new Set();
    if (n.id !== undefined && !has(CONSTS, n.id)) acc.add(n.id);
    if (n.args) n.args.forEach((a) => variables(a, acc));
    if (n.a) variables(n.a, acc);
    if (n.b) variables(n.b, acc);
    return acc;
  }

  /** Compile to a closure `env -> number` (tree-walking; never eval). */
  function compile(src) {
    const tree = parse(src);
    const f = (env) => evaluate(tree, env);
    f.variables = [...variables(tree)];
    return f;
  }

  return { parse, evaluate, compile, variables, FUNCS: Object.keys(FUNCS), CONSTS: Object.keys(CONSTS) };
});
