// Ramdaf v0.13.0 -> v0.14.0: differenceWith writes each kept element at the
// end of the output again (out[out.length], f5966efd), so the port drops the
// kept-prefix precondition it needed for v0.11.0's holes. The body is the same
// recursion; only the precondition (and the asserts it needed) went. The
// obligation is on the DIRECT route (the precondition changed and the old
// ensures names differenceWith), under both preconditions: Old's recursion and
// the new one agree on the old domain, by induction on first, once Old's
// containsWith and the new one (the same `exists`) are equated.
module CompatProofs {
  import Ramdaf.List
  import Ramdaf.Data
  import OL = Old.Ramdaf.List
  import OD = Old.Ramdaf.Data

  lemma ContainsWithEq<T>(pred: (T, T) -> bool, x: T, s: seq<T>)
    ensures OL.containsWith(pred, x, s) == List.containsWith(pred, x, s)
  {}

  lemma {:induction false} DifferenceWithAgrees<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>)
    requires OD.differenceWith<T>.requires(pred, first, second)
    ensures OD.differenceWith<T>(pred, first, second) == Data.differenceWith<T>(pred, first, second)
    decreases |first|
  {
    if |first| > 0 {
      var init := first[..|first| - 1];
      var x := first[|first| - 1];
      assert forall i :: 0 <= i < |init| ==> init[i] == first[i];
      assert forall i :: 0 <= i <= |init| ==> init[..i] == first[..i];
      assert OD.differenceWith<T>.requires(pred, init, second);
      DifferenceWithAgrees(pred, init, second);
      ContainsWithEq(pred, x, second);
      ContainsWithEq(pred, x, Data.differenceWith(pred, init, second));
    }
  }

  lemma Ramdaf_Data_differenceWith_BodyEquivalent_Manual<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>)
    requires OD.differenceWith<T>.requires(pred, first, second) && Data.differenceWith<T>.requires(pred, first, second)
    ensures OD.differenceWith<T>(pred, first, second) == Data.differenceWith<T>(pred, first, second)
  { DifferenceWithAgrees(pred, first, second); }
}
