// Bridge for Ramda v0.15.1 -> v0.16.0: commute went from
// commuteMap(xs => mapSeq(x => x, xs), of, list) to commuteMap(xs => xs, of, list).
// The obligation is stated over the shadow (vocabulary) modules, whose lambdas
// cannot be named here, so the helper facts are stated for ALL functions that
// agree pointwise and Z3 instantiates them with the shadows' lambdas.
module CompatProofs {
  import Ramdaf.List
  import Ramdaf
  import Old
  import DpackOldVocab_S_Ramdaf_List
  import DpackNewVocab_S_Ramdaf_List

  // commuteMap only looks at fn on the elements of list.
  lemma CommuteMapCongruent<A, B>(f1: seq<A> -> seq<B>, f2: seq<A> -> seq<B>,
                                  of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>)
    requires forall xs :: xs in list ==> f1(xs) == f2(xs)
    ensures List.commuteMap(f1, of, list) == List.commuteMap(f2, of, list)
    decreases |list|
  {
    if |list| > 0 {
      var init := list[..|list| - 1];
      assert forall xs :: xs in init ==> xs in list;
      CommuteMapCongruent(f1, f2, of, init);
      assert list[|list| - 1] in list;
    }
  }

  lemma CommuteMapCongruentAll<A, B>(of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>)
    ensures forall f1: seq<A> -> seq<B>, f2: seq<A> -> seq<B>
              {:trigger List.commuteMap(f1, of, list), List.commuteMap(f2, of, list)} ::
              (forall xs :: xs in list ==> f1(xs) == f2(xs)) ==>
              List.commuteMap(f1, of, list) == List.commuteMap(f2, of, list)
  {
    forall f1: seq<A> -> seq<B>, f2: seq<A> -> seq<B> | forall xs :: xs in list ==> f1(xs) == f2(xs)
      ensures List.commuteMap(f1, of, list) == List.commuteMap(f2, of, list)
    { CommuteMapCongruent(f1, f2, of, list); }
  }

  // map(identity) is the identity, for any function that is pointwise the identity.
  lemma MapSeqIdentity<A>(g: A -> A, xs: seq<A>)
    requires forall x :: g(x) == x
    ensures List.mapSeq(g, xs) == xs
  {}

  lemma Ramdaf_List_commute_BodyEquivalent_Manual<A>(of: seq<A> -> seq<seq<A>>, list: seq<seq<A>>)
    ensures DpackOldVocab_S_Ramdaf_List.commute_Body(of, list) == DpackNewVocab_S_Ramdaf_List.commute_Body(of, list)
  {
    forall g: A -> A, xs: seq<A> | forall x :: g(x) == x
      ensures List.mapSeq(g, xs) == xs
    { MapSeqIdentity(g, xs); }
    CommuteMapCongruentAll<A, A>(of, list);
  }

  // split (direct path, Old.split == split): the old body found the first
  // occurrence with strIndexOf; the new one peels one character at a time.
  lemma SplitAgrees(sep: string, s: string)
    ensures Old.Ramdaf.String.split(sep, s) == Ramdaf.String.split(sep, s)
    decreases |s|
  {
    if |sep| == 0 {
      if |s| > 0 { SplitAgrees(sep, s[1..]); }
    } else if sep <= s {
      assert Old.Ramdaf.String.strIndexOf(sep, s) == 0;
      assert s[..0] == "";
      SplitAgrees(sep, s[|sep|..]);
    } else if |s| == 0 {
      assert Old.Ramdaf.String.strIndexOf(sep, s) == -1;
    } else {
      SplitAgrees(sep, s[1..]);
      var i := Old.Ramdaf.String.strIndexOf(sep, s);
      var j := Old.Ramdaf.String.strIndexOf(sep, s[1..]);
      if |sep| > |s| {
        assert i == -1 && j == -1;
      } else {
        assert i == (if j < 0 then -1 else j + 1);
      }
      if j >= 0 {
        assert [s[0]] + s[1..][..j] == s[..j + 1];
        assert s[1..][j + |sep|..] == s[j + 1 + |sep|..];
      } else {
        assert [s[0]] + s[1..] == s;
      }
    }
  }

  lemma Ramdaf_String_split_BodyEquivalent_Manual(sep: string, s: string)
    ensures Old.Ramdaf.String.split(sep, s) == Ramdaf.String.split(sep, s)
  { SplitAgrees(sep, s); }
}
