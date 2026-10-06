// Ramdaf: Ramda v0.1.1 "String Functions" (ramda.js lines 1339-1404): the
// String.prototype methods, with JS's index clamping. A Dafny `string` is a
// sequence of Unicode scalar values where JS counts UTF-16 code units, and
// case conversion is ASCII-only (see README "Deviations").

module Ramdaf.String {
  export
    reveals substring, substringFrom, substringTo, charAt, charCodeAt,
            strIndexOf, strLastIndexOf, toUpperCase, toLowerCase, split

  // `String.prototype.substring(start, end)`: each index is clamped to
  // [0, |s|], and the two are swapped when start > end.
  function substring(start: int, end: int, s: string): string
    ensures |substring(start, end, s)| <= |s|
  { var a := if start < 0 then 0 else if start > |s| then |s| else start;
    var b := if end < 0 then 0 else if end > |s| then |s| else end;
    if a <= b then s[a..b] else s[b..a] }

  // `flip(substring)(undefined)`: `substringFrom(n, s) == s.substring(n)`
  function substringFrom(n: int, s: string): string { substring(n, |s|, s) }

  // `substring(0)`: `substringTo(n, s) == s.substring(0, n)`
  function substringTo(n: int, s: string): string { substring(0, n, s) }

  // `String.prototype.charAt(n)`: the empty string when n is out of range.
  function charAt(n: int, s: string): string
  { if 0 <= n < |s| then [s[n]] else "" }

  // `String.prototype.charCodeAt(n)`: NaN when n is out of range, which int
  // cannot hold, so out-of-range indices are excluded.
  function charCodeAt(n: int, s: string): int
    requires 0 <= n < |s|
  { s[n] as int }

  // `String.prototype.indexOf(sub)`: the first index where sub occurs, or -1.
  // (`sub <= t` is Dafny's prefix test: sub occurs at i iff `sub <= s[i..]`.)
  function strIndexOf(sub: string, s: string): int
    ensures strIndexOf(sub, s) == -1 ||
      (0 <= strIndexOf(sub, s) <= |s| && sub <= s[strIndexOf(sub, s)..])
    ensures forall i :: 0 <= i <= |s| && sub <= s[i..] ==> 0 <= strIndexOf(sub, s) <= i
  { if |sub| > |s| then -1
    else if sub <= s then 0
    else var r := strIndexOf(sub, s[1..]);
         assert forall i :: 1 <= i <= |s| ==> s[i..] == s[1..][i - 1..];
         if r < 0 then -1 else r + 1 }

  // `String.prototype.lastIndexOf(sub)`: the last index where sub occurs, or
  // -1 (so `strLastIndexOf("", s) == |s|`).
  function strLastIndexOf(sub: string, s: string): int
    ensures strLastIndexOf(sub, s) == -1 ||
      (0 <= strLastIndexOf(sub, s) <= |s| && sub <= s[strLastIndexOf(sub, s)..])
    ensures forall i :: 0 <= i <= |s| && sub <= s[i..] ==> i <= strLastIndexOf(sub, s)
  { if |sub| > |s| then -1
    else if |s| == 0 then 0
    else var r := strLastIndexOf(sub, s[1..]);
         assert forall i :: 1 <= i <= |s| ==> s[i..] == s[1..][i - 1..];
         if r >= 0 then r + 1 else if sub <= s then 0 else -1 }

  // `String.prototype.toUpperCase()`, ASCII letters only.
  function toUpperCase(s: string): string
    ensures |toUpperCase(s)| == |s|
  { if |s| == 0 then ""
    else [if 'a' <= s[0] <= 'z' then (s[0] as int - 32) as char else s[0]] + toUpperCase(s[1..]) }

  // `String.prototype.toLowerCase()`, ASCII letters only.
  function toLowerCase(s: string): string
    ensures |toLowerCase(s)| == |s|
  { if |s| == 0 then ""
    else [if 'A' <= s[0] <= 'Z' then (s[0] as int + 32) as char else s[0]] + toLowerCase(s[1..]) }

  // `String.prototype.split(sep)`: the pieces between occurrences of sep;
  // an empty separator splits into single characters (and "" into []).
  function split(sep: string, s: string): seq<string>
    decreases |s|
  { if |sep| == 0 then (if |s| == 0 then [] else [[s[0]]] + split(sep, s[1..]))
    else var i := strIndexOf(sep, s);
         if i < 0 then [s] else [s[..i]] + split(sep, s[i + |sep|..]) }
}
