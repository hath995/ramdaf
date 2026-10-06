// Ramdaf: Ramda v0.1.0 "Core Functions" (ramda.js lines 219-277) plus `size`.

module Ramdaf.Core {
  export
    reveals clone, isEmpty, prepend, cons, head, car, tail, cdr,
            append, push, merge, concat, identity, I, size

  // `clone(list)` is `list.concat()`, a shallow copy. Dafny sequences are
  // values, so the copy is the list itself.
  function clone<T>(list: seq<T>): seq<T> { list }

  function isEmpty<T>(list: seq<T>): bool { |list| == 0 }

  function prepend<T>(el: T, list: seq<T>): seq<T> { [el] + list }
  function cons<T>(el: T, list: seq<T>): seq<T> { prepend(el, list) }

  // Ramda v0.1.0 returns the empty list itself for `head([])` (not an element);
  // that value has no counterpart in T, so the empty list is excluded.
  function head<T>(list: seq<T>): T
    requires |list| > 0
  { list[0] }
  function car<T>(list: seq<T>): T
    requires |list| > 0
  { head(list) }

  // `(arr.length > 1) ? slice(arr, 1) : EMPTY`
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

  function size<T>(list: seq<T>): nat { |list| }
}
