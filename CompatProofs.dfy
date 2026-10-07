// Ramdaf v0.6.0 -> v0.7.0: difference and differenceWith become one loop each
// (push first[idx] unless it is in second or already in the output) instead of
// uniq / uniqWith of a reject; the results are the same. Both obligations are on
// the SHADOW route (CMP-19: their ensures, which name the functions themselves,
// no longer force Old.F == F), so the proofs show the NEW functions satisfy the
// OLD defining equations, by induction on `first`. The fact Dafny cannot find
// on its own is that the head-recursive List.filter (under reject) also peels
// the LAST element (FilterSnoc), which the new back-recursive bodies need.
module CompatProofs {
  import Ramdaf.List
  import Ramdaf.Data
  import DpackOldVocab_S_Ramdaf_Data
  import DpackNewVocab_S_Ramdaf_Data

  lemma {:induction false} FilterSnoc<T>(p: T -> bool, s: seq<T>)
    requires |s| > 0
    ensures List.filter(p, s) == List.filter(p, s[..|s| - 1]) + (if p(s[|s| - 1]) then [s[|s| - 1]] else [])
    decreases |s|
  {
    var u := s[..|s| - 1];
    var x := s[|s| - 1];
    var tail := if p(x) then [x] else [];
    if |s| == 1 {
      assert s[1..] == [];
      assert u == [];
      calc {
        List.filter(p, s);
        if p(s[0]) then [s[0]] + List.filter(p, s[1..]) else List.filter(p, s[1..]);
        { assert List.filter(p, s[1..]) == List.filter(p, []); }
        tail;
      }
    } else {
      var t := s[1..];
      FilterSnoc(p, t);
      assert t[..|t| - 1] == u[1..];
      assert t[|t| - 1] == x;
      assert u[0] == s[0];
      calc {
        List.filter(p, s);
        if p(s[0]) then [s[0]] + List.filter(p, t) else List.filter(p, t);
        if p(s[0]) then [s[0]] + (List.filter(p, u[1..]) + tail) else List.filter(p, u[1..]) + tail;
        (if p(u[0]) then [u[0]] + List.filter(p, u[1..]) else List.filter(p, u[1..])) + tail;
        List.filter(p, u) + tail;
      }
    }
  }

  lemma RejectSnoc<T>(fn: T -> bool, s: seq<T>)
    requires |s| > 0
    ensures List.reject(fn, s) == List.reject(fn, s[..|s| - 1]) + (if fn(s[|s| - 1]) then [] else [s[|s| - 1]])
  {
    forall p: T -> bool
      ensures List.filter(p, s) == List.filter(p, s[..|s| - 1]) + (if p(s[|s| - 1]) then [s[|s| - 1]] else [])
    { FilterSnoc(p, s); }
  }

  lemma {:isolate_assertions} UniqRejectSnoc<T(==)>(fn: T -> bool, s: seq<T>)
    requires |s| > 0
    ensures List.uniq(List.reject(fn, s)) ==
      (var r := List.uniq(List.reject(fn, s[..|s| - 1]));
       if !fn(s[|s| - 1]) && s[|s| - 1] !in r then r + [s[|s| - 1]] else r)
  {
    RejectSnoc(fn, s);
    var x := s[|s| - 1];
    var k0 := List.reject(fn, s[..|s| - 1]);
    var r := List.uniq(k0);
    if fn(x) {
      assert List.reject(fn, s) == k0;
    } else {
      var k := k0 + [x];
      assert List.reject(fn, s) == k;
      assert k[..|k| - 1] == k0;
      assert k[|k| - 1] == x;
      assert List.uniq(k) == (if x in r then r else r + [x]);
    }
  }

  lemma {:isolate_assertions} UniqWithRejectSnoc<T>(pred: (T, T) -> bool, fn: T -> bool, s: seq<T>)
    requires |s| > 0
    ensures List.uniqWith(pred, List.reject(fn, s)) ==
      (var r := List.uniqWith(pred, List.reject(fn, s[..|s| - 1]));
       if !fn(s[|s| - 1]) && !List.containsWith(pred, s[|s| - 1], r) then r + [s[|s| - 1]] else r)
  {
    RejectSnoc(fn, s);
    var x := s[|s| - 1];
    var k0 := List.reject(fn, s[..|s| - 1]);
    var r := List.uniqWith(pred, k0);
    if fn(x) {
      assert List.reject(fn, s) == k0;
    } else {
      var k := k0 + [x];
      assert List.reject(fn, s) == k;
      assert k[..|k| - 1] == k0;
      assert k[|k| - 1] == x;
      assert List.uniqWith(pred, k) == (if List.containsWith(pred, x, r) then r else r + [x]);
    }
  }

  lemma DifferenceOld<T(==)>(first: seq<T>, second: seq<T>)
    ensures Data.difference(first, second) == DpackOldVocab_S_Ramdaf_Data.difference_Body(first, second)
    decreases |first|
  {
    if |first| > 0 {
      DifferenceOld(first[..|first| - 1], second);
      forall fn: T -> bool ensures List.uniq(List.reject(fn, first)) ==
        (var r := List.uniq(List.reject(fn, first[..|first| - 1]));
         if !fn(first[|first| - 1]) && first[|first| - 1] !in r then r + [first[|first| - 1]] else r)
      { UniqRejectSnoc(fn, first); }
    }
  }

  lemma Ramdaf_Data_difference_BodyEquivalent_Manual<T(==)>(first: seq<T>, second: seq<T>)
    ensures DpackOldVocab_S_Ramdaf_Data.difference_Body(first, second) == DpackNewVocab_S_Ramdaf_Data.difference_Body(first, second)
  { DifferenceOld(first, second); }

  lemma DifferenceWithOld<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>)
    ensures Data.differenceWith(pred, first, second) == DpackOldVocab_S_Ramdaf_Data.differenceWith_Body(pred, first, second)
    decreases |first|
  {
    if |first| > 0 {
      DifferenceWithOld(pred, first[..|first| - 1], second);
      forall fn: T -> bool ensures List.uniqWith(pred, List.reject(fn, first)) ==
        (var r := List.uniqWith(pred, List.reject(fn, first[..|first| - 1]));
         if !fn(first[|first| - 1]) && !List.containsWith(pred, first[|first| - 1], r) then r + [first[|first| - 1]] else r)
      { UniqWithRejectSnoc(pred, fn, first); }
    }
  }

  lemma Ramdaf_Data_differenceWith_BodyEquivalent_Manual<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>)
    ensures DpackOldVocab_S_Ramdaf_Data.differenceWith_Body(pred, first, second) == DpackNewVocab_S_Ramdaf_Data.differenceWith_Body(pred, first, second)
  { DifferenceWithOld(pred, first, second); }
}
