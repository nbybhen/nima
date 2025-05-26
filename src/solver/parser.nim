import std/[tables, strformat]
import lexer

type Parser* = object
  src*: seq[lexer.Token]
  current: int = 0

type AstKind* = enum
  Unary
  Binary
  Variable

type Expr* = ref object
  case kind*: AstKind
  of Binary:
    left*: Expr
    op*: Token
    right*: Expr
  of Unary:
    val*: Token
  of Variable:
    varName*: Token

type StmtKind* = enum 
  ExprStmt
  VarStmt

type Stmt* = ref object
  case kind*: StmtKind
  of ExprStmt:
    expression*: Expr
  of VarStmt:
    varName*: Token
    varVal*: Expr

const bindingPower = {'+': 10, '*': 20, '=': 5}.toTable

template peek(self: Parser): Token = self.src[self.current]

proc advance(self: var Parser): Token {.inline.} =
  self.current += 1
  self.src[self.current - 1]

# Forward Decls

proc parseAssignment() = discard  

proc expression(self: var Parser, rbp: int): Expr

proc parseStatement(self: var Parser): Stmt = 
  case self.peek.kind:
  of tkIdent:
    let name = self.advance()
    if self.advance().kind == tkEqual:
      let val = self.expression(0)
      return Stmt(kind: VarStmt, varName: name, varVal: val)
  else:
    let val = self.expression(0)
    return Stmt(kind: ExprStmt, expression: val)

proc parse*(self: var Parser): Stmt = self.parseStatement()

proc nud(self: var Parser): Expr {.inline.} = Expr(kind: Unary, val: self.advance())

proc led(self: var Parser, left: Expr): Expr {.inline.}

proc expression(self: var Parser, rbp: int): Expr =
  var left = self.nud()
  if self.peek.kind == tkEOF:
    return left

  var op = self.peek
  case op.kind:
  of tkAdd, tkMult, tkEqual:
    while bindingPower[op.val] > rbp and self.peek.kind != tkEOF:
      left = self.led(left)
  else:
    return left
  left

proc led(self: var Parser, left: Expr): Expr {.inline.} =
  let op = self.advance()
  let bp = bindingPower.getOrDefault(op.val, 0);

  Expr(kind: Binary, left: left, op: op, right: self.expression(bp))


proc cleanPrint*(node: Expr, prefix: string = "", isLeft: bool = true) =
  const 
    rightBar = "└──"
    leftBar = "├──"
    spacing = "    "

  case node.kind:
  of Binary:
    echo prefix, rightBar, node[].op
    cleanPrint(node.left, prefix & spacing, true)
    cleanPrint(node.right, prefix & spacing, false)
  of Unary:
    if isLeft:
      echo prefix, leftBar, node[].val
    else:
      echo prefix, rightBar, node[].val
  of Variable:
    if isLeft:
      echo prefix, leftBar, node[].varName
    else:
      echo prefix, rightBar, node[].varName
      

proc cleanStmtPrint*(node: Stmt, prefix: string = "", isLeft: bool = true) = 
  const 
    rightBar = "└──"
    leftBar = "├──"
    spacing = "    "

  case node.kind:
  of ExprStmt:
    node[].expression.cleanPrint(prefix, isLeft)
  of VarStmt:
    echo node[].varName
    node[].varVal.cleanPrint(prefix, isLeft)