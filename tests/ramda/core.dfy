// Ramda v0.5.0 test/test.core.js and test/test.clone.js, transcribed. Not
// transcribed: head's and last's
// "returns undefined for an empty list" and "for no arguments" (the empty list
// is outside their domain, README "Outside the modeled domain"); tail's
// "returns an empty list for no arguments" (no-argument call of a list
// function); v0.4.0's concat cases "delegates to non-String object with a
// concat method, as second param" (method dispatch on a non-array object) and
// "throws if not an array, String, or object with a concat method" (object
// operands); and the `notStrictEqual` half of clone's "returns a copy of an
// array" (v0.4.0; reference identity); v0.5.0's "throws on zero arguments"
// cases (no-argument calls), the non-list arguments of isEmpty's "returns
// `true` for falsy arguments" (only `isEmpty('')` is a list), and the
// `notStrictEqual` half of cloneObj's "returns a copy of an object". (v0.2.0
// removed test.clone.js's describe('cloneDeep') with the function, and
// v0.5.0 test.core.js's describe('isAtom').) The lists that mix strings and
// arrays are lists of Js values.

module RamdafTests.Ramda.Core {
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Sort
  import opened Support

  // describe('isEmpty')
  method {:test} IsEmptyTrueForEmptyList() {
    var empty: seq<string> := [];
    expect isEmpty(empty) == true;
  }

  method {:test} IsEmptyFalseForNonEmptyList() {
    expect isEmpty([""]) == false;
  }

  // v0.5.0: "returns `true` for falsy arguments", its string case (a string
  // is a seq here)
  method {:test} IsEmptyTrueForFalsyArguments() {
    expect isEmpty("") == true;
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
  // objects with a concat method"). A string is a seq here.
  method {:test} ConcatWorksForStrings() {
    expect concat("foo", "bar") == "foobar";
  }

  // v0.4.0: "is curried" (its mixed list is a list of Js values)
  method {:test} ConcatIsCurried() {
    var conc123 := (l: seq<int>) => concat([1, 2, 3], l);
    expect conc123([4, 5, 6]) == [1, 2, 3, 4, 5, 6];
    var conc123Js := (l: seq<Js>) => concat([Num(1), Num(2), Num(3)], l);
    expect conc123Js([Str("a"), Str("b"), Str("c")]) == [Num(1), Num(2), Num(3), Str("a"), Str("b"), Str("c")];
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

  // v0.3.0: "should be aliased by `length`" (its `strictEqual(R.length,
  // size)` checks function identity, which Dafny functions do not have; the
  // alias is compared by its results).
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
}
