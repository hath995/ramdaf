// Ramdaf v0.18.x -> v0.19.0: R.containsWith is removed, and uniqWith (body and
// postcondition) and intersectionWith (body) write it out in place:
// containsWith(pred, x, list) is `exists i :: 0 <= i < |list| && pred(x, list[i])`,
// so both are equal by definition. Both obligations are on the DIRECT route
// (their old text names the removed containsWith), so the proofs relate Old's
// copies to the new ones. uniqWith, unchanged but for that, agrees with Old's
// by induction on the prefix. For intersectionWith, both filters (Old's over
// containsWith, the new one over the written-out exists) are shown equal to
// one lambda-free recursion, Matching, for ANY predicate that agrees pointwise
// with the condition, since neither body's lambda can be named here. (Equating
// uniqWith for every list at once, instead of at Matching's result, sets off
// uniqWith's prefix-recursive ensures and timed out.)
module CompatProofs {
  import Ramdaf.List
  import Ramdaf.Data
  import OL = Old.Ramdaf.List
  import OD = Old.Ramdaf.Data
  import DpackOldVocab_Ramdaf_List
  import DpackNewVocab_Ramdaf_List

  lemma UniqWithEq<T>(pred: (T, T) -> bool, s: seq<T>)
    ensures OL.uniqWith(pred, s) == List.uniqWith(pred, s)
    decreases |s|
  {
    if |s| > 0 { UniqWithEq(pred, s[..|s| - 1]); }
  }

  // filter by "x matches some element of list2", without a lambda.
  function Matching<T>(pred: (T, T) -> bool, list2: seq<T>, s: seq<T>): seq<T>
    decreases |s|
  {
    if |s| == 0 then []
    else (if exists j :: 0 <= j < |list2| && pred(s[0], list2[j]) then [s[0]] else []) + Matching(pred, list2, s[1..])
  }

  lemma NewFilterMatching<T>(f: T -> bool, pred: (T, T) -> bool, list2: seq<T>, s: seq<T>)
    requires forall x :: f(x) == exists j :: 0 <= j < |list2| && pred(x, list2[j])
    ensures List.filter(f, s) == Matching(pred, list2, s)
    decreases |s|
  {
    if |s| > 0 { NewFilterMatching(f, pred, list2, s[1..]); }
  }

  lemma OldFilterMatching<T>(f: T -> bool, pred: (T, T) -> bool, list2: seq<T>, s: seq<T>)
    requires forall x :: f(x) == exists j :: 0 <= j < |list2| && pred(x, list2[j])
    ensures OL.filter(f, s) == Matching(pred, list2, s)
    decreases |s|
  {
    if |s| > 0 { OldFilterMatching(f, pred, list2, s[1..]); }
  }

  lemma Ramdaf_List_uniqWith_PostStrengthened_Manual<T>(pred: (T, T) -> bool, list: seq<T>, r: seq<T>)
    requires DpackNewVocab_Ramdaf_List.uniqWith_Post<T>(pred, list, r)
    ensures DpackOldVocab_Ramdaf_List.uniqWith_Post<T>(pred, list, r)
  {
    if |list| > 0 { UniqWithEq(pred, list[..|list| - 1]); }
  }

  lemma Ramdaf_Data_intersectionWith_BodyEquivalent_Manual<T>(pred: (T, T) -> bool, list1: seq<T>, list2: seq<T>)
    ensures OD.intersectionWith<T>(pred, list1, list2) == Data.intersectionWith<T>(pred, list1, list2)
  {
    var m := Matching(pred, list2, list1);
    forall f: T -> bool | forall x :: f(x) == exists j :: 0 <= j < |list2| && pred(x, list2[j])
      ensures OL.filter(f, list1) == m && List.filter(f, list1) == m
    {
      OldFilterMatching(f, pred, list2, list1);
      NewFilterMatching(f, pred, list2, list1);
    }
    UniqWithEq(pred, m);
  }
}
