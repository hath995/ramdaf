// Ramdaf v0.2.4 -> v0.3.0: groupBy stops being partition's alias and carries
// partition's old body itself, while partition changes signature (a pair of
// lists by a predicate). The obligation is on the DIRECT route,
// Old.groupBy == groupBy, since the old body names partition, whose signature
// changed. Old partition and new groupBy are the same map of filters; what an
// empty proof cannot see is that Old's filter and the new one, two copies of
// one recursive function, agree.
module CompatProofs {
  import Ramdaf.List
  import Ramdaf.Data
  import OL = Old.Ramdaf.List
  import OD = Old.Ramdaf.Data

  lemma FilterEq<T>(p: T -> bool, s: seq<T>)
    ensures OL.filter(p, s) == List.filter(p, s)
    decreases |s|
  {
    if |s| > 0 { FilterEq(p, s[1..]); }
  }

  lemma Ramdaf_Data_groupBy_BodyEquivalent_Manual<T>(fn: T -> string, list: seq<T>)
    ensures OD.groupBy<T>(fn, list) == Data.groupBy<T>(fn, list)
  {
    var A := OD.groupBy(fn, list);
    var B := Data.groupBy(fn, list);
    assert A == OL.partition(fn, list);
    forall p: T -> bool ensures OL.filter(p, list) == List.filter(p, list) { FilterEq(p, list); }
    assert A.Keys == B.Keys;
    forall k | k in A ensures A[k] == B[k] { }
  }
}
