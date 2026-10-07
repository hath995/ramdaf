// Ramda v0.30.0 test/always.js, T.js, F.js, compose.js, pipe.js,
// converge.js, flip.js, ap.js, juxt.js, applySpec.js, o.js, applyTo.js,
// thunkify.js, pipeWith.js, composeWith.js, promap.js and flow.js (until v0.8.0 test.always.js,
// test.compose.js and test.functionBasics.js), transcribed. A call with no
// arguments is a call with the unit value `()`. Not transcribed: the Date
// case of `always`; compose/pipe's "passes context to functions" (`this`,
// v0.2.3, which also dropped the single-function cases); compose's "returns
// a function with arity == rightmost argument" (v0.3.0; arity), and
// compose's (v0.3.0) and pipe's (v0.4.0) "throws if given no arguments" and
// "returns argument if given exactly one argument" (compose and pipe are
// binary here, and the latter checks function identity; v0.11.0 replaces it
// with "can be applied to one argument", a one-function compose or pipe and
// its arity), and v0.16.0's "is a variadic function" (arity); flip's "produces a function that throws if given no arguments"
// (v0.4.0 to v0.10.0; no-argument call);
// ap's "dispatches to the passed object's ap method" (method dispatch on a
// non-array object), the `typeof` check of its "is curried" (since v0.5.0
// the dispatch case calls `ap(obj, 10)`, on the first argument) and
// v0.18.0's "interprets ((->) r) as an applicative" (`ap` on functions; the
// port's takes lists, README "Deviations"); v0.14.0's
// converge "returns a function with the length of the "longest" argument"
// (arity), "passes context to its functions" (`this`) and the
// `f3(R.__).length` half of its "returns a curried function". The files
// of functions that are not portable (README) are not transcribed: useWith,
// once, memoize, construct, constructN, unary, binary, nAry, apply, unapply,
// composeP, pipeP, curry, curryN, op, partial, partialRight, wrap, forEach,
// forEachIndexed (until v0.15.1), installTo (until v0.11.0), path, pathOn,
// pathEq, pathOr (v0.18.0), is, propIs (v0.16.0), isArrayLike (until
// v0.23.0; v0.24.0 tests the private `_isArrayLike` in
// internal/_isArrayLike.js), type,
// functions, functionsIn, bind, invoker, lift, liftN, nthArg, and v0.9.0's
// new call.js, v0.14.0's uncurryN.js and v0.15.0's addIndex.js, and
// v0.16.0's composeK.js and pipeK.js, whose monad is an `Identity` object
// with a `chain` method, not a list (README "Deviations"); test/helpers/test.examplesRunner.js (test/ until v0.14.0) runs the JSDoc examples
// through `dox` and is not a hand-written suite. (v0.1.3 moved test.lazy.js
// out of test/, v0.4.1 removed test.always.js's "should be aliased by
// `constant`" with `constant`, and v0.9.0 removed alwaysZero's describe with
// the function and renamed the alwaysTrue and alwaysFalse describes to T and
// F; v0.10.0 renamed the files of pCompose, pPipe, lPartial and rPartial to
// composeP, pipeP, partial and partialRight with the functions; v0.11.0
// removed op.js and pathOn.js with the functions and added the unportable
// dissocPath.js, invariants.js (arity under partial application) and
// internal/_curry2.js and internal/_curry3.js; v0.12.0 removed installTo.js
// with the function and added the unportable invoke.js, into.js and
// transduce.js; v0.13.0 added isNaN.js and retitled the "is automatically
// curried" `it`s "is curried"; v0.14.0 removed func.js with the function;
// v0.15.0 removed isNaN.js with the function; v0.16.0 removed composeL.js,
// pipeL.js, arity.js and forEachIndexed.js with the functions and rewrote
// compose.js and pipe.js; v0.18.0 rewrote compose's and pipe's "performs
// right-to-left (left-to-right) function composition" again, retitled ap's
// "applies a list of functions to a list of values" "interprets [a] as an
// applicative", and passes converge's functions as one list, a pair here;
// v0.19.0 removed functions.js and functionsIn.js with the functions and
// added the unportable lensPath.js and pathSatisfies.js; v0.20.0 added the
// unportable tryCatch.js; v0.24.0 added the unportable memoizeWith.js,
// mergeDeepLeft.js, mergeDeepRight.js, mergeDeepWith.js and
// mergeDeepWithKey.js.) juxt.js's (v0.19.0) and applySpec.js's (v0.20.0)
// calls with no values pass `()`, and with several a tuple. Not
// transcribed either: v0.20.0's arity and curried `it`s, converge's "works
// with empty functions list" (no arguments; the port's converge takes a
// pair), juxt's "retains the highest arity" and "returns a curried
// function", and applySpec's "works with nested specs" (a nested spec
// object cannot be written, README "Outside the modeled domain"), "retains
// the highest arity" and "returns a curried function". o.js's (v0.24.0)
// curried calls are lambdas, and `R.map` and `R.multiply` in "performs
// right-to-left function composition" are a lambda over `mapSeq` and a
// lambda returning one; its "is not a variadic function" (arity) and the
// jsverify "o properties" are not transcribed. applyTo.js's (v0.25.0)
// curried and placeholder calls are lambdas, and its "has length 2" (arity)
// and flip.js's v0.25.0 "returns a function with the correct arity" are not
// transcribed. v0.26.0 removed the "is curried" `it`s (ap's, applyTo's),
// and the files of the unportable memoize, then and otherwise went or are
// not transcribed; thunkify.js's arity `it` is not, and its "returns a
// function that expects arguments and returns a new invoker function" is a
// `typeof` check that holds by construction. pipeWith.js and composeWith.js
// compose three functions as nested pairs (README "JS -> Dafny mapping"),
// with ParseInt below; their promise `it`s are not transcribed. promap.js
// (v0.28.0): its profunctor-dispatch `it`s (objects with `promap` and
// `fantasy-land/promap` methods) are not transcribed; on.js's only `it`
// applies `R.includes` to strings, a substring search (README
// "Deviations"); compose.js's, o.js's and flip.js's fast-check properties
// (jsverify until v0.27.2) are not transcribed.

