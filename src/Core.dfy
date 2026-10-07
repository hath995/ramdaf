// Ramdaf: Ramda v0.8.0 "Core Functions" (ramda.js lines 866-1225), `clone`
// (lines 785-787) and `cloneDeep` (lines 808-810) from the internal
// functions, and `size` with its alias `length` (lines 2443-2453).
// (v0.2.0 removed `cloneDeep`, which v0.8.0 brings back, and v0.4.1 the
// `first` alias of `head`.)

module Ramdaf.Core {
  import opened Prelude

  export
    reveals clone, cloneDeep, isEmpty, prepend, cons, prependTo, nth, head, car, last,
            tail, cdr, append, push, appendTo, concat, identity, I, times, repeatN,
            size, length
    provides Prelude

  // `clone(list)` is `_slice(list)` (`list.concat()` before v0.2.0), a
  // shallow copy. Dafny sequences are values, so the copy is the list itself.
  function clone<T>(list: seq<T>): seq<T> { list }

  // `R.cloneDeep(value)` (v0.8.0): `_baseCopy(value, [], [])`, a deep copy of
  // nested arrays and objects (a Date is copied, a shared or circular
  // reference copied once) that keeps functions by reference. A Dafny value
  // is immutable and has no identity, so its deep copy is the value itself.
  // (v0.1.1's `cloneDeep`, removed in v0.2.0, was a JSON round trip that
  // dropped functions and undefined properties, and took a `T(==)`.) In JS
  // an own `__proto__` property is not copied (README "Deviations").
  function cloneDeep<T>(value: T): T { value }

  // `val == null || val.length === 0` (v0.8.0; `!list || !list.length`
  // before): on a list (or a JS string) the same test, |list| == 0. Only
  // non-list arguments changed (`isEmpty(0)` is now false).
  function isEmpty<T>(list: seq<T>): bool { |list| == 0 }

  function prepend<T>(el: T, list: seq<T>): seq<T> { [el] + list }
  function cons<T>(el: T, list: seq<T>): seq<T> { prepend(el, list) }

  // `R.prependTo = flip(_prepend)` (v0.8.0), where `_prepend` is the
  // function behind `R.prepend`: prepend with the arguments the other way
  // round.
  function prependTo<T>(list: seq<T>, el: T): seq<T> { prepend(el, list) }

  // `R.nth(n, list)` (v0.8.0): `n < 0 ? list[list.length + n] : list[n]`,
  // the element at n, a negative n counting from the end; out of range it is
  // undefined (documented: `nth(-99, list)`), here None. (v0.1.0 to v0.4.0
  // had another `nth` in List, from v0.3.0 an alias of `prop`; v0.4.1
  // removed it.)
  function nth<T>(n: int, list: seq<T>): Option<T>
  { var i := if n < 0 then |list| + n else n;
    if 0 <= i < |list| then Some(list[i]) else None }

  // `arr[0]` (since v0.8.0 `nth(0)`): `head([])` is undefined (not an
  // element), so the empty list is excluded.
  function head<T>(list: seq<T>): T
    requires |list| > 0
  { list[0] }
  function car<T>(list: seq<T>): T
    requires |list| > 0
  { head(list) }

  // `arr[arr.length - 1]` (since v0.8.0 `nth(-1)`): `last([])` is undefined,
  // so the empty list is excluded.
  function last<T>(list: seq<T>): T
    requires |list| > 0
  { list[|list| - 1] }

  // `_slice(list, 1)` (v0.8.0; `(arr.length > 1) ? slice(arr, 1) : []`
  // before, the same on lists, as `_slice` of a list with at most one
  // element is [])
  function tail<T>(list: seq<T>): seq<T>
    ensures |list| > 0 ==> tail(list) == list[1..]
  { if |list| <= 1 then [] else list[1..] }
  function cdr<T>(list: seq<T>): seq<T> { tail(list) }

  function append<T>(el: T, list: seq<T>): seq<T> { list + [el] }
  function push<T>(el: T, list: seq<T>): seq<T> { append(el, list) }

  // `R.appendTo = flip(_append)` (v0.8.0): append with the arguments the
  // other way round.
  function appendTo<T>(list: seq<T>, el: T): seq<T> { append(el, list) }

  // `R.concat` (v0.2.4; until v0.2.3 it was an alias of `merge`, which v0.2.4
  // removed): the elements of list1 followed by those of list2. When the
  // second argument is not an array, v0.6.0 calls the first argument's
  // `concat` method if it has one (`concat("foo", "bar")` is `"foobar"`) and
  // otherwise throws TypeError. From v0.6.0 to v0.7.2 the first argument
  // also had to be truthy, so `concat("", "bar")` threw; since v0.8.0
  // `_hasMethod` tests `obj != null`, so it is `"bar"`, as here. (v0.4.0 and
  // v0.5.0 tested for a String first argument and then the second argument's
  // method.) A Dafny string is a seq, so the same function covers strings.
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
