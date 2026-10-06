// Ramdaf: Ramda v0.1.5 "Core Functions" (ramda.js lines 250-322), `clone` and
// `cloneDeep` (lines 241-249) and `size`.

module Ramdaf.Core {
  export
    reveals clone, cloneDeep, isEmpty, prepend, cons, head, car, first, last, tail, cdr,
            append, push, merge, concat, identity, I, repeatN, size

  // `clone(list)` is `list.concat()`, a shallow copy. Dafny sequences are
  // values, so the copy is the list itself.
  function clone<T>(list: seq<T>): seq<T> { list }

  // `JSON.parse(JSON.stringify(obj))`, a deep copy. Dafny values are
  // immutable, so the copy is the value itself. JSON cannot carry a function
  // (`cloneDeep(f)` throws a SyntaxError, a function inside an object is
  // dropped), so T is limited to types with equality, which excludes every
  // type that contains a function. A property that is undefined (None) is
  // dropped by JSON but kept here (README "Deviations").
  function cloneDeep<T(==)>(obj: T): T { obj }

  function isEmpty<T>(list: seq<T>): bool { |list| == 0 }

  function prepend<T>(el: T, list: seq<T>): seq<T> { [el] + list }
  function cons<T>(el: T, list: seq<T>): seq<T> { prepend(el, list) }

  // `arr[0]`: `head([])` is undefined (not an element), so the empty list is
  // excluded.
  function head<T>(list: seq<T>): T
    requires |list| > 0
  { list[0] }
  function car<T>(list: seq<T>): T
    requires |list| > 0
  { head(list) }
  function first<T>(list: seq<T>): T
    requires |list| > 0
  { head(list) }

  // `arr[arr.length - 1]`: `last([])` is undefined, so the empty list is
  // excluded.
  function last<T>(list: seq<T>): T
    requires |list| > 0
  { list[|list| - 1] }

  // `(arr.length > 1) ? slice(arr, 1) : []`
  function tail<T>(list: seq<T>): seq<T>
    ensures |list| > 0 ==> tail(list) == list[1..]
  { if |list| <= 1 then [] else list[1..] }
  function cdr<T>(list: seq<T>): seq<T> { tail(list) }

  function append<T>(el: T, list: seq<T>): seq<T> { list + [el] }
  function push<T>(el: T, list: seq<T>): seq<T> { append(el, list) }

  function merge<T>(list1: seq<T>, list2: seq<T>): seq<T> { list1 + list2 }
  function concat<T>(list1: seq<T>, list2: seq<T>): seq<T> { merge(list1, list2) }

  function identity<T>(x: T): T { x }
  function I<T>(x: T): T { identity(x) }

  // `var arr = [], i = -1; while (++i < n) { arr[i] = value; }`: n copies of
  // value, none when n <= 0 (v0.1.3 replaced the generator-based
  // `repeat.nTimes`).
  function repeatN<T>(value: T, n: int): seq<T>
    ensures |repeatN(value, n)| == if n <= 0 then 0 else n
    ensures forall i :: 0 <= i < |repeatN(value, n)| ==> repeatN(value, n)[i] == value
  { if n <= 0 then [] else seq(n, _ => value) }

  function size<T>(list: seq<T>): nat { |list| }
}