module RamdafTests.Ramda.Functions {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Functions
  import opened Ramdaf.List
  import opened Ramdaf.Math
  import C = Ramdaf.Core
  import O = Ramdaf.Object
  import S = Ramdaf.String
  import opened Support

  // ---- always.js, T.js, F.js ----

  // describe('always')
  // (v0.5.0 adds `always()()`, whose omitted value is undefined; since
  // v0.11.0 Ramda writes `always(undefined)()`)
  method {:test} AlwaysReturnsTheValueInitiallySupplied() {
    expect always(42)(()) == 42;
    expect always(42)(10) == 42;
    expect always(42)(false) == 42;
    expect always(Undefined)(()) == Undefined;
  }
  method {:test} AlwaysWorksWithVariousTypes() {
    expect always(false)(()) == false;
    expect always("abc")(()) == "abc";
    expect always(map["a" := 1, "b" := 2])(()) == map["a" := 1, "b" := 2];
    var obj := map["a" := 1, "b" := 2];
    expect always(obj)(()) == obj;
  }

  // describe('F') and describe('T') (describe('alwaysFalse') and
  // describe('alwaysTrue') until v0.8.0)
  method {:test} FAlwaysReturnsFalse() {
    expect F(()) == false;
    expect F(10) == false;
    expect F(true) == false;
  }
  method {:test} TAlwaysReturnsTrue() {
    expect T(()) == true;
    expect T(10) == true;
    expect T(true) == true;
  }

  // ---- compose.js, pipe.js, converge.js ----

