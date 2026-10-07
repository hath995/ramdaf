// Ramdaf v0.9.1 -> v0.10.0: Ramda renamed `_foldl` to `_reduce` and removed
// `foldl`, so ap, chain and commuteMap fold with the new `reduce` where they
// folded with `foldl`. Old foldl and new reduce are the same front-recursive
// left fold, and each body passes the same step function, so every result is
// unchanged. All three obligations are on the DIRECT route
// (Old.F == F, since the old bodies name the removed foldl); what an empty
// proof cannot see is that two copies of a recursive fold agree.
module CompatProofs {
  import Ramdaf.List
  import OL = Old.Ramdaf.List

  // Old foldl and new reduce agree for pointwise-equal step functions.
  lemma FoldlReduce<A, B>(f: (A, B) -> A, g: (A, B) -> A, acc: A, s: seq<B>)
    requires forall a: A, x: B :: f(a, x) == g(a, x)
    ensures OL.foldl(f, acc, s) == List.reduce(g, acc, s)
    decreases |s|
  {
    if |s| > 0 {
      FoldlReduce(f, g, f(acc, s[0]), s[1..]);
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
    FoldlReduce(f, g, [], fns);
  }

  lemma Ramdaf_List_ap_BodyEquivalent_Manual<A, B>(fns: seq<A -> B>, vs: seq<A>)
    ensures OL.ap<A, B>(fns, vs) == List.ap<A, B>(fns, vs)
  { ApEq(fns, vs); }

  lemma Ramdaf_List_chain_BodyEquivalent_Manual<A, B>(f: A -> seq<B>, list: seq<A>)
    ensures OL.chain<A, B>(f, list) == List.chain<A, B>(f, list)
  {
    var h := (acc: seq<B>, xs: seq<B>) => acc + xs;
    MapSeqEq(f, list);
    FoldlReduce(h, h, [], List.mapSeq(f, list));
  }

  lemma Ramdaf_List_commuteMap_BodyEquivalent_Manual<A, B>(fn: seq<A> -> seq<B>, of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>)
    ensures OL.commuteMap<A, B>(fn, of, list) == List.commuteMap<A, B>(fn, of, list)
  {
    var f := (acc: seq<seq<B>>, ftor: seq<A>) => OL.ap(OL.mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc);
    var g := (acc: seq<seq<B>>, ftor: seq<A>) => List.ap(List.mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc);
    forall acc: seq<seq<B>>, ftor: seq<A> ensures f(acc, ftor) == g(acc, ftor) {
      var h := (x: B) => ((l: seq<B>) => l + [x]);
      MapSeqEq(h, fn(ftor));
      ApEq(List.mapSeq(h, fn(ftor)), acc);
    }
    FoldlReduce(f, g, of([]), list);
  }
}
