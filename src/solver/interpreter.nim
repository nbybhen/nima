import std/[strformat, tables]
import lexer, parser

type ObjKind = enum
  Number
  String

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
  of String:
    valStr: string

proc value(obj: Obj): string {.inline.} =
  # Gets inner value of any Obj type as a string
  case obj.kind:
  of String:
    obj.valStr
  of Number:
    case obj.numKind:
    of nkFloat:
      $obj.valFloat
    of nkInt:
      $obj.valInt

type Interpreter* = object
  tree*: Expr
  globals: Table[string, Obj]

proc traverse*(self: var Interpreter, tree: Expr): Obj =
  case tree.kind:
  of Binary:
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
      elif left.kind == String and right.kind == String:
        return Obj(kind: String, valStr: left.valStr & right.valStr)
    of tkMult:
      if left.kind == Number and right.kind == Number:
        if left.numKind == nkFloat and right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valFloat * right.valFloat)
        elif left.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valFloat * right.valInt.toFloat)
        elif right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: left.valInt.toFloat * right.valFloat)
        return Obj(kind: Number, numKind: nkInt, valInt: left.valInt * right.valInt)
    else:
      echo &"{op.kind} not implemented for Binary"
  of Unary:
    case tree.val.kind:
    of tkInt:
      return Obj(kind: Number, numKind: nkInt, valInt: tree.val.valInt)
    of tkFloat:
      return Obj(kind: Number, numKind: nkFloat, valFloat: tree.val.valFloat)
    of tkIdent:
      return Obj(kind: String, valStr: tree.val.valIdent)
    else:
      echo &"{tree.val.kind} not implemented for Unary"
  of Variable:
    if not self.globals.contains(tree.varName.valIdent):
      echo &"Variable {tree.varName.valIdent} isn't defined!"
      return
    return self.globals[tree.varName.valIdent]
  of Assign:
    let val = self.traverse(self.tree.assignVal)
    self.globals[self.tree.assignName.valIdent] = val

    return val
  else:
    echo "NOT IMPLEMENTED"

proc interpret*(self: var Interpreter) =
  echo "Output: ", self.traverse(self.tree)