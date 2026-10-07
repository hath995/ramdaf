// Ramdaf: Ramda v0.30.1 `source/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "String Functions" section; from v0.9.0 on, the functions
// with `@category String`. (v0.9.0 renamed `toUpperCase` and `toLowerCase`
// to `toUpper` and `toLower`; v0.14.0 removed `charAt` and `charCodeAt`,
// deprecated since v0.12.0 for `nthChar` and `nthCharCode`; v0.16.0 removed
// `substring`, `substringFrom`, `substringTo`, `strIndexOf` and
// `strLastIndexOf`, deprecated since v0.15.0 for `slice`, `indexOf` and
// `lastIndexOf`, which work on strings; v0.18.0 removed `nthChar` and
// `nthCharCode` (v0.12.0), deprecated since v0.16.0, when `nth` began to
// work on strings.) The String.prototype methods, with JS's index clamping.
// A Dafny `string` is a sequence of Unicode scalar values where JS counts
// UTF-16 code units, and case conversion is ASCII-only (see README
// "Deviations").

module Ramdaf.String {
  export
    reveals toUpper, toLower, trim, replace, split

  // `R.toUpper = invoker(0, 'toUpperCase')` (v0.9.0, which renamed
  // `toUpperCase` with the same code): `String.prototype.toUpperCase()`,
  // ASCII letters only.
  function toUpper(s: string): string
    ensures |toUpper(s)| == |s|
  { if |s| == 0 then ""
    else [if 'a' <= s[0] <= 'z' then (s[0] as int - 32) as char else s[0]] + toUpper(s[1..]) }

  // `R.toLower = invoker(0, 'toLowerCase')` (v0.9.0, `toLowerCase`
  // renamed): `String.prototype.toLowerCase()`, ASCII letters only.
  function toLower(s: string): string
    ensures |toLower(s)| == |s|
  { if |s| == 0 then ""
    else [if 'A' <= s[0] <= 'Z' then (s[0] as int + 32) as char else s[0]] + toLower(s[1..]) }

  // `R.trim(str)` (v0.6.0): `String.prototype.trim` when it strips every
  // character of `ws` and not U+200B (the zero-width space), and otherwise
  // the fallback `str.replace(/^[ws][ws]*/, '').replace(/[ws][ws]*$/, '')`:
  // the leading and then the trailing run of the 25 characters below
  // removed. Since v0.27.2 (94d05703, "Security fix for ReDoS") `ws` lacks
  // U+180E, so node uses its own trim, which strips exactly these 25
  // (`trim('\u180Ea')` is '\u180Ea'). Until v0.27.1 `ws` had 26 characters,
  // U+180E among them (a format character since Unicode 6.3), which node's
  // trim does not strip, so node ran the fallback, and U+180E was stripped
  // ('a'). All 25 are in the BMP, so code points and UTF-16 code units agree
  // here.
  function trim(s: string): string
    decreases |s|
  { var ws := "\t\n\U{000B}\U{000C}\r \U{00A0}\U{1680}\U{2000}\U{2001}\U{2002}\U{2003}\U{2004}\U{2005}\U{2006}\U{2007}\U{2008}\U{2009}\U{200A}\U{202F}\U{205F}\U{3000}\U{2028}\U{2029}\U{FEFF}";
    if |s| > 0 && s[0] in ws then trim(s[1..])
    else if |s| > 0 && s[|s| - 1] in ws then trim(s[..|s| - 1])
    else s }

  // `R.replace(pattern, replacement, str)` (v0.7.0): `str.replace(pattern,
  // replacement)` with a string pattern (a RegExp pattern or a function
  // replacement is not portable, README "Deviations"): the FIRST occurrence
  // of pattern is replaced, and in the replacement `$$` is `$`, `$&` the
  // match, `` $` `` the text before it and `$'` the text after it
  // (GetSubstitution; a string pattern has no captures, so `$1`, `$<` and any
  // other `$` stay literal). The first occurrence is at the length of
  // `split(pattern, str)`'s first piece, when there is more than one piece
  // (an empty pattern occurs at 0); until v0.15.1 the body found it with the
  // exported `strIndexOf`, which v0.16.0 removed, and the postconditions
  // named it. The body expands the replacement one token at a time, left to
  // right, recursing on the rest of the replacement.
  function replace(pattern: string, replacement: string, str: string): string
    ensures (forall j :: 0 <= j <= |str| ==> !(pattern <= str[j..])) ==>
      replace(pattern, replacement, str) == str
    ensures forall i :: 0 <= i <= |str| && pattern <= str[i..] &&
                        (forall j :: 0 <= j < i ==> !(pattern <= str[j..])) ==>
      str[..i] <= replace(pattern, replacement, str)
    decreases |replacement|
  { var parts := split(pattern, str);
    if |pattern| > 0 && |parts| == 1 then str
    else
      var i := if |pattern| == 0 then 0 else |parts[0]|;
      assert pattern <= str[i..] && forall j :: 0 <= j < i ==> !(pattern <= str[j..]);
      var before, after := str[..i], str[i + |pattern|..];
      if |replacement| == 0 then before + after
      else
        var r := replacement;
        var special := |r| >= 2 && r[0] == '$' && r[1] in "$&`'";
        var piece := if !special then [r[0]]
                     else if r[1] == '$' then "$"
                     else if r[1] == '&' then pattern
                     else if r[1] == '`' then before
                     else after;
        var rest := replace(pattern, if special then r[2..] else r[1..], str);
        before + piece + rest[|before|..] }

  // `String.prototype.split(sep)`: the pieces between occurrences of sep,
  // found left to right; an empty separator splits into single characters
  // (and "" into []). The body cuts at s's start when sep is a prefix of it,
  // and otherwise puts s's first character at the start of the first piece
  // of the rest (until v0.15.1 it found the first occurrence with the
  // exported `strIndexOf`, which v0.16.0 removed; the pieces are the same).
  function split(sep: string, s: string): seq<string>
    decreases |s|
    ensures |sep| > 0 ==> |split(sep, s)| > 0 && split(sep, s)[0] <= s
    ensures |sep| > 0 ==> forall j :: 0 <= j < |split(sep, s)[0]| ==> !(sep <= s[j..])
    ensures |sep| > 0 && |split(sep, s)| > 1 ==>
      |split(sep, s)[0]| + |sep| <= |s| && sep <= s[|split(sep, s)[0]|..]
    ensures |sep| > 0 && |split(sep, s)| == 1 ==> forall j :: 0 <= j <= |s| ==> !(sep <= s[j..])
  { if |sep| == 0 then (if |s| == 0 then [] else [[s[0]]] + split(sep, s[1..]))
    else if sep <= s then [""] + split(sep, s[|sep|..])
    else if |s| == 0 then [""]
    else
      var r := split(sep, s[1..]);
      assert forall j :: 1 <= j <= |s| ==> s[j..] == s[1..][j - 1..];
      [[s[0]] + r[0]] + r[1..] }
}
