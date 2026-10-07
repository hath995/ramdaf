// Ramdaf: Ramda v0.20.0 `src/comparator.js`, `src/sort.js` and
// `src/sortBy.js`.
//
// `sort` is `_slice(list).sort(comparator)` (v0.14.0, "Don't clone in sort"),
// i.e. JS Array.prototype.sort on a shallow copy, which is stable (ES2019;
// node is the reference). (From v0.9.0 to v0.13.0 it sorted
// `clone(list)`, a deep copy, so the elements were copies, an element object
// lost an own `__proto__` key, and a JS string, which `clone` returns as it
// is, threw: `sort(cmp, 'cab')`, `['a', 'b', 'c']` again since v0.14.0, as
// here. `Array.prototype.sort` has always put `undefined` elements last
// without calling the comparator, README "Deviations".) For a comparator that is
// consistent on the list's elements the postconditions determine the result
// completely: the stable sorted permutation. JS leaves the order unspecified
// for inconsistent comparators, and so do the postconditions here. The bodies
// use private helpers, so `sort` and `sortBy` are exported by contract.

module Ramdaf.Sort {
  import List

  export
    reveals comparator
    provides sort, sortBy, List

  // `pred(a, b) ? -1 : pred(b, a) ? 1 : 0`, from a "less than" predicate.
  function comparator<T>(pred: (T, T) -> bool): (T, T) -> int
  { (a, b) => if pred(a, b) then -1 else if pred(b, a) then 1 else 0 }

  // The comparator's sign is antisymmetric and `<= 0` is transitive, on the
  // elements of the list (indices i, j, k range over it).
  function sort<T>(cmp: (T, T) -> int, list: seq<T>): seq<T>
    ensures |sort(cmp, list)| == |list|
    ensures multiset(sort(cmp, list)) == multiset(list)
    ensures ((forall i, j :: 0 <= i < |list| && 0 <= j < |list| ==>
                (cmp(list[i], list[j]) < 0 <==> cmp(list[j], list[i]) > 0)) &&
             (forall i, j, k | 0 <= i < |list| && 0 <= j < |list| && 0 <= k < |list| ::
                cmp(list[i], list[j]) <= 0 && cmp(list[j], list[k]) <= 0 ==> cmp(list[i], list[k]) <= 0))
            ==>
            (forall i, j :: 0 <= i < j < |list| ==>
               cmp(sort(cmp, list)[i], sort(cmp, list)[j]) <= 0) &&
            (forall i :: 0 <= i < |list| ==>
               List.filter(y => cmp(y, list[i]) == 0, sort(cmp, list)) ==
               List.filter(y => cmp(y, list[i]) == 0, list))
  { SortCorrect(cmp, list);
    insertionSort(cmp, list) }

  // `_slice(list).sort(function(a, b) { var aa = fn(a); var bb = fn(b);
  // return aa < bb ? -1 : aa > bb ? 1 : 0; })` (v0.10.0, "preserve object
  // identity in R.sortBy"; v0.9.1 sorted a deep `clone(list)`, so a JS
  // string threw and an element object lost an own `__proto__` key, and
  // until v0.9.0 the list's `{key, val}` pairs were sorted by key and the
  // values plucked): a stable sort by key of a shallow copy, which keeps the
  // elements themselves. `Array.prototype.sort` still puts `undefined`
  // elements last (README "Deviations"). The keys are ints (see README
  // "Deviations").
  function sortBy<T>(fn: T -> int, list: seq<T>): seq<T>
    ensures |sortBy(fn, list)| == |list|
    ensures multiset(sortBy(fn, list)) == multiset(list)
    ensures forall i, j :: 0 <= i < j < |list| ==> fn(sortBy(fn, list)[i]) <= fn(sortBy(fn, list)[j])
    ensures forall i :: 0 <= i < |list| ==>
      List.filter(y => fn(y) == fn(list[i]), sortBy(fn, list)) == List.filter(y => fn(y) == fn(list[i]), list)
  { var cmp := (a: T, b: T) => fn(a) - fn(b);
    SortCorrect(cmp, list);
    forall i | 0 <= i < |list|
      ensures List.filter(y => fn(y) == fn(list[i]), insertionSort(cmp, list)) ==
              List.filter(y => fn(y) == fn(list[i]), list)
    {
      FilterCongruent(y => cmp(y, list[i]) == 0, y => fn(y) == fn(list[i]), insertionSort(cmp, list));
      FilterCongruent(y => cmp(y, list[i]) == 0, y => fn(y) == fn(list[i]), list);
    }
    insertionSort(cmp, list) }

  // ---- private: insertion sort and its proof ----

