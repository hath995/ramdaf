// Ramdaf v0.27.2 -> v0.28.0: contains is removed, and without, which was
// reject(x => contains(x, xs), list), now calls includes, the same `a in list`.
// The obligation is on the DIRECT route (the old body names the removed
// contains): Old.without == without. The two rejects filter with predicates
// that agree pointwise; what an empty proof cannot see is that Old's filter
// and the new one, two copies of one recursive function, agree for such
// predicates. Stated for ALL pointwise-equal pairs, so Z3 instantiates it with
// the lambdas inside the two rejects, which cannot be named here.
module CompatProofs {
  import Ramdaf.List
  import OL = Old.Ramdaf.List

  lemma FilterEq<T>(p: T -> bool, q: T -> bool, s: seq<T>)
    requires forall x :: p(x) == q(x)
    ensures OL.filter(p, s) == List.filter(q, s)
    decreases |s|
  {
    if |s| > 0 { FilterEq(p, q, s[1..]); }
  }

  lemma Ramdaf_List_without_BodyEquivalent_Manual<T(==)>(xs: seq<T>, list: seq<T>)
    ensures OL.without<T>(xs, list) == List.without<T>(xs, list)
  {
    forall p: T -> bool, q: T -> bool | forall x :: p(x) == q(x)
      ensures OL.filter(p, list) == List.filter(q, list)
    { FilterEq(p, q, list); }
  }
}