  // describe('compose'), describe('pipe'): v0.18.0's "performs
  // right-to-left (left-to-right) function composition", `f =
  // compose(R.map, R.multiply, parseInt)` (`pipe(parseInt, R.multiply,
  // R.map)`), nested here, with the curried `R.multiply(n)` and `R.map(fn)`
  // as lambdas and `parseInt(s, radix)` taking a tuple, its omitted radix
  // undefined (None, base 10); the `.length` line (arity) is not transcribed.
  // (v0.16.0 and v0.17.x composed `f(a) = [a]`, `g(a, b) = [a, b]` and `h(a,
  // b, c) = [a, b, c]`; until v0.15.1 "executes its passed in functions in
  // order from right to left (left to right)" over string functions and
  // "first function is passed multiple args".)
  function ParseInt(t: (string, Option<int>)): int
    decreases |t.0|
  { var radix := if t.1.Some? then t.1.value else 10;
    if |t.0| == 0 then 0
    else ParseInt((t.0[..|t.0| - 1], t.1)) * radix + (t.0[|t.0| - 1] as int - '0' as int) }
  function MultiplyBy(n: int): int -> int { (x: int) => multiply(n, x) }
  function MapWith(fn: int -> int): seq<int> -> seq<int> { (l: seq<int>) => mapSeq(fn, l) }

