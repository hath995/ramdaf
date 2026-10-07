// Ramdaf v0.19.x -> v0.20.0: mergeAll was reduce((acc, obj) => acc + obj, {}, list)
// (R.merge written out) and is now its own recursion, mergeAll(init) + last,
// which is _objectAssign's loop. reduce's own ensures peels the last element,
// so the two agree by induction (shadow route: the new mergeAll satisfies the
// old defining equation). The step function is stated pointwise, since the
// old shadow's lambda cannot be named here.
module CompatProofs {
  import Ramdaf.List
  import DpackOldVocab_S_Ramdaf_List
  import DpackNewVocab_S_Ramdaf_List

  lemma ReduceUnion<V>(f: (map<string, V>, map<string, V>) -> map<string, V>, list: seq<map<string, V>>)
    requires forall a: map<string, V>, b: map<string, V> :: f(a, b) == a + b
    ensures List.reduce(f, map[], list) == List.mergeAll(list)
    decreases |list|
  {
    if |list| > 0 { ReduceUnion(f, list[..|list| - 1]); }
  }

  lemma Ramdaf_List_mergeAll_BodyEquivalent_Manual<V>(list: seq<map<string, V>>)
    ensures DpackOldVocab_S_Ramdaf_List.mergeAll_Body<V>(list) == DpackNewVocab_S_Ramdaf_List.mergeAll_Body<V>(list)
  {
    forall f: (map<string, V>, map<string, V>) -> map<string, V> | forall a: map<string, V>, b: map<string, V> :: f(a, b) == a + b
      ensures List.reduce(f, map[], list) == List.mergeAll(list)
    { ReduceUnion(f, list); }
  }
}
