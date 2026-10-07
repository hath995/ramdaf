// Bridge for Ramdaf.List.commuteMap, v0.8.0 -> v0.9.0 (DIRECT route:
// `ensures Old.Ramdaf.List.commuteMap(fn, of, list) ==
// Ramdaf.List.commuteMap(fn, of, list)`). The old body folds with
// Old's `reduce`, the new one with the new `foldl`; both are the same
// front-recursive left fold, and the step functions agree pointwise once
// Old's `ap`/`mapSeq` are shown equal to the new ones.
module CompatProofs {
  import Old
  import Ramdaf.List
  import OL = Old.Ramdaf.List

  // Old reduce and new foldl agree for pointwise-equal step functions.
  lemma ReduceFoldl<A, B>(f: (A, B) -> A, g: (A, B) -> A, acc: A, s: seq<B>)
    requires forall a: A, x: B :: f(a, x) == g(a, x)
    ensures OL.reduce(f, acc, s) == List.foldl(g, acc, s)
    decreases |s|
  {
    if |s| > 0 {
      ReduceFoldl(f, g, f(acc, s[0]), s[1..]);
    }
  }

  lemma MapSeqEq<A, B>(fn: A -> B, vs: seq<A>)
    ensures OL.mapSeq(fn, vs) == List.mapSeq(fn, vs)
  {}

  lemma ApEq<A, B>(fns: seq<A -> B>, vs: seq<A>)
    ensures OL.ap(fns, vs) == List.ap(fns, vs)
  {
    var f := (acc: seq<B>, fn: A -> B) => acc + OL.mapSeq(fn, vs);
    var g := (acc: seq<B>, fn: A -> B) => acc + List.mapSeq(fn, vs);
    forall acc: seq<B>, fn: A -> B ensures f(acc, fn) == g(acc, fn) {
      MapSeqEq(fn, vs);
    }
    ReduceFoldl(f, g, [], fns);
  }

  lemma Ramdaf_List_commuteMap_BodyEquivalent_Manual<A, B>(fn: seq<A> -> seq<B>, of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>)
    ensures OL.commuteMap(fn, of, list) == List.commuteMap(fn, of, list)
  {
    var f := (acc: seq<seq<B>>, ftor: seq<A>) => OL.ap(OL.mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc);
    var g := (acc: seq<seq<B>>, ftor: seq<A>) => List.ap(List.mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc);
    forall acc: seq<seq<B>>, ftor: seq<A> ensures f(acc, ftor) == g(acc, ftor) {
      var h := (x: B) => ((l: seq<B>) => l + [x]);
      MapSeqEq(h, fn(ftor));
      ApEq(List.mapSeq(h, fn(ftor)), acc);
    }
    ReduceFoldl(f, g, of([]), list);
  }
}
