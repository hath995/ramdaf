// Ramda v0.8.0 test/test.core.js, test/test.clone.js, test/test.cloneDeep.js
// and test/test.identity.js, transcribed. Not transcribed: head's and last's
// "returns undefined for an empty list" (the empty list is outside their
// domain, README "Outside the modeled domain"); v0.8.0's "throws if applied
// to null or undefined" of nth, head, last and tail (null and undefined are
// not lists; v0.8.0 removed head's and last's "returns undefined for no
// arguments" and tail's "returns an empty list for no arguments"); v0.4.0's
// concat cases "delegates to non-String object with a
// concat method, as second param" (method dispatch on a non-array object) and
// "throws if not an array, String, or object with a concat method" (object
// operands); and the `notStrictEqual` half of clone's "returns a copy of an
// array" (v0.4.0; reference identity); v0.5.0's "throws on zero arguments"
// cases (no-argument calls; v0.8.0 adds prependTo's and appendTo's), and the
// `notStrictEqual` half of cloneObj's "returns a copy of an object";
// v0.8.0's isEmpty cases on values that are not lists ("returns true for
// null", "for undefined", "for empty arguments object", the two objects with
// a `length` property, and of "returns false for every other value" all but
// `isEmpty([''])`; v0.8.0 replaced the `it`s "returns true if the list is
// empty", "returns false if the list is not empty" and "returns `true` for
// falsy arguments"); test.cloneDeep.js's "clone objects with circular
// references" and "clone instances" (cycles, prototypes) and "clone date"
// (no Date value), the Date property of "clone shallow object", the
// mutations of the original after cloning (a Dafny value cannot be mutated,
// so the clone equals the input) and the `!==`, `===` and `notStrictEqual`
// halves (reference identity); and test.identity.js's two-argument call
// (fixed arity), "has length 1" (arity) and argN's describe (not portable,
// README). (v0.2.0 removed test.clone.js's describe('cloneDeep') with the
// function, and v0.5.0 test.core.js's describe('isAtom').) The lists that
// mix strings and arrays are lists of Js values, and so are the values
// test.cloneDeep.js clones.

module RamdafTests.Ramda.Core {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Sort
  import opened Support

  // describe('isEmpty') (v0.8.0's its; a string is a seq here)
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

  // describe('prependTo') (v0.8.0); the mixed list is a list of Js values
  method {:test} PrependToAddsToTheBeginning() {
    expect prependTo([4, 5, 6], 3) == [3, 4, 5, 6];
    var a123 := Arr([Num(1), Num(2), Num(3)]);
    expect prependTo([Num(4), Num(5), Num(6)], a123) == [a123, Num(4), Num(5), Num(6)];
  }

  method {:test} PrependToWorksOnEmptyList() {
    var empty: seq<int> := [];
    expect prependTo(empty, 1) == [1];
  }

