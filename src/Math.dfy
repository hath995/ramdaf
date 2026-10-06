// Ramdaf: Ramda v0.1.3 "Arithmetic Functions" (ramda.js lines 1139-1249).
// JS numbers are IEEE doubles; the port uses int, and real for division
// (see README "Deviations").

module Ramdaf.Math {
  import opened Prelude

  export
    reveals add, multiply, subtract, subtractN, divide, divideBy, modulo, moduloBy,
            sum, product, lt, lte, gt, gte, max, maxWith, minWith, min
    provides Prelude

  function add(a: int, b: int): int { a + b }

  function multiply(a: int, b: int): int { a * b }

  function subtract(a: int, b: int): int { a - b }

  // `subtractN = flip(subtract)`: `subtractN(a, b) == b - a`
  function subtractN(a: int, b: int): int { b - a }

  // JS `a / 0` is +-Infinity or NaN, which `real` cannot hold.
  function divide(a: real, b: real): real
    requires b != 0.0
  { a / b }

  // `divideBy = flip(divide)`: `divideBy(a, b) == b / a`
  function divideBy(a: real, b: real): real
    requires a != 0.0
  { b / a }

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

  // `moduloBy = flip(modulo)`: `moduloBy(a, b) == b % a`
  function moduloBy(a: int, b: int): int
    requires a != 0
  { modulo(b, a) }

  // `foldl(add, 0)`
  function sum(list: seq<int>): int
  { if |list| == 0 then 0 else list[0] + sum(list[1..]) }

  // `foldl(multiply, 1)`
  function product(list: seq<int>): int
  { if |list| == 0 then 1 else list[0] * product(list[1..]) }

  function lt(a: int, b: int): bool { a < b }

  function lte(a: int, b: int): bool { a <= b }

  function gt(a: int, b: int): bool { a > b }

  function gte(a: int, b: int): bool { a >= b }

  // `Math.max.apply(null, list)`; `max([])` is -Infinity in JS, which int
  // cannot hold, so the empty list is excluded.
  function max(list: seq<int>): int
    requires |list| > 0
    ensures max(list) in list
    ensures forall x :: x in list ==> x <= max(list)
  { if |list| == 1 then list[0]
    else var m := max(list[1..]);
         assert list == [list[0]] + list[1..];
         if list[0] < m then m else list[0] }

  // `Math.min.apply(null, list)`; `min([])` is Infinity in JS.
  function min(list: seq<int>): int
    requires |list| > 0
    ensures min(list) in list
    ensures forall x :: x in list ==> min(list) <= x
  { if |list| == 1 then list[0]
    else var m := min(list[1..]);
         assert list == [list[0]] + list[1..];
         if m < list[0] then m else list[0] }

  // Ramda keeps a running maximum, replacing it only when
  // `comparator(max, list[idx]) < 0`: the first maximal element wins. The
  // recursion folds the first two elements into one, which is that loop.
  // The empty list gives null (undefined before v0.1.1), here None.
  function maxWith<T>(comparator: (T, T) -> int, list: seq<T>): Option<T>
    decreases |list|
    ensures maxWith(comparator, list).None? <==> |list| == 0
    ensures maxWith(comparator, list).Some? ==> maxWith(comparator, list).value in list
    ensures ((forall x, y | x in list && y in list :: comparator(x, y) < 0 <==> comparator(y, x) > 0) &&
             (forall x, y, z | x in list && y in list && z in list ::
                comparator(x, y) <= 0 && comparator(y, z) <= 0 ==> comparator(x, z) <= 0))
            ==> forall x | x in list :: comparator(x, maxWith(comparator, list).value) <= 0
  { if |list| == 0 then None
    else if |list| == 1 then Some(list[0])
    else var rest := [if comparator(list[0], list[1]) < 0 then list[1] else list[0]] + list[2..];
         assert forall x | x in rest :: x in list;
         assert forall x | x in list :: x == list[0] || x == list[1] || x in rest;
         maxWith(comparator, rest) }

  // As maxWith, replacing the running minimum when `comparator(min, x) > 0`.
  function minWith<T>(comparator: (T, T) -> int, list: seq<T>): Option<T>
    decreases |list|
    ensures minWith(comparator, list).None? <==> |list| == 0
    ensures minWith(comparator, list).Some? ==> minWith(comparator, list).value in list
    ensures ((forall x, y | x in list && y in list :: comparator(x, y) < 0 <==> comparator(y, x) > 0) &&
             (forall x, y, z | x in list && y in list && z in list ::
                comparator(x, y) <= 0 && comparator(y, z) <= 0 ==> comparator(x, z) <= 0))
            ==> forall x | x in list :: comparator(minWith(comparator, list).value, x) <= 0
  { if |list| == 0 then None
    else if |list| == 1 then Some(list[0])
    else var rest := [if comparator(list[0], list[1]) > 0 then list[1] else list[0]] + list[2..];
         assert forall x | x in rest :: x in list;
         assert forall x | x in list :: x == list[0] || x == list[1] || x in rest;
         minWith(comparator, rest) }
}
