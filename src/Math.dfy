// Ramdaf: Ramda v0.12.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Arithmetic Functions" section; from v0.9.0 on, the
// functions with `@category Math` (`inc`, `dec`, `negate`). (v0.5.0 removed
// `subtractN`, `divideBy` and `moduloBy`; v0.8.0 renamed `maxWith` and
// `minWith` to `maxBy` and `minBy`.)
// JS numbers are IEEE doubles; the port uses int, and real for division
// (see README "Deviations").

module Ramdaf.Math {
  import opened Prelude

  export
    reveals add, multiply, subtract, divide, modulo,
            sum, product, lt, lte, gt, gte, max, maxBy, minBy, min, mathMod, inc, dec, negate
    provides Prelude

  function add(a: int, b: int): int { a + b }

  function multiply(a: int, b: int): int { a * b }

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

  // `createMaxMin(gt, -Infinity)` (v0.7.0): a loop that replaces the winner
  // when `+list[idx]` is strictly greater, skipping NaN and non-numbers
  // (v0.2.0 to v0.6.0 `foldl(binary(Math.max), -Infinity, list)`, before that
  // `Math.max.apply(null, list)`, the same on ints); `max([])` is -Infinity
  // in JS, which int cannot hold, so the empty list is excluded.
  function max(list: seq<int>): int
    requires |list| > 0
    ensures max(list) in list
    ensures forall x :: x in list ==> x <= max(list)
  { if |list| == 1 then list[0]
    else var m := max(list[1..]);
         assert list == [list[0]] + list[1..];
         if list[0] < m then m else list[0] }

  // `createMaxMin(lt, Infinity)` (v0.7.0; `foldl(binary(Math.min), Infinity,
  // list)` before, the same on ints); `min([])` is Infinity in JS.
  function min(list: seq<int>): int
    requires |list| > 0
    ensures min(list) in list
    ensures forall x :: x in list ==> min(list) <= x
  { if |list| == 1 then list[0]
    else var m := min(list[1..]);
         assert list == [list[0]] + list[1..];
         if m < list[0] then m else list[0] }

  // `R.maxBy(keyFn, list)` (v0.8.0 renamed `maxWith` to `maxBy` with the
  // same code, `_curry2(_createMaxMinBy(gt))`; `maxWith` took a key function
  // since v0.2.0, a comparator before; v0.7.0 made it
  // `curry2(createMaxMinWith(gt))`, the same loop): the running
  // winner is replaced only when `keyFn(list[idx]) > max`, so the FIRST
  // element with the greatest key wins. The empty list gives undefined (null
  // before v0.2.0), here None. Keys are ints (README "Deviations"). The body
  // recurses on the tail: the tail's winner beats list[0] only when its key
  // is strictly greater, which picks the same element as the loop.
  function maxBy<T>(keyFn: T -> int, list: seq<T>): Option<T>
    ensures maxBy(keyFn, list).None? <==> |list| == 0
    ensures maxBy(keyFn, list).Some? ==> maxBy(keyFn, list).value in list
    ensures maxBy(keyFn, list).Some? ==>
      forall j :: 0 <= j < |list| ==> keyFn(list[j]) <= keyFn(maxBy(keyFn, list).value)
    ensures maxBy(keyFn, list).Some? ==>
      forall j :: 0 <= j < |list| && keyFn(list[j]) == keyFn(maxBy(keyFn, list).value) &&
                  (forall i :: 0 <= i < j ==> keyFn(list[i]) < keyFn(list[j]))
                  ==> list[j] == maxBy(keyFn, list).value
  { if |list| == 0 then None
    else match maxBy(keyFn, list[1..])
      case None => Some(list[0])
      case Some(m) =>
        assert forall j :: 1 <= j < |list| ==> list[j] == list[1..][j - 1];
        if keyFn(m) > keyFn(list[0]) then Some(m) else Some(list[0]) }

  // `R.minBy` (v0.8.0, `minWith` renamed, with the same code): as maxBy,
  // replacing the running winner when `keyFn(list[idx]) < min`: the FIRST
  // element with the least key wins.
  function minBy<T>(keyFn: T -> int, list: seq<T>): Option<T>
    ensures minBy(keyFn, list).None? <==> |list| == 0
    ensures minBy(keyFn, list).Some? ==> minBy(keyFn, list).value in list
    ensures minBy(keyFn, list).Some? ==>
      forall j :: 0 <= j < |list| ==> keyFn(minBy(keyFn, list).value) <= keyFn(list[j])
    ensures minBy(keyFn, list).Some? ==>
      forall j :: 0 <= j < |list| && keyFn(list[j]) == keyFn(minBy(keyFn, list).value) &&
                  (forall i :: 0 <= i < j ==> keyFn(list[j]) < keyFn(list[i]))
                  ==> list[j] == minBy(keyFn, list).value
  { if |list| == 0 then None
    else match minBy(keyFn, list[1..])
      case None => Some(list[0])
      case Some(m) =>
        assert forall j :: 1 <= j < |list| ==> list[j] == list[1..][j - 1];
        if keyFn(m) < keyFn(list[0]) then Some(m) else Some(list[0]) }

  // `R.inc = add(1)` (v0.9.0).
  function inc(n: int): int { add(1, n) }

  // `R.dec = add(-1)` (v0.9.0).
  function dec(n: int): int { add(-1, n) }

  // `_curry1(function negate(n) { return -n; })` (v0.11.0; `R.negate =
  // multiply(-1)` in v0.9.0 and v0.10.0, the same results). JS `negate(0)` is
  // `-0`, which int does not have (README "Deviations", under `eq`).
  function negate(n: int): int { -n }
}