  method {:test} ComposePerformsRightToLeftFunctionComposition() {
    var f := compose(MapWith, compose(MultiplyBy, ParseInt));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  method {:test} PipePerformsLeftToRightFunctionComposition() {
    var f := pipe(ParseInt, pipe(MultiplyBy, MapWith));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  // describe('converge') (describe('fork') until v0.4.1): since v0.18.0 the
  // branching functions are one list, a pair here
  // `converge(mult, [add(1), add(3)])(2)`: mult(add1(2), add3(2)) = mult(3, 5)
  method {:test} ConvergePassesTheResultsOfTwoFunctionsIntoAThird() {
    expect converge((a: int, b: int) => a * b, ((x: int) => add(1, x), (x: int) => add(3, x)))(2) == 15;
  }

  // v0.14.0 "returns a curried function": `f2 = converge(mult, [a => a, (a,
  // b) => b])` takes two arguments (a tuple here), and `f2(6)(7)` is
  // `mult(6, 7)`; its `f3(R.__).length` checks an arity.
  method {:test} ConvergeReturnsACurriedFunction() {
    var f2 := converge((a: int, b: int) => a * b, ((p: (int, int)) => p.0, (p: (int, int)) => p.1));
    var f2Of6 := (y: int) => f2((6, y));
    expect f2Of6(7) == 42;
  }

  // ---- flip.js ----
  // The JS function takes a third argument that flip passes through; the
  // binary port keeps the two that flip swaps.

  method {:test} FlipInvertsTheFirstTwoArguments() {
    var f := (x: string, y: string) => x + " " + y;
    var g := flip(f);
    expect f("a", "b") == "a b";
    expect g("a", "b") == "b a";
  }

  method {:test} FlipReturnsACurriedFunction() {
    var f := (x: string, y: string) => x + " " + y;
    var g := (y: string) => flip(f)("a", y);
    expect g("b") == "b a";
  }

  // ---- ap.js (v0.3.0) ----

  function mult2(x: int): int { x * 2 }
  function plus3(x: int): int { x + 3 }

  method {:test} ApAppliesAListOfFunctionsToAListOfValues() {
    expect ap([mult2, plus3], [1, 2, 3]) == [2, 4, 6, 4, 5, 6];
  }

  // ---- juxt.js (v0.19.0): `hello() = 'hello'`, `bye() = 'bye'` ----
  function Hello(u: ()): string { "hello" }
  function Bye(u: ()): string { "bye" }

  method {:test} JuxtWorksWithNoFunctionsAndNoValues() {
    var none: seq<(()) -> int> := [];
    expect juxt(none)(()) == [];
  }

  method {:test} JuxtWorksWithNoFunctionsAndSomeValues() {
    var none: seq<((int, int)) -> int> := [];
    expect juxt(none)((2, 3)) == [];
  }

  method {:test} JuxtWorksWith1FunctionAndNoValues() {
    expect juxt([Hello])(()) == ["hello"];
  }

  // `R.add(3)`
  method {:test} JuxtWorksWith1FunctionAnd1Value() {
    expect juxt([(x: int) => add(3, x)])(2) == [5];
  }

  // `R.multiply` on two values
  method {:test} JuxtWorksWith1FunctionAndSomeValues() {
    expect juxt([(t: (int, int)) => multiply(t.0, t.1)])((2, 3)) == [6];
  }

  method {:test} JuxtWorksWithSomeFunctionsAndNoValues() {
    expect juxt([Hello, Bye])(()) == ["hello", "bye"];
  }

  // `R.multiply(2)`, `R.add(3)`
  method {:test} JuxtWorksWithSomeFunctionsAnd1Value() {
    expect juxt([(x: int) => multiply(2, x), (x: int) => add(3, x)])(2) == [4, 5];
  }

  // `R.add`, `R.multiply` on two values
  method {:test} JuxtWorksWithSomeFunctionsAndSomeValues() {
    expect juxt([(t: (int, int)) => add(t.0, t.1), (t: (int, int)) => multiply(t.0, t.1)])((2, 3)) == [5, 6];
  }

  // ---- applySpec.js (v0.20.0) ----

  method {:test} ApplySpecWorksWithEmptySpec() {
    var spec: map<string, (()) -> int> := map[];
    expect applySpec(spec)(()) == map[];
  }

  // `R.inc`, `R.dec`
  method {:test} ApplySpecWorksWithUnaryFunctions() {
    expect applySpec(map["v" := inc, "u" := dec])(1) == map["v" := 2, "u" := 0];
  }

  // `R.add` on two values
  method {:test} ApplySpecWorksWithBinaryFunctions() {
    expect applySpec(map["sum" := (t: (int, int)) => add(t.0, t.1)])((1, 2)) == map["sum" := 3];
  }

  // ---- o.js (v0.24.0) ----

  // `R.o(R.add(1), R.multiply(2), 10)` equals
  // `R.o(R.add(1))(R.multiply(2))(10)`
  method {:test} OIsACurriedFunction() {
    var oCurried := (f: int -> int) => ((g: int -> int) => ((x: int) => o(f, g, x)));
    expect o((x: int) => add(1, x), (x: int) => multiply(2, x), 10) ==
      oCurried((x: int) => add(1, x))((x: int) => multiply(2, x))(10);
  }

  // `f = R.o(R.map, R.multiply)`; `f(10)([1, 2, 3])`
  method {:test} OPerformsRightToLeftFunctionComposition() {
    var f := (n: int) =>
      o<int, int -> int, seq<int> -> seq<int>>((g: int -> int) => ((xs: seq<int>) => mapSeq(g, xs)),
                                               (a: int) => ((b: int) => multiply(a, b)), n);
    expect f(10)([1, 2, 3]) == [10, 20, 30];
  }

  // ---- applyTo.js (v0.25.0) ----

  // `R.applyTo(21, R.multiply(2))`
  method {:test} ApplyToAppliesTheFunctionToItsFirstArgument() {
    expect applyTo(21, (x: int) => multiply(2, x)) == 42;
  }


  // ---- applySpec.js (v0.26.0) ----

  // `R.prop('a')` on `{a: 1}`: here the spec maps to the property, None
  // when absent.
  method {:test} ApplySpecWorksWithASpecDefiningAMapKey() {
    var r := applySpec(map["map" := (o: map<string, int>) => O.prop("a", o)])(map["a" := 1]);
    expect r == map["map" := Some(1)];
  }

  // ---- thunkify.js (v0.26.0) ----

  // `thunk = R.thunkify(R.add(2))`, `thunk(40)()`
  method {:test} ThunkifyCallsTheOriginalFunctionWithTheProvidedArgumentsWhenAllWereSupplied() {
    var thunk := thunkify((x: int) => add(2, x));
    expect thunk(40)() == 42;
  }

  // ---- pipeWith.js, composeWith.js (v0.26.0) ----

  // `(f, res) => f(res)`, at the types of each nesting level
  function Applying<B, C>(f: B -> C, res: B): C { f(res) }

  // `pipeWith(applying)([parseInt, R.multiply, R.map])`, here
  // `pipeWith(applying, (pipeWith(applying, (ParseInt, MultiplyBy)), MapWith))`
  method {:test} PipeWithPerformsLeftToRightFunctionCompositionWithFunctionApplying() {
    var inner := pipeWith((f: int -> (int -> int), res: int) => Applying(f, res), (ParseInt, MultiplyBy));
    var f := pipeWith((g: (int -> int) -> (seq<int> -> seq<int>), res: int -> int) => Applying(g, res), (inner, MapWith));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  // `isOdd = R.flip(R.modulo)(2)`; `(f, res) => R.isNil(res) ? null : f(res)`
  // over `[parseInt, R.ifElse(isOdd, R.identity, R.always(null)), R.inc]`:
  // null is None, and each function returns an Option
  function WhenNotNil(f: int -> Option<int>, res: Option<int>): Option<int>
  { if C.isNil(res) then None else f(res.value) }
  function OddOrNull(x: int): Option<int> { if modulo(x, 2) != 0 then Some(x) else None }

  method {:test} PipeWithPerformsLeftToRightFunctionWhileNotNilResult() {
    var parse := (s: string) => Some(ParseInt((s, None)));
    var inner := pipeWith(WhenNotNil, (parse, OddOrNull));
    var f := pipeWith(WhenNotNil, (inner, (x: int) => Some(inc(x))));
    expect f("1") == Some(2);
    expect f("2") == None;
  }

  // `composeWith(applying)([R.map, R.multiply, parseInt])`
  method {:test} ComposeWithPerformsRightToLeftFunctionCompositionWithFunctionApplying() {
    var inner := composeWith((f: int -> (int -> int), res: int) => Applying(f, res), (MultiplyBy, ParseInt));
    var f := composeWith((g: (int -> int) -> (seq<int> -> seq<int>), res: int -> int) => Applying(g, res), (MapWith, inner));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  method {:test} ComposeWithPerformsRightToLeftFunctionWhileNotNilResult() {
    var parse := (s: string) => Some(ParseInt((s, None)));
    var inner := composeWith(WhenNotNil, (OddOrNull, parse));
    var f := composeWith(WhenNotNil, ((x: int) => Some(inc(x)), inner));
    expect f("1") == Some(2);
    expect f("2") == None;
  }

  // ---- promap.js (v0.28.0): "composes two functions, f and g, before and
  // after the final function respectively": `charCodeAt(s)` is the first
  // character's code and `String.fromCharCode` the one-character string ----

  method {:test} PromapComposesTwoFunctionsFAndGBeforeAndAfterTheFinalFunction() {
    var charCodeAt := (s: string) => if |s| > 0 then s[0] as int else 0;
    var fromCharCode := (n: int) => if 0 <= n < 0xD800 then [n as char] else "";
    var decodeChar := promap(charCodeAt, fromCharCode, (n: int) => add(-8, n));
    var decodeString := promap((s: string) => S.split("", s), (l: seq<string>) => join("", l),
                               (l: seq<string>) => mapSeq(decodeChar, l));
    expect decodeString("ziuli") == "ramda";
  }

  // ---- flow.js (v0.30.0): "applies the first argument to a left-to-right
  // composed function"; its three-function pipelines are pairs, the first
  // two functions composed with `pipe` (the pipeline is a pair, README
  // "Deviations"); `Math.sqrt` of the perfect squares 4 and 9, `R.multiply`
  // and `R.map` curried as lambdas. "is a binary function" (typeof, length)
  // is not transcribed. ----

  function Sqrt(n: nat): nat { if n == 4 then 2 else if n == 9 then 3 else 0 }

  method {:test} FlowAppliesTheFirstArgumentToALeftToRightComposedFunction() {
    var multiplyBy := (a: nat) => ((b: int) => multiply(a, b));
    var mapWith := (f: int -> int) => ((l: seq<int>) => mapSeq(f, l));
    var f2 := flow(4, (pipe(Sqrt, multiplyBy), mapWith));
    var f3 := flow(9, (pipe(Sqrt, multiplyBy), mapWith));
    expect f2([1, 2, 3]) == [2, 4, 6];
    expect f3([1, 2, 3]) == [3, 6, 9];
    expect flow(9, (pipe(Sqrt, (n: nat) => negate(n)), inc)) == -2;
  }
}
