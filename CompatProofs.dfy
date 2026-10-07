// Ramdaf v0.22.1 -> v0.23.0: reduceRight's callback now takes (element,
// accumulator) where it took (accumulator, element), a real break, and
// sequence passes it the same step with its parameters swapped to match, so
// sequence's results are unchanged (and traverse's, which calls sequence).
// The obligation is on the DIRECT route (Old.sequence == sequence, since the
// old body names reduceRight, whose signature changed). Old reduceRight
// computes f(fold of the rest, x0) and the new one g(x0, fold of the rest),
// so the folds agree when g(x, a) == f(a, x); the steps call ap, unchanged,
// but two copies of it (and of the recursive reduce under it).
module CompatProofs {
  import Ramdaf.List
  import OL = Old.Ramdaf.List

  lemma ReduceEq<A, B>(f: (A, B) -> A, g: (A, B) -> A, acc: A, s: seq<B>)
    requires forall a: A, x: B :: f(a, x) == g(a, x)
    ensures OL.reduce(f, acc, s) == List.reduce(g, acc, s)
    decreases |s|
  {
    if |s| > 0 {
      ReduceEq(f, g, f(acc, s[0]), s[1..]);
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
    ReduceEq(f, g, [], fns);
  }

  // The old right fold with an (acc, x) step and the new one with the same
  // step taking (x, acc).
  lemma RightFoldSwapped<A, B>(f: (A, B) -> A, g: (B, A) -> A, acc: A, s: seq<B>)
    requires forall a: A, x: B :: f(a, x) == g(x, a)
    ensures OL.reduceRight(f, acc, s) == List.reduceRight(g, acc, s)
    decreases |s|
  {
    if |s| > 0 {
      RightFoldSwapped(f, g, acc, s[1..]);
    }
  }

  lemma Ramdaf_List_sequence_BodyEquivalent_Manual<A>(of: seq<A> -> seq<seq<A>>, traversable: seq<seq<A>>)
    ensures OL.sequence<A>(of, traversable) == List.sequence<A>(of, traversable)
  {
    var f := (acc: seq<seq<A>>, x: seq<A>) => OL.ap(OL.mapSeq((y: A) => ((l: seq<A>) => [y] + l), x), acc);
    var g := (x: seq<A>, acc: seq<seq<A>>) => List.ap(List.mapSeq((y: A) => ((l: seq<A>) => [y] + l), x), acc);
    forall acc: seq<seq<A>>, x: seq<A> ensures f(acc, x) == g(x, acc) {
      var h := (y: A) => ((l: seq<A>) => [y] + l);
      MapSeqEq(h, x);
      ApEq(List.mapSeq(h, x), acc);
    }
    RightFoldSwapped(f, g, of([]), traversable);
  }
}
