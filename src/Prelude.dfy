// Ramdaf: a Dafny port of Ramda v0.3.0 (2014-08-10).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree, SpecVal

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> undefined, `nth` out of range -> undefined, a
  // missing property -> undefined, `maxWith([])` -> undefined) becomes None.
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten` and `unnest`)
  // become a rose tree: a nested array is a Node, any other element a Leaf.
  // (Since v0.3.0 Ramda also flattens an array-like element, such as an
  // object with a numeric `length`; a Leaf is never flattened, README
  // "Deviations".)
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)

  // A value of `where`'s spec object: a function, called with the test
  // object's property and the whole test object, or any other value, compared
  // with `===`. (Up to v0.2.2 the function was also called for an absent
  // property, with None, i.e. JS undefined; since v0.2.3 it is not.)
  datatype SpecVal<!V> = Pred(fn: (Option<V>, map<string, V>) -> bool) | Val(v: V)
}
