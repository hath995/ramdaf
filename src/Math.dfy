// Ramdaf: Ramda v0.22.1 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Arithmetic Functions" section; from v0.9.0 on, the
// functions with `@category Math` (`inc`, `dec`, `negate`, `mean`,
// `median`). (v0.5.0 removed
// `subtractN`, `divideBy` and `moduloBy`; v0.8.0 renamed `maxWith` and
// `minWith` to `maxBy` and `minBy`.)
// JS numbers are IEEE doubles; the port uses int, and real for division and
// for the results of `mean` and `median` (see README "Deviations").
// `median` sorts with `Sort.sort`, so Math imports Sort (v0.14.0). (Math
// imported Prelude for the `Option` results of `maxBy` and `minBy` until
// v0.16.0 made them binary.)

module Ramdaf.Math {
  import Sort

  export
    reveals add, multiply, subtract, divide, modulo,
            sum, product, lt, lte, gt, gte, max, maxBy, minBy, min, mathMod, inc, dec, negate,
            mean, median
    provides Sort

  // `R.add(a, b)`: since v0.20.0 `Number(a) + Number(b)`, which converts
  // its operands (`add('1', '2')` is 3, where `a + b` concatenated, '12');
  // on ints the same sum (README "Deviations").
  function add(a: int, b: int): int { a + b }

  function multiply(a: int, b: int): int { a * b }

  // `R.subtract(a, b)`: since v0.20.0 `Number(a) - Number(b)`, as add.
  function subtract(a: int, b: int): int { a - b }

  // JS `a / 0` is +-Infinity or NaN, which `real` cannot hold.
  function divide(a: real, b: real): real
    requires b != 0.0
  { a / b }

  // JS `a % b`: the remainder of the division truncated toward zero, so it
  // takes the dividend's sign (`modulo(-5, 4) == -1`, `modulo(7, -3) == 1`).
  // Dafny's `%` is Euclidean (never negative), so the body works on absolute
  // values. `a % 0` is NaN, which int cannot hold.
  function modulo(a: int, b: int): int
    requires b != 0
    ensures exists q :: a == b * q + modulo(a, b)
    ensures -(if b < 0 then -b else b) < modulo(a, b) < (if b < 0 then -b else b)
    ensures a >= 0 ==> modulo(a, b) >= 0
    ensures a <= 0 ==> modulo(a, b) <= 0
  { var aa := if a < 0 then -a else a;
    var bb := if b < 0 then -b else b;
    var r := aa % bb;
    var res := if a < 0 then -r else r;
    var m := if (a < 0) == (b < 0) then aa / bb else -(aa / bb);
    assert aa == bb * (aa / bb) + r;
    assert a == b * m + res;
    res }

  // `if (!isInteger(m)) return NaN; if (!isInteger(p) || p < 1) return NaN;
  // return ((m % p) + p) % p;` (v0.4.2, "Fix a critical bug in R.mathMod"),
  // with JS's truncated `%` (modulo here): for p >= 1 the remainder in
  // [0, p) (`mathMod(-17, 5)` is 3). A modulus below 1 is NaN, so p must be
  // at least 1. (v0.3.0 to v0.4.1 tested the dividend instead, requiring
  // m >= 1 and p != 0: `mathMod(-17, 5)` was NaN and `mathMod(17, -5)` -3.)
  function mathMod(m: int, p: int): int
    requires p >= 1
  { modulo(modulo(m, p) + p, p) }

  // `foldl(add, 0)` (since v0.9.0 `foldl(_add, 0)`, since v0.10.0
  // `reduce(_add, 0)`). (In v0.2.0 and v0.2.1 the partially applied foldl kept
  // its accumulator between calls; v0.2.2's curry3 starts each call afresh.)
  function sum(list: seq<int>): int
  { if |list| == 0 then 0 else list[0] + sum(list[1..]) }

  // `foldl(multiply, 1)` (since v0.10.0 `reduce(_multiply, 1)`)
  function product(list: seq<int>): int
  { if |list| == 0 then 1 else list[0] * product(list[1..]) }

  function lt(a: int, b: int): bool { a < b }

