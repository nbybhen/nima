import std/[strformat, tables, sugar]
import lexer, parser

type 
  NumKind* = enum
    nkFloat
    nkInt
  ObjKind = enum
    Number
    Vector

type Obj = object
  case kind: ObjKind
  of Number:
    case numKind: NumKind
    of nkFloat:
      valFloat: float
    of nkInt:
      valInt: int
  of Vector:
    valVec: seq[Obj]

type Interpreter* = object
  tree*: Expr
  globals: Table[string, Obj]

proc traverseExpr*(self: var Interpreter, tree: Expr): Obj =
  case tree.kind:
  of Binary:
    let op = tree.op
    var left = self.traverseExpr(tree.left)
    var right = self.traverseExpr(tree.right)

    case op.kind:
    of tkAdd:
      if left.kind == Number and right.kind == Number:
        let 
          a = if left.numKind == nkFloat: left.valFloat else: left.valInt.toFloat
          b = if right.numKind == nkFloat: right.valFloat else: right.valInt.toFloat
        if left.numKind == nkFloat or right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: a + b)
        return Obj(kind: Number, numKind: nkInt, valInt: left.valInt + right.valInt)
    of tkSub:
      if left.kind == Number and right.kind == Number:
        let 
          a = if left.numKind == nkFloat: left.valFloat else: left.valInt.toFloat
          b = if right.numKind == nkFloat: right.valFloat else: right.valInt.toFloat
        if left.numKind == nkFloat or right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: a - b)
        return Obj(kind: Number, numKind: nkInt, valInt: left.valInt - right.valInt)
    of tkMult:
      if left.kind == Number and right.kind == Number:
        let 
          a = if left.numKind == nkFloat: left.valFloat else: left.valInt.toFloat
          b = if right.numKind == nkFloat: right.valFloat else: right.valInt.toFloat
        if left.numKind == nkFloat or right.numKind == nkFloat:
          return Obj(kind: Number, numKind: nkFloat, valFloat: a * b)
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
      if not self.globals.contains(tree.val.valIdent):
        echo &"Variable {tree.val.valIdent} isn't defined!"
        return
      return self.globals[tree.val.valIdent]
    else:
      echo &"{tree.val.kind} not implemented for Unary"
  of List:
    let vec = collect(newSeq):
      for x in tree.inner:
        self.traverseExpr(x)
    return Obj(kind: Vector, valVec: vec)
  else:
    echo "NOT IMPLEMENTED"

proc traverse(self: var Interpreter, tree: Stmt): Obj = 
  case tree.kind:
  of ExprStmt:
    return self.traverseExpr(tree.expression)
  of VarStmt:
    let val = self.traverseExpr(tree.varVal)
    self.globals[tree.varName.valIdent] = val
    return val

proc interpret*(self: var Interpreter, tree: Stmt) =
  echo "Output: ", self.traverse(tree).repr