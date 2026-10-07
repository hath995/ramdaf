// Ramda v0.26.1 test/isEmpty.js, prepend.js, append.js, concat.js, nth.js,
// head.js, last.js, tail.js, length.js, sort.js, comparator.js, clone.js,
// identity.js, isNil.js, ascend.js and descend.js, transcribed
// (v0.9.0 splits the suite into one file per function; until v0.8.0 these
// were test.core.js, test.clone.js, test.cloneDeep.js and test.identity.js).
// Not transcribed: the `head([])`, `head('')`, `last([])` and `last('')`
// lines (until v0.15.1 the `it`s "returns undefined for an empty list"; the
// empty list is outside their domain, README "Outside the modeled
// domain"); the "throws if applied to null or undefined" cases of nth, head,
// last and tail (null and undefined are not lists); concat's "delegates to
// non-String object with a concat method, as second param" (method dispatch
// on a non-array object) and "throws if not an array, String, or object with
// a concat method" (object operands), and v0.22.0's "throws if attempting
// to combine an array with a non-array" (a number operand); sortWith.js
// (v0.23.0), whose `it`s all sort by a string `title` or `genre` with
// `ascend(prop(…))` (keys are ints here, README "Deviations"); the "throws on zero arguments" cases
// (no-argument calls; v0.11.0 removed them); isEmpty's cases on values that are not lists
// ("returns false for null" and "for undefined", "returns true for empty
// arguments object", v0.18.0's "returns true for empty object", which
// replaced the two objects with a `length` property, and of "returns false
// for every other value" all but `isEmpty([''])`); length's
// cases on functions, arguments objects and values of other types (NaN);
// clone's "clone objects with circular references" and "clone instances"
// (cycles, prototypes) and "clone date" (no Date value), v0.18.0's
// "dispatches to `clone` method if present" (method dispatch), the Date property
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
// (v0.26.0 removed the per-function "is curried" `it`s (concat's placeholder
// one too), with their transcriptions here.)

module RamdafTests.Ramda.Core {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Sort
  import opened Support

  // describe('isEmpty') (a string is a seq here)
  // (v0.18.0 adds the `' '` and `[[]]` lines)
  method {:test} IsEmptyTrueForEmptyString() {
    expect isEmpty("") == true;
    expect isEmpty(" ") == false;
  }

  method {:test} IsEmptyTrueForEmptyArray() {
    var empty: seq<string> := [];
    expect isEmpty(empty) == true;
    var nested: seq<seq<int>> := [[]];
    expect isEmpty(nested) == false;
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

  // describe('nth') (v0.8.0): undefined is None. v0.16.0 adds string lines:
  // a character is a one-character JS string, here a char, and the '' that
  // `nth(3, 'abc')` gives out of range is None (README "JS -> Dafny
  // mapping"); v0.16.0 removed "is curried".
  function NthList(): seq<string> { ["foo", "bar", "baz", "quux"] }

  method {:test} NthAcceptsPositiveOffsets() {
    expect nth(0, NthList()) == Some("foo");
    expect nth(1, NthList()) == Some("bar");
    expect nth(2, NthList()) == Some("baz");
    expect nth(3, NthList()) == Some("quux");
    expect nth(4, NthList()) == None;
    expect nth(0, "abc") == Some('a');
    expect nth(1, "abc") == Some('b');
    expect nth(2, "abc") == Some('c');
    expect nth(3, "abc") == None;
  }

  method {:test} NthAcceptsNegativeOffsets() {
    expect nth(-1, NthList()) == Some("quux");
    expect nth(-2, NthList()) == Some("baz");
    expect nth(-3, NthList()) == Some("bar");
    expect nth(-4, NthList()) == Some("foo");
    expect nth(-5, NthList()) == None;
    expect nth(-1, "abc") == Some('c');
    expect nth(-2, "abc") == Some('b');
    expect nth(-3, "abc") == Some('a');
    expect nth(-4, "abc") == None;
  }

  // describe('head'): v0.16.0's "returns the first element of an ordered
  // collection" (until v0.15.1 "returns the first element of a list", over
  // ['a', 'b', 'c', 'd']); its `head([])` and `head('')` lines are outside
  // the domain (undefined and '', README "Outside the modeled domain")
  method {:test} HeadReturnsTheFirstElementOfAnOrderedCollection() {
    expect head([1, 2, 3]) == 1;
    expect head([2, 3]) == 2;
    expect head([3]) == 3;
    expect head("abc") == 'a';
    expect head("bc") == 'b';
    expect head("c") == 'c';
  }

  // describe('last'): "returns the last element of an ordered collection"
  // (v0.25.0; from v0.16.0 to v0.24.1 "returns the first element of an
  // ordered collection", sic), with the same exclusions
  method {:test} LastReturnsTheLastElementOfAnOrderedCollection() {
    expect last([1, 2, 3]) == 3;
    expect last([1, 2]) == 2;
    expect last([1]) == 1;
    expect last("abc") == 'c';
    expect last("ab") == 'b';
    expect last("a") == 'a';
  }

  // describe('tail'): v0.16.0's "returns the tail of an ordered collection"
  // (until v0.15.1 "returns an empty list for an empty list" and "returns a
  // new list containing all the elements after the first element of a list")
  method {:test} TailReturnsTheTailOfAnOrderedCollection() {
    var empty: seq<int> := [];
    expect tail([1, 2, 3]) == [2, 3];
    expect tail([2, 3]) == [3];
    expect tail([3]) == [];
    expect tail(empty) == [];
    expect tail("abc") == "bc";
    expect tail("bc") == "c";
    expect tail("c") == "";
    expect tail("") == "";
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

  // describe('ascend') (v0.23.0): `[3, 1, 8, 1, 2, 5].sort(R.ascend(R.identity))`,
  // the comparator passed to Sort.sort
  method {:test} AscendBuildsAnAscendingComparatorFunctionOutOfTheIdentityFunction() {
    expect sort((a: int, b: int) => ascend((x: int) => x, a, b), [3, 1, 8, 1, 2, 5]) == [1, 1, 2, 3, 5, 8];
  }

  // describe('descend') (v0.23.0)
  method {:test} DescendBuildsADescendingComparatorFunctionOutOfTheIdentityFunction() {
    expect sort((a: int, b: int) => descend((x: int) => x, a, b), [3, 1, 8, 1, 2, 5]) == [8, 5, 3, 2, 1, 1];
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
