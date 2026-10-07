// Ramda v0.15.0 test/isEmpty.js, prepend.js, append.js, concat.js, nth.js,
// head.js, last.js, tail.js, length.js, sort.js, comparator.js, clone.js,
// identity.js and isNil.js, transcribed
// (v0.9.0 splits the suite into one file per function; until v0.8.0 these
// were test.core.js, test.clone.js, test.cloneDeep.js and test.identity.js).
// Not transcribed: head's and last's "returns undefined for an empty list"
// (the empty list is outside their domain, README "Outside the modeled
// domain"); the "throws if applied to null or undefined" cases of nth, head,
// last and tail (null and undefined are not lists); concat's "delegates to
// non-String object with a concat method, as second param" (method dispatch
// on a non-array object) and "throws if not an array, String, or object with
// a concat method" (object operands); the "throws on zero arguments" cases
// (no-argument calls; v0.11.0 removed them); isEmpty's cases on values that are not lists
// ("returns false for null" and "for undefined", "returns true for empty
// arguments object", the two objects with a `length` property, and of
// "returns false for every other value" all but `isEmpty([''])`); length's
// cases on functions, arguments objects and values of other types (NaN);
// clone's "clone objects with circular references" and "clone instances"
// (cycles, prototypes) and "clone date" (no Date value), the Date property
// of "clone shallow object", the mutations of the original after cloning (a
// Dafny value cannot be mutated, so the clone equals the input) and the
// `!==`, `===` and `notStrictEqual` halves (reference identity); identity's
// two-argument call (fixed arity) and "has length 1" (arity); clone's
// "clones RegExp object" (v0.12.0; no RegExp value); and nthArg.js
// (not portable, README). The `typeof` checks of the "is curried" cases hold
// by construction. (v0.9.0 removed size's describe with `size`, whose
// "counts the elements" length.js replaces, clone's two shallow-copy `it`s
// and cloneObj's describe with `cloneObj`; v0.5.0 removed test.core.js's
// describe('isAtom'); v0.12.0 removed prependTo.js, appendTo.js and
// identity's "is aliased by `I`" with the functions.) The lists that mix strings and arrays are lists of Js
// values, and so are the values clone.js clones.

module RamdafTests.Ramda.Core {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Sort
  import opened Support

  // describe('isEmpty') (a string is a seq here)
  method {:test} IsEmptyTrueForEmptyString() {
    expect isEmpty("") == true;
  }

  method {:test} IsEmptyTrueForEmptyArray() {
    var empty: seq<string> := [];
    expect isEmpty(empty) == true;
  }

  // "returns false for every other value": its list case
  method {:test} IsEmptyFalseForEveryOtherValue() {
    expect isEmpty([""]) == false;
  }

  // describe('prepend')
  method {:test} PrependAddsToTheBeginning() {
    expect prepend("x", ["y", "z"]) == ["x", "y", "z"];
    // v0.2.0: an array element is prepended as one element
    var az := Arr([Str("a"), Str("z")]);
    expect prepend(az, [Str("x"), Str("y")]) == [az, Str("x"), Str("y")];
  }

  // v0.5.0
  method {:test} PrependWorksOnEmptyList() {
    var empty: seq<int> := [];
    expect prepend(1, empty) == [1];
  }

  // v0.5.0
  method {:test} PrependIsCurried() {
    var prepend4 := (l: seq<int>) => prepend(4, l);
    expect prepend4([3, 2, 1]) == [4, 3, 2, 1];
  }

  // describe('append')
  method {:test} AppendAddsToTheEnd() {
    expect append("z", ["x", "y"]) == ["x", "y", "z"];
    // v0.2.0: an array element is appended as one element
    var az := Arr([Str("a"), Str("z")]);
    expect append(az, [Str("x"), Str("y")]) == [Str("x"), Str("y"), az];
  }

  // v0.5.0
  method {:test} AppendWorksOnEmptyList() {
    var empty: seq<int> := [];
    expect append(1, empty) == [1];
  }

  // v0.5.0
  method {:test} AppendIsCurried() {
    var append1 := (l: seq<int>) => append(1, l);
    expect append1([4, 3, 2]) == [4, 3, 2, 1];
  }

  // describe('concat') (v0.2.4; it was describe('merge')). Its first `it`
  // appears twice, with the same body.
  method {:test} ConcatCombinesTheLists() {
    expect concat(["a", "b"], ["c", "d"]) == ["a", "b", "c", "d"];
    var empty: seq<string> := [];
    expect concat(empty, ["c", "d"]) == ["c", "d"];
  }

