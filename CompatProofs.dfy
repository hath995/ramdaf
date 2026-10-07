// Bridge for Ramdaf.Data.countBy, v0.20.1 -> v0.21.0 (shadow path).
// Old body: the map from each key fn produces to |List.filter(x => fn(x) == k, list)|.
// New body: List.reduceBy((acc, elem) => acc + 1, 0, fn, list), a left fold.
// The new function satisfies the old defining equation, by induction on the
// list from the right (List.reduce's ensures peels the last element; the
// head-recursive List.filter needs FilterSnocLen to do the same).
module CompatProofs {
  import Ramdaf.List
  import DpackOldVocab_S_Ramdaf_Data
  import DpackNewVocab_S_Ramdaf_Data

  function Bump(M: map<string, nat>, k: string): map<string, nat>
  { M[k := (if k in M then M[k] else 0) + 1] }

  lemma {:induction false} FilterSnocLen<T>(p: T -> bool, s: seq<T>)
    requires |s| > 0
    ensures |List.filter(p, s)| == |List.filter(p, s[..|s| - 1])| + (if p(s[|s| - 1]) then 1 else 0)
    decreases |s|
  {
    if |s| == 1 {
      assert s[..0] == [];
      assert s[1..] == [];
    } else {
      var t := s[1..];
      FilterSnocLen(p, t);
      assert t[..|t| - 1] == s[..|s| - 1][1..];
      assert t[|t| - 1] == s[|s| - 1];
    }
  }

  lemma {:induction false} ReduceBySnoc<T, A>(valueFn: (A, T) -> A, valueAcc: A, keyFn: T -> string, list: seq<T>)
    requires |list| > 0
    ensures List.reduceBy(valueFn, valueAcc, keyFn, list)
         == (var M := List.reduceBy(valueFn, valueAcc, keyFn, list[..|list| - 1]);
             var k := keyFn(list[|list| - 1]);
             M[k := valueFn(if k in M then M[k] else valueAcc, list[|list| - 1])])
  {
    var F := (acc: map<string, A>, elt: T) =>
      acc[keyFn(elt) := valueFn(if keyFn(elt) in acc then acc[keyFn(elt)] else valueAcc, elt)];
    assert List.reduceBy(valueFn, valueAcc, keyFn, list) == List.reduce(F, map[], list);
    assert List.reduceBy(valueFn, valueAcc, keyFn, list[..|list| - 1]) == List.reduce(F, map[], list[..|list| - 1]);
    assert List.reduce(F, map[], list) == F(List.reduce(F, map[], list[..|list| - 1]), list[|list| - 1]);
  }

  lemma {:induction false} NewSnoc<T>(fn: T -> string, list: seq<T>)
    requires |list| > 0
    ensures DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list)
         == Bump(DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list[..|list| - 1]), fn(list[|list| - 1]))
  {
    var V := (acc: nat, elem: T) => acc + 1;
    assert DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list) == List.reduceBy<T, nat>(V, 0, fn, list);
    assert DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list[..|list| - 1]) == List.reduceBy<T, nat>(V, 0, fn, list[..|list| - 1]);
    ReduceBySnoc<T, nat>(V, 0, fn, list);
    var M := List.reduceBy<T, nat>(V, 0, fn, list[..|list| - 1]);
    var k := fn(list[|list| - 1]);
    var c: nat := if k in M then M[k] else 0;
    assert V(c, list[|list| - 1]) == c + 1;
    assert List.reduceBy<T, nat>(V, 0, fn, list) == M[k := c + 1];
    assert Bump(M, k) == M[k := c + 1];
  }

  lemma {:induction false} OldSnoc<T>(fn: T -> string, list: seq<T>)
    requires |list| > 0
    ensures DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, list)
         == Bump(DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, list[..|list| - 1]), fn(list[|list| - 1]))
  {
    var init := list[..|list| - 1];
    var last := list[|list| - 1];
    forall p: T -> bool
      ensures |List.filter(p, list)| == |List.filter(p, init)| + (if p(last) then 1 else 0)
    { FilterSnocLen(p, list); }
    var M := DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, init);
    var k := fn(last);
    var N := Bump(M, k);
    var O := DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, list);
    var keysI := set i | 0 <= i < |init| :: fn(init[i]);
    var keysL := set i | 0 <= i < |list| :: fn(list[i]);
    assert keysL == keysI + {k} by {
      forall j | 0 <= j < |init| ensures fn(init[j]) in keysL { assert init[j] == list[j]; }
      assert k == fn(list[|list| - 1]);
    }
    assert O.Keys == N.Keys;
    forall k' | k' in O ensures O[k'] == N[k'] {
      var fk := List.filter(x => fn(x) == k', init);
      if k' !in M {
        if |fk| > 0 {
          assert fk[0] in init;
          var j :| 0 <= j < |init| && init[j] == fk[0];
          assert fn(init[j]) in keysI;
        }
      }
    }
  }

  lemma {:induction false} CountByOld<T>(fn: T -> string, list: seq<T>)
    ensures DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, list) == DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list)
    decreases |list|
  {
    if |list| > 0 {
      CountByOld(fn, list[..|list| - 1]);
      OldSnoc(fn, list);
      NewSnoc(fn, list);
    }
  }

  lemma Ramdaf_Data_countBy_BodyEquivalent_Manual<T>(fn: T -> string, list: seq<T>)
    ensures DpackOldVocab_S_Ramdaf_Data.countBy_Body(fn, list) == DpackNewVocab_S_Ramdaf_Data.countBy_Body(fn, list)
  { CountByOld(fn, list); }
}
