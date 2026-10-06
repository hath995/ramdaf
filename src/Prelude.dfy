// Ramdaf: a Dafny port of Ramda v0.1.0 (2013-12-26).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> false, `nth` out of range -> null, a missing
  // property -> undefined, `maxWith([])` -> undefined) becomes None.
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten`) become a rose tree:
  // a non-array element is a Leaf, a nested array is a Node.
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)
}