  // "works on strings" (v0.4.0; until v0.3.0 the string half of "works for
  // objects with a concat method"). A string is a seq here. v0.8.0 adds the
  // empty-string cases, which threw from v0.6.0 to v0.7.2.
  method {:test} ConcatWorksForStrings() {
    expect concat("foo", "bar") == "foobar";
    expect concat("x", "") == "x";
    expect concat("", "x") == "x";
    expect concat("", "") == "";
  }

  // v0.9.0: "is curried like a binary operator, that accepts an inital
  // placeholder": since v0.11.0 only `appendBar = concat(__, 'bar')`,
  // `appendBar('foo')` → 'foobar' (v0.9.x also had `concat(__)('bar')('foo')`
  // and `concat(__)('bar', 'foo')`, which the `op` currying flipped; since
  // v0.11.0 `concat(__)` is concat itself, and the first gives 'barfoo').
  method {:test} ConcatIsCurriedLikeABinaryOperator() {
    var appendBar := (a: string) => concat(a, "bar");
    expect appendBar("foo") == "foobar";
  }

  // v0.4.0: "is curried" (its mixed list is a list of Js values)
  method {:test} ConcatIsCurried() {
    var conc123 := (l: seq<int>) => concat([1, 2, 3], l);
    expect conc123([4, 5, 6]) == [1, 2, 3, 4, 5, 6];
    var conc123Js := (l: seq<Js>) => concat([Num(1), Num(2), Num(3)], l);
    expect conc123Js([Str("a"), Str("b"), Str("c")]) == [Num(1), Num(2), Num(3), Str("a"), Str("b"), Str("c")];
  }

  // describe('nth') (v0.8.0): undefined is None
  function NthList(): seq<string> { ["foo", "bar", "baz", "quux"] }

  method {:test} NthAcceptsPositiveOffsets() {
    expect nth(0, NthList()) == Some("foo");
    expect nth(1, NthList()) == Some("bar");
    expect nth(2, NthList()) == Some("baz");
    expect nth(3, NthList()) == Some("quux");
    expect nth(4, NthList()) == None;
  }

  method {:test} NthAcceptsNegativeOffsets() {
    expect nth(-1, NthList()) == Some("quux");
    expect nth(-2, NthList()) == Some("baz");
    expect nth(-3, NthList()) == Some("bar");
    expect nth(-4, NthList()) == Some("foo");
    expect nth(-5, NthList()) == None;
  }

  method {:test} NthIsCurried() {
    var nth0 := (l: seq<string>) => nth(0, l);
    expect nth0(NthList()) == Some("foo");
  }

  // describe('head')
  method {:test} HeadReturnsTheFirstElement() {
    expect head(["a", "b", "c", "d"]) == "a";
  }

  // describe('last') ("returns the first element of a list" checks the last)
  method {:test} LastReturnsTheLastElement() {
    expect last(["a", "b", "c", "d"]) == "d";
  }

  // describe('tail')
  method {:test} TailReturnsAnEmptyListForAnEmptyList() {
    var empty: seq<string> := [];
    expect tail(empty) == [];
  }

  method {:test} TailReturnsTheRest() {
    expect tail(["a", "b", "c", "d"]) == ["b", "c", "d"];
  }

  // describe('length') (v0.9.0; describe('size') until v0.8.0)
  method {:test} LengthReturnsTheLengthOfAList() {
    var empty: seq<string> := [];
    expect length(empty) == 0;
    expect length(["a", "b", "c", "d"]) == 4;
  }

  method {:test} LengthReturnsTheLengthOfAString() {
    expect length("") == 0;
    expect length("xyz") == 3;
  }

  // describe('sort')
  method {:test} SortSortsTheElements() {
    expect sort((a: int, b: int) => a - b, [3, 1, 8, 1, 2, 5]) == [1, 1, 2, 3, 5, 8];
  }

  method {:test} SortDoesNotAffectTheListSupplied() {
    var list := [3, 1, 8, 1, 2, 5];
    expect sort((a: int, b: int) => a - b, list) == [1, 1, 2, 3, 5, 8];
    expect list == [3, 1, 8, 1, 2, 5];
  }

  // "is automatically curried": `sort(cmp)` applied to the list. The expected
  // order relies on a stable sort.
  method {:test} SortIsAutomaticallyCurried() {
    var sortByLength := (l: seq<string>) => sort((a: string, b: string) => |a| - |b|, l);
    expect sortByLength(["one", "two", "three", "four", "five", "six"]) ==
      ["one", "two", "six", "four", "five", "three"];
  }

