import std/[strformat]
import calc, parser

type ObjKind = enum
  Number

type NumKind* = enum
  nkFloat,
  nkInt

type Obj = object
  case kind: ObjKind
  of Number:
    case numKind: NumKind
    of nkFloat:
      valFloat: float
    of nkInt:
      valInt: int

type Interpreter* = object
  tree*: Ast

proc traverse*(self: var Interpreter, tree: Ast): Obj =
  case tree.kind:
  of LED:
    let op = tree.op
    var left = self.traverse(tree.left)
    var right = self.traverse(tree.right)

    case op.kind:
    of tkAdd:
      if left.kind == Number and right.kind == Number:
        if left.numKind == nkFloat and right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valFloat + right.valFloat)
        elif left.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valFloat + right.valInt.toFloat)
        elif right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valInt.toFloat + right.valFloat)
        return Obj(kind: Number, numKind: nkInt, valInt: left.valInt + right.valInt)
    of tkMult:
      if left.kind == Number and right.kind == Number:
        if left.numKind == nkFloat or right.numKind == nkFloat:
          echo &"MULTIPLYING {left.valInt} and {right.valInt}"
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valInt.toFloat * right.valInt.toFloat)
        echo &"MULTIPLYING {left.valInt} and {right.valInt}"
        return Obj(kind: Number, numKind: nkInt, valInt: left.valInt * right.valInt)
    else:
      echo &"{op.kind} not implemented"
  else:
    case tree.val.kind:
    of tkInt:
      return Obj(kind: Number, numKind: nkInt, valInt: tree.val.valInt)
    else:
      echo &"{tree.val.kind} not implemented"

proc interpret*(self: var Interpreter) =
  echo "Output: ", self.traverse(self.tree)