  function insert<T>(cmp: (T, T) -> int, x: T, s: seq<T>): seq<T>
  { if |s| == 0 || cmp(x, s[0]) <= 0 then [x] + s else [s[0]] + insert(cmp, x, s[1..]) }

  function insertionSort<T>(cmp: (T, T) -> int, list: seq<T>): seq<T>
  { if |list| == 0 then [] else insert(cmp, list[0], insertionSort(cmp, list[1..])) }

  ghost predicate Laws<T>(cmp: (T, T) -> int, u: seq<T>)
  {
    (forall i, j :: 0 <= i < |u| && 0 <= j < |u| ==> (cmp(u[i], u[j]) < 0 <==> cmp(u[j], u[i]) > 0)) &&
    (forall i, j, k | 0 <= i < |u| && 0 <= j < |u| && 0 <= k < |u| ::
       cmp(u[i], u[j]) <= 0 && cmp(u[j], u[k]) <= 0 ==> cmp(u[i], u[k]) <= 0)
  }

  ghost predicate Sorted<T>(cmp: (T, T) -> int, s: seq<T>)
  { forall i, j :: 0 <= i < j < |s| ==> cmp(s[i], s[j]) <= 0 }

  lemma LawsOnElements<T>(cmp: (T, T) -> int, u: seq<T>)
    requires Laws(cmp, u)
    ensures forall a, b :: a in u && b in u ==> (cmp(a, b) < 0 <==> cmp(b, a) > 0)
    ensures forall a, b, c :: a in u && b in u && c in u && cmp(a, b) <= 0 && cmp(b, c) <= 0 ==> cmp(a, c) <= 0
  {
    forall a, b | a in u && b in u ensures cmp(a, b) < 0 <==> cmp(b, a) > 0 {
      var i, j :| 0 <= i < |u| && 0 <= j < |u| && u[i] == a && u[j] == b;
    }
    forall a, b, c | a in u && b in u && c in u && cmp(a, b) <= 0 && cmp(b, c) <= 0 ensures cmp(a, c) <= 0 {
      var i, j, k :| 0 <= i < |u| && 0 <= j < |u| && 0 <= k < |u| && u[i] == a && u[j] == b && u[k] == c;
    }
  }

  lemma InsertElements<T>(cmp: (T, T) -> int, x: T, s: seq<T>)
    ensures |insert(cmp, x, s)| == |s| + 1
    ensures multiset(insert(cmp, x, s)) == multiset{x} + multiset(s)
    ensures forall y :: y in insert(cmp, x, s) ==> y == x || y in s
    ensures x in insert(cmp, x, s) && forall y :: y in s ==> y in insert(cmp, x, s)
  {
    if |s| > 0 && cmp(x, s[0]) > 0 {
      InsertElements(cmp, x, s[1..]);
      assert s == [s[0]] + s[1..];
    }
  }

  lemma SortElements<T>(cmp: (T, T) -> int, list: seq<T>)
    ensures |insertionSort(cmp, list)| == |list|
    ensures multiset(insertionSort(cmp, list)) == multiset(list)
    ensures forall y :: y in insertionSort(cmp, list) ==> y in list
    ensures forall y :: y in list ==> y in insertionSort(cmp, list)
  {
    if |list| > 0 {
      SortElements(cmp, list[1..]);
      InsertElements(cmp, list[0], insertionSort(cmp, list[1..]));
      assert list == [list[0]] + list[1..];
    }
  }

  // The `<= 0` facts below hold for elements of u.
  lemma InsertSorted<T>(cmp: (T, T) -> int, u: seq<T>, x: T, s: seq<T>)
    requires Laws(cmp, u)
    requires x in u && forall y :: y in s ==> y in u
    requires Sorted(cmp, s)
    ensures Sorted(cmp, insert(cmp, x, s))
  {
    LawsOnElements(cmp, u);
    if |s| == 0 || cmp(x, s[0]) <= 0 {
      var r := [x] + s;
      forall i, j | 0 <= i < j < |r| ensures cmp(r[i], r[j]) <= 0 {
        if i == 0 {
          assert r[j] == s[j - 1] && s[0] in u && s[j - 1] in u;
          if j > 1 { assert cmp(s[0], s[j - 1]) <= 0; }
        } else {
          assert r[i] == s[i - 1] && r[j] == s[j - 1];
        }
      }
    } else {
      var t := insert(cmp, x, s[1..]);
      InsertSorted(cmp, u, x, s[1..]);
      InsertElements(cmp, x, s[1..]);
      assert s[0] in u;
      assert cmp(s[0], x) < 0;
      var r := [s[0]] + t;
      forall i, j | 0 <= i < j < |r| ensures cmp(r[i], r[j]) <= 0 {
        if i == 0 {
          assert r[j] == t[j - 1];
          assert t[j - 1] in t;
          assert r[j] == x || r[j] in s[1..];
          if r[j] != x { var k :| 0 <= k < |s[1..]| && s[1..][k] == r[j]; assert s[k + 1] == r[j]; }
        } else {
          assert r[i] == t[i - 1] && r[j] == t[j - 1];
        }
      }
    }
  }

