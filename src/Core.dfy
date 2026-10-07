// Ramdaf: Ramda v0.4.1 "Core Functions" (ramda.js lines 753-1056), `clone`
// (lines 749-751), and `size` with its alias `length` (lines 1958-1968).
// (v0.2.0 removed `cloneDeep`, and v0.4.1 the `first` alias of `head`.)

module Ramdaf.Core {
  export
    reveals clone, isEmpty, prepend, cons, head, car, last, tail, cdr,
            append, push, concat, identity, I, times, repeatN, size, length

  // `clone(list)` is `_slice(list)` (`list.concat()` before v0.2.0), a
  // shallow copy. Dafny sequences are values, so the copy is the list itself.
  function clone<T>(list: seq<T>): seq<T> { list }

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

  // `R.concat` (v0.2.4; until v0.2.3 it was an alias of `merge`, which v0.2.4
  // removed): the elements of list1 followed by those of list2. Since v0.4.0
  // a second argument that is not an array makes a String first argument
  // concatenate as a string (`concat("foo", "bar")` is `"foobar"`), and
  // otherwise calls the second argument's `concat` method with the first
  // (`set2.concat(set1)`) or throws TypeError; until v0.3.0 a non-array first
  // argument with a `concat` method was dispatched to. A Dafny string is a
  // seq, so the same function covers strings.
  function concat<T>(list1: seq<T>, list2: seq<T>): seq<T> { list1 + list2 }

  function identity<T>(x: T): T { x }
  function I<T>(x: T): T { identity(x) }

  // `var arr = new Array(n); while (++i < n) { arr[i] = fn(i); }` (v0.2.3):
  // fn applied to 0, 1, ..., n - 1. `new Array(n)` throws RangeError for a
  // negative n, so n is a nat.
  function times<T>(fn: nat -> T, n: nat): seq<T>
    ensures |times(fn, n)| == n
    ensures forall i :: 0 <= i < n ==> times(fn, n)[i] == fn(i)
  { seq(n, i requires 0 <= i < n => fn(i)) }

  // n copies of value: since v0.2.3 `times(always(value), n)`, before that
  // `var arr = new Array(n), i = -1; while (++i < n) { arr[i] = value; }`.
  // Since v0.2.0 the array is allocated with `new Array(n)`, which throws
  // RangeError for a negative n (v0.1.3 to v0.1.5 returned []), so n is a
  // nat.
  function repeatN<T>(value: T, n: nat): seq<T>
    ensures |repeatN(value, n)| == n
    ensures forall i :: 0 <= i < n ==> repeatN(value, n)[i] == value
  { seq(n, _ => value) }

  function size<T>(list: seq<T>): nat { |list| }
  // v0.3.0: `aliasFor('size').is('length')`.
  function length<T>(list: seq<T>): nat { size(list) }
}