  // its `typeof` check holds by construction
  method {:test} PrependToIsCurried() {
    var prependTo321 := (el: int) => prependTo([3, 2, 1], el);
    expect prependTo321(4) == [4, 3, 2, 1];
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

  // describe('appendTo') (v0.8.0); the mixed list is a list of Js values
  method {:test} AppendToAddsToTheEnd() {
    expect appendTo([1, 2, 3], 4) == [1, 2, 3, 4];
    var a456 := Arr([Num(4), Num(5), Num(6)]);
    expect appendTo([Num(1), Num(2), Num(3)], a456) == [Num(1), Num(2), Num(3), a456];
  }

  method {:test} AppendToWorksOnEmptyList() {
    var empty: seq<int> := [];
    expect appendTo(empty, 1) == [1];
  }

  // its `typeof` check holds by construction
  method {:test} AppendToIsCurried() {
    var appendTo432 := (el: int) => appendTo([4, 3, 2], el);
    expect appendTo432(1) == [4, 3, 2, 1];
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

  // describe('size')
  method {:test} SizeCountsTheElements() {
    expect size(["a", "b", "c", "d"]) == 4;
  }

  // v0.3.0: "is aliased by `length`" (since v0.7.0 only its `strictEqual(R.length,
  // size)`, a function-identity check that Dafny functions have no
  // counterpart for; the alias is compared by its results).
  method {:test} SizeIsAliasedByLength() {
    expect length([2, 4, 6, 8, 10]) == 5;
    expect length([2, 4, 6, 8, 10]) == size([2, 4, 6, 8, 10]);
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

  // ---- test.clone.js ----

  // describe('clone')
  method {:test} CloneReturnsACopyOfAnArray() {
    expect clone([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5];
  }

  // "copies objects in the array by reference": `c[0]` equals `o1` (Dafny
  // compares values, so this holds without references).
  method {:test} CloneCopiesObjectsInTheArrayByReference() {
    var o1, o2, o3 := map["x" := 1], map["x" := 2], map["x" := 3];
    var c := clone([o1, o2, o3]);
    expect c[0] == o1;
  }

  // describe('cloneiObj') (sic; v0.5.0): "returns a copy of an object"
  method {:test} CloneObjReturnsACopyOfAnObject() {
    var input := map["a" := 1, "b" := 2, "c" := 3, "z" := 100];
    expect cloneObj(input) == input;
  }

  // "copies objects in the array by reference": `c.a` equals `o1` (by value)
  method {:test} CloneObjCopiesObjectsByReference() {
    var o1, o2, o3 := map["x" := 1], map["x" := 2], map["x" := 3];
    var c := cloneObj(map["a" := o1, "b" := o2, "c" := o3]);
    expect c["a"] == o1;
  }

  // ---- test.cloneDeep.js (v0.8.0) ----

  // describe('deep clone integers, strings and booleans')
  method {:test} CloneDeepCloneIntegers() {
    expect cloneDeep(-4) == -4;
    expect cloneDeep(9007199254740991) == 9007199254740991;
  }

  method {:test} CloneDeepCloneFloats() {
    expect cloneDeep(-4.5) == -4.5;
    expect cloneDeep(0.0) == 0.0;
  }

  method {:test} CloneDeepCloneStrings() {
    expect cloneDeep("ramda") == "ramda";
  }

  method {:test} CloneDeepCloneBooleans() {
    expect cloneDeep(true) == true;
  }

  // describe('deep clone objects'): "clone shallow object" without its Date
  // property `d`
  method {:test} CloneDeepCloneShallowObject() {
    var obj := map["a" := Num(1), "b" := Str("ramda"), "c" := Bool(true)];
    expect cloneDeep(obj) == map["a" := Num(1), "b" := Str("ramda"), "c" := Bool(true)];
  }

  method {:test} CloneDeepCloneDeepObject() {
    var obj := map["a" := Obj(map["b" := Obj(map["c" := Str("ramda")])])];
    expect cloneDeep(obj) == map["a" := Obj(map["b" := Obj(map["c" := Str("ramda")])])];
  }

  // describe('deep clone arrays')
  method {:test} CloneDeepCloneShallowArrays() {
    expect cloneDeep([1, 2, 3]) == [1, 2, 3];
  }

  method {:test} CloneDeepCloneDeepArrays() {
    var list := [Num(1), Arr([Num(1), Num(2), Num(3)]), Arr([Arr([Arr([Num(5)])])])];
    expect cloneDeep(list) == [Num(1), Arr([Num(1), Num(2), Num(3)]), Arr([Arr([Arr([Num(5)])])])];
  }

  // describe('deep `clone` functions'): "keep reference to function"
  method {:test} CloneDeepKeepsReferenceToFunction() {
    var fn := (x: int) => x + x;
    var c: seq<map<string, int -> int>> := cloneDeep([map["a" := fn]]);
    var a := c[0]["a"];
    expect a(10) == 20;
  }

  // describe('deep clone deep nested mixed objects')
  method {:test} CloneDeepCloneArrayWithObjects() {
    var list := [Obj(map["a" := Obj(map["b" := Num(1)])]), Arr([Obj(map["c" := Obj(map["d" := Num(1)])])])];
    expect cloneDeep(list) == [Obj(map["a" := Obj(map["b" := Num(1)])]), Arr([Obj(map["c" := Obj(map["d" := Num(1)])])])];
  }

  method {:test} CloneDeepCloneArrayWithArrays() {
    var list := [Arr([Num(1)]), Arr([Arr([Num(3)])])];
    expect cloneDeep(list) == [Arr([Num(1)]), Arr([Arr([Num(3)])])];
  }

  method {:test} CloneDeepCloneArrayWithMutualRefObject() {
    var obj := map["a" := 1];
    var c := cloneDeep([map["b" := obj], map["b" := obj]]);
    expect c[0]["b"] == c[1]["b"];
    expect c[0]["b"] == map["a" := 1];
    expect c[1]["b"] == map["a" := 1];
  }

  // describe('deep clone edge cases'): `cloneDeep()` is
  // `cloneDeep(undefined)`
  method {:test} CloneDeepNullsUndefinedsAndEmptyObjectsAndArrays() {
    expect cloneDeep(Null) == Null;
    expect cloneDeep(Undefined) == Undefined;
    expect cloneDeep(Undefined) != Null;
    var obj: map<string, int> := map[];
    expect cloneDeep(obj) == obj;
    var list: seq<int> := [];
    expect cloneDeep(list) == list;
  }

  // ---- test.identity.js (v0.8.0) ----

  // "returns its first argument": `identity()` is `identity(undefined)`
  method {:test} IdentityReturnsItsFirstArgument() {
    expect identity(Undefined) == Undefined;
    expect identity("foo") == "foo";
  }

  // "is aliased by `I`" (`strictEqual(R.I, R.identity)`; compared by results)
  method {:test} IdentityIsAliasedByI() {
    expect I("foo") == identity("foo");
    expect I(Num(3)) == Num(3);
  }
}
