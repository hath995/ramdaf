// Test support: a JS value type for transcribing Ramda tests whose arrays and
// objects mix types, and integer-to-string conversion (JS `'' + n`).

module RamdafTests.Support {
  datatype Js =
    | Undefined
    | Null
    | Bool(b: bool)
    | Num(n: int)
    | Str(s: string)
    | Arr(items: seq<Js>)
    | Obj(props: map<string, Js>)

  function NumStr(n: int): string
    decreases if n < 0 then 1 - n else n
  {
    if n < 0 then "-" + NumStr(-n)
    else if n < 10 then [('0' as int + n) as char]
    else NumStr(n / 10) + NumStr(n % 10)
  }

  // `o.x` for a test object, 0 when absent.
  function Field(o: map<string, int>, k: string): int { if k in o then o[k] else 0 }
}
