// Ramdaf: Ramda v0.1.2 "Core Functions" (ramda.js lines 236-293), `clone` and
// `cloneDeep` (lines 226-235), `repeat.nTimes` (Generators, line 411) and
// `size`.

module Ramdaf.Core {
  export
    reveals clone, cloneDeep, isEmpty, prepend, cons, head, car, tail, cdr,
            append, push, merge, concat, identity, I, repeatNTimes, size

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

  // `repeat.nTimes(value, n)` is `take(n, repeat(value))`, n copies of value
  // (`repeat` itself is an infinite generator, README "Not portable"). JS
  // recurses until the stack overflows for a negative n, so n is a nat.
  function repeatNTimes<T>(value: T, n: nat): seq<T>
    ensures |repeatNTimes(value, n)| == n
    ensures forall i :: 0 <= i < n ==> repeatNTimes(value, n)[i] == value
  { seq(n, _ => value) }

  function size<T>(list: seq<T>): nat { |list| }
}
