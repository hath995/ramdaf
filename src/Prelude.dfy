// Ramdaf: a Dafny port of Ramda v0.2.2 (2014-06-30).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree, SpecVal

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> undefined, `nth` out of range -> undefined, a
  // missing property -> undefined, `maxWith([])` -> undefined) becomes None.
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten`) become a rose tree:
  // a non-array element is a Leaf, a nested array is a Node.
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)

  // A value of `where`'s spec object: a function, called with the test
  // object's property (None when absent, i.e. JS undefined) and the whole test
  // object, or any other value, compared with `===`.
  datatype SpecVal<!V> = Pred(fn: (Option<V>, map<string, V>) -> bool) | Val(v: V)
}