  // describe('comparator')
  method {:test} ComparatorBuildsAComparatorFromALessThanPredicate() {
    expect sort(comparator((a: int, b: int) => a < b), [3, 1, 8, 1, 2, 5]) == [1, 1, 2, 3, 5, 8];
  }

  // ---- clone.js (test.cloneDeep.js's `it`s until v0.8.0, for cloneDeep) ----

  // describe('deep clone integers, strings and booleans')
  method {:test} CloneIntegers() {
    expect clone(-4) == -4;
    expect clone(9007199254740991) == 9007199254740991;
  }

  method {:test} CloneFloats() {
    expect clone(-4.5) == -4.5;
    expect clone(0.0) == 0.0;
  }

  method {:test} CloneStrings() {
    expect clone("ramda") == "ramda";
  }

  method {:test} CloneBooleans() {
    expect clone(true) == true;
  }

  // describe('deep clone objects'): "clone shallow object" without its Date
  // property `d`
  method {:test} CloneShallowObject() {
    var obj := map["a" := Num(1), "b" := Str("ramda"), "c" := Bool(true)];
    expect clone(obj) == map["a" := Num(1), "b" := Str("ramda"), "c" := Bool(true)];
  }

  method {:test} CloneDeepObject() {
    var obj := map["a" := Obj(map["b" := Obj(map["c" := Str("ramda")])])];
    expect clone(obj) == map["a" := Obj(map["b" := Obj(map["c" := Str("ramda")])])];
  }

  // describe('deep clone arrays')
  method {:test} CloneShallowArrays() {
    expect clone([1, 2, 3]) == [1, 2, 3];
  }

  method {:test} CloneDeepArrays() {
    var list := [Num(1), Arr([Num(1), Num(2), Num(3)]), Arr([Arr([Arr([Num(5)])])])];
    expect clone(list) == [Num(1), Arr([Num(1), Num(2), Num(3)]), Arr([Arr([Arr([Num(5)])])])];
  }

  // describe('deep `clone` functions'): "keep reference to function"
  method {:test} CloneKeepsReferenceToFunction() {
    var fn := (x: int) => x + x;
    var c: seq<map<string, int -> int>> := clone([map["a" := fn]]);
    var a := c[0]["a"];
    expect a(10) == 20;
  }

  // describe('deep clone deep nested mixed objects')
  method {:test} CloneArrayWithObjects() {
    var list := [Obj(map["a" := Obj(map["b" := Num(1)])]), Arr([Obj(map["c" := Obj(map["d" := Num(1)])])])];
    expect clone(list) == [Obj(map["a" := Obj(map["b" := Num(1)])]), Arr([Obj(map["c" := Obj(map["d" := Num(1)])])])];
  }

  method {:test} CloneArrayWithArrays() {
    var list := [Arr([Num(1)]), Arr([Arr([Num(3)])])];
    expect clone(list) == [Arr([Num(1)]), Arr([Arr([Num(3)])])];
  }

  method {:test} CloneArrayWithMutualRefObject() {
    var obj := map["a" := 1];
    var c := clone([map["b" := obj], map["b" := obj]]);
    expect c[0]["b"] == c[1]["b"];
    expect c[0]["b"] == map["a" := 1];
    expect c[1]["b"] == map["a" := 1];
  }

  // describe('deep clone edge cases') (until v0.10.0 it also asserted
  // `clone()`, the same as `clone(undefined)`)
  method {:test} CloneNullsUndefinedsAndEmptyObjectsAndArrays() {
    expect clone(Null) == Null;
    expect clone(Undefined) == Undefined;
    expect clone(Undefined) != Null;
    var obj: map<string, int> := map[];
    expect clone(obj) == obj;
    var list: seq<int> := [];
    expect clone(list) == list;
  }

  // ---- identity.js ----

  // "returns its first argument": `identity(undefined)` (`identity()` until
  // v0.10.0)
  method {:test} IdentityReturnsItsFirstArgument() {
    expect identity(Undefined) == Undefined;
    expect identity("foo") == "foo";
  }

  // ---- isNil.js (v0.9.0) ----

  // "tests a value for `null` or `undefined`": both are None here (README
  // "Deviations"); the other values are Some.
  method {:test} IsNilTestsAValueForNullOrUndefined() {
    var none: Option<Js> := None;
    expect isNil(none) == true;
    expect isNil(Some(Arr([]))) == false;
    expect isNil(Some(Obj(map[]))) == false;
    expect isNil(Some(Num(0))) == false;
    expect isNil(Some(Str(""))) == false;
  }
}
