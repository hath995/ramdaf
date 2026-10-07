// Ramdaf: Ramda v0.14.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Core Functions" section (`isEmpty`, `prepend`, `nth`,
// `head`, `last`, `tail`, `append`, `concat`, `identity`, `times`), `clone`
// and `length`; and, from v0.9.0 on, the functions with `@category Type`
// (`isNil`). (v0.2.0 removed `cloneDeep`, which v0.8.0 brought back; v0.4.1
// removed the `first` alias of `head`; v0.9.0 removed the aliases `car`,
// `cdr`, `cons` and `push`, `size`, whose alias `length` holds its code now,
// and `cloneDeep`, which `clone` became, and renamed `repeatN` to `repeat`,
// which `@category List` puts in List; v0.12.0 removed `prependTo`,
// `appendTo` and the `I` alias of `identity`, deprecated in v0.11.0.)

module Ramdaf.Core {
  import opened Prelude

  export
    reveals clone, isEmpty, prepend, nth, head, last, tail, append,
            concat, identity, times, length, isNil
    provides Prelude

  // `R.clone(value)` (`src/clone.js`): `_baseCopy(value, [], [])`, a deep
  // copy of nested arrays and objects (a Date is copied, a shared or
  // circular reference copied once) that keeps functions and primitives
  // (strings included) as they are. v0.9.0 "unify R.clone, R.cloneObj, and
  // R.cloneDeep" gave `clone` v0.8.0's `cloneDeep` code and removed the
  // other two; until v0.8.0 `clone(list)` was `_slice(list)`
  // (`list.concat()` before v0.2.0), a shallow copy of a list, and the port
  // took a seq. A Dafny value is immutable and has no identity, so its copy
  // is the value itself. In JS an own `__proto__` property is not copied
  // (README "Deviations").
  function clone<T>(value: T): T { value }

  // `Object(list).length === 0` (v0.9.0; v0.8.0 `val == null || val.length
  // === 0`, `!list || !list.length` before): on a list (or a JS string) the
  // same test, |list| == 0. Only non-list arguments changed (since v0.8.0
  // `isEmpty(0)` is false, and since v0.9.0 `isEmpty(null)` too).
  function isEmpty<T>(list: seq<T>): bool { |list| == 0 }

  function prepend<T>(el: T, list: seq<T>): seq<T> { [el] + list }


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

  function append<T>(el: T, list: seq<T>): seq<T> { list + [el] }


  // `R.concat` (v0.2.4; until v0.2.3 it was an alias of `merge`, which v0.2.4
  // removed): the elements of list1 followed by those of list2. When the
  // second argument is not an array, v0.6.0 calls the first argument's
  // `concat` method if it has one (`concat("foo", "bar")` is `"foobar"`) and
  // otherwise throws TypeError. From v0.6.0 to v0.7.2 the first argument
  // also had to be truthy, so `concat("", "bar")` threw; since v0.8.0
  // `_hasMethod` tests `obj != null`, so it is `"bar"`, as here. (v0.4.0 and
  // v0.5.0 tested for a String first argument and then the second argument's
  // method.) A Dafny string is a seq, so the same function covers strings.
  // (From v0.9.0 to v0.10.0 `concat` was `op`-curried, and since v0.11.0 it
  // is `_curry2`, which takes the placeholder in either position,
  // `concat(__, b)`; neither changes the two-argument result.)
  function concat<T>(list1: seq<T>, list2: seq<T>): seq<T> { list1 + list2 }

  function identity<T>(x: T): T { x }


  // `var arr = new Array(n); while (++i < n) { arr[i] = fn(i); }` (v0.2.3;
  // since v0.9.0 `new Array(Number(n))`, which only changes non-numbers):
  // fn applied to 0, 1, ..., n - 1. `new Array(n)` throws RangeError for a
  // negative n, so n is a nat.
  function times<T>(fn: nat -> T, n: nat): seq<T>
    ensures |times(fn, n)| == n
    ensures forall i :: 0 <= i < n ==> times(fn, n)[i] == fn(i)
  { seq(n, i requires 0 <= i < n => fn(i)) }

  // `list != null && is(Number, list.length) ? list.length : NaN`
  // (`src/length.js`; v0.9.0 removed `size`, whose alias `length` was from
  // v0.3.0 to v0.8.0, and gave `length` the code, NaN only for non-lists).
  function length<T>(list: seq<T>): nat { |list| }

  // `R.isNil(x)` (v0.9.0, `@category Type`): `x == null`, true for null and
  // undefined. The port's `None` is JS undefined (an absent property, a "no
  // value" result) and stands for null too, so isNil tests an Option
  // (README "Deviations"). (Since v0.11.0 it is `_curry1`, so a call with
  // no argument returns isNil itself, which the port has no form for.)
  function isNil<T>(x: Option<T>): bool { x.None? }
}