  function lte(a: int, b: int): bool { a <= b }

  function gt(a: int, b: int): bool { a > b }

  function gte(a: int, b: int): bool { a >= b }

  // `R.max(a, b)` (v0.16.0, "make R.min, R.max, R.minBy, and R.maxBy binary
  // functions", 43b57125): `b > a ? b : a`, the larger of two values (the
  // first when they are equal). Until v0.15.1 `max(list)` was the largest
  // element of a list, `createMaxMin(gt, -Infinity)` (v0.7.0; a fold with
  // `Math.max` from v0.2.0 to v0.6.0), with `max([])` -Infinity, so the empty
  // list was excluded. JS compares any orderable values (`max('a', 'b')` is
  // 'b'); here ints (README "Deviations").
  function max(a: int, b: int): int { if b > a then b else a }

  // `R.min(a, b)` (v0.16.0): `b < a ? b : a`, the smaller of two values
  // (until v0.15.1 the least element of a list, `createMaxMin(lt,
  // Infinity)`, with `min([])` Infinity).
  function min(a: int, b: int): int { if b < a then b else a }

  // `R.maxBy(f, a, b)` (v0.16.0, 43b57125): `f(b) > f(a) ? b : a`, the value
  // with the larger key (a on a tie; `maxBy(n => n * n, -3, 2)` is -3). Keys
  // are ints (README "Deviations"). Until v0.15.1 `maxBy(keyFn, list)`
  // (`maxWith` until v0.8.0) was the element of a list with the greatest
  // key, the first on a tie, undefined (None) for []; in v0.15.x
  // `_createMaxMinBy` started from `list[1]` (7f7648df), so `list[0]` was
  // never considered and a one-element list, which called
  // `keyFn(undefined)`, was excluded.
  function maxBy<T>(keyFn: T -> int, a: T, b: T): T { if keyFn(b) > keyFn(a) then b else a }

  // `R.minBy(f, a, b)` (v0.16.0): `f(b) < f(a) ? b : a`, the value with the
  // smaller key (a on a tie); until v0.15.1 the element of a list with the
  // least key, as maxBy.
  function minBy<T>(keyFn: T -> int, a: T, b: T): T { if keyFn(b) < keyFn(a) then b else a }

  // `R.inc = add(1)` (v0.9.0).
  function inc(n: int): int { add(1, n) }

  // `R.dec = add(-1)` (v0.9.0).
  function dec(n: int): int { add(-1, n) }

  // `_curry1(function negate(n) { return -n; })` (v0.11.0; `R.negate =
  // multiply(-1)` in v0.9.0 and v0.10.0, the same results). JS `negate(0)` is
  // `-0`, which int does not have (README "Deviations", under `eq`).
  function negate(n: int): int { -n }

  // `R.mean(list)` (v0.14.0, `@category Math`): `sum(list) / list.length`,
  // a real here, as divide's result is (`mean([2, 7])` is 4.5). `mean([])`
  // is NaN (0 / 0), so the list must not be empty.
  function mean(list: seq<int>): real
    requires |list| > 0
  { sum(list) as real / |list| as real }

  // `R.median(list)` (v0.14.0): NaN for the empty list (excluded, as for
  // mean); otherwise a copy of the list (`_slice(list)`) sorted with
  // `function(a, b) { return a < b ? -1 : a > b ? 1 : 0; }`, and the mean of
  // its middle element (odd length) or two middle elements (even length):
  // `width = 2 - len % 2`, `idx = (len - width) / 2`, `mean(sorted.slice(idx,
  // idx + width))` (`median([7, 2, 10, 9])` is 8). JS sorts in place with
  // `Array.prototype.sort`, which is what `Sort.sort` (`_slice(list).sort`
  // since v0.14.0) is, by contract.
  function median(list: seq<int>): real
    requires |list| > 0
  { var width := 2 - |list| % 2;
    var idx := (|list| - width) / 2;
    var sorted := Sort.sort((a: int, b: int) => if a < b then -1 else if a > b then 1 else 0, list);
    mean(sorted[idx..idx + width]) }
}