  lemma SortSorted<T>(cmp: (T, T) -> int, list: seq<T>)
    requires Laws(cmp, list)
    ensures Sorted(cmp, insertionSort(cmp, list))
  {
    if |list| > 0 {
      assert Laws(cmp, list[1..]) by {
        forall i, j | 0 <= i < |list[1..]| && 0 <= j < |list[1..]|
          ensures cmp(list[1..][i], list[1..][j]) < 0 <==> cmp(list[1..][j], list[1..][i]) > 0
        { assert list[1..][i] == list[i + 1] && list[1..][j] == list[j + 1]; }
        forall i, j, k | 0 <= i < |list[1..]| && 0 <= j < |list[1..]| && 0 <= k < |list[1..]| &&
            cmp(list[1..][i], list[1..][j]) <= 0 && cmp(list[1..][j], list[1..][k]) <= 0
          ensures cmp(list[1..][i], list[1..][k]) <= 0
        { assert list[1..][i] == list[i + 1] && list[1..][j] == list[j + 1] && list[1..][k] == list[k + 1]; }
      }
      SortSorted(cmp, list[1..]);
      SortElements(cmp, list[1..]);
      assert forall y :: y in list[1..] ==> y in list;
      assert list[0] in list;
      InsertSorted(cmp, list, list[0], insertionSort(cmp, list[1..]));
    }
  }

  // Inserting x leaves the order within every equivalence class of s alone and
  // puts x first in its own class.
  lemma InsertStable<T>(cmp: (T, T) -> int, u: seq<T>, x: T, s: seq<T>, z: T)
    requires Laws(cmp, u)
    requires x in u && z in u && forall y :: y in s ==> y in u
    ensures List.filter(y => cmp(y, z) == 0, insert(cmp, x, s)) ==
            (if cmp(x, z) == 0 then [x] else []) + List.filter(y => cmp(y, z) == 0, s)
  {
    LawsOnElements(cmp, u);
    if |s| == 0 || cmp(x, s[0]) <= 0 {
    } else {
      InsertStable(cmp, u, x, s[1..], z);
      assert s[0] in u;
      if cmp(x, z) == 0 {
        // s[0] < x, so s[0] is not in x's class.
        assert cmp(s[0], z) != 0;
      }
    }
  }

  lemma SortCorrect<T>(cmp: (T, T) -> int, list: seq<T>)
    ensures |insertionSort(cmp, list)| == |list|
    ensures multiset(insertionSort(cmp, list)) == multiset(list)
    ensures Laws(cmp, list) ==>
            Sorted(cmp, insertionSort(cmp, list)) &&
            (forall i :: 0 <= i < |list| ==>
               List.filter(y => cmp(y, list[i]) == 0, insertionSort(cmp, list)) ==
               List.filter(y => cmp(y, list[i]) == 0, list))
  {
    SortElements(cmp, list);
    if Laws(cmp, list) {
      SortSorted(cmp, list);
      forall i | 0 <= i < |list|
        ensures List.filter(y => cmp(y, list[i]) == 0, insertionSort(cmp, list)) ==
                List.filter(y => cmp(y, list[i]) == 0, list)
      { SortStable(cmp, list, list, list[i]); }
    }
  }

  lemma SortStable<T>(cmp: (T, T) -> int, u: seq<T>, list: seq<T>, z: T)
    requires Laws(cmp, u)
    requires z in u && forall y :: y in list ==> y in u
    ensures List.filter(y => cmp(y, z) == 0, insertionSort(cmp, list)) ==
            List.filter(y => cmp(y, z) == 0, list)
  {
    if |list| > 0 {
      assert forall y :: y in list[1..] ==> y in list;
      SortStable(cmp, u, list[1..], z);
      SortElements(cmp, list[1..]);
      assert list[0] in list;
      InsertStable(cmp, u, list[0], insertionSort(cmp, list[1..]), z);
      assert list == [list[0]] + list[1..];
    }
  }

  lemma FilterCongruent<T>(p: T -> bool, q: T -> bool, s: seq<T>)
    requires forall y :: y in s ==> p(y) == q(y)
    ensures List.filter(p, s) == List.filter(q, s)
  {
    if |s| > 0 { FilterCongruent(p, q, s[1..]); }
  }
}
