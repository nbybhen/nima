import std/[tables, strformat]
import calc

type Parser* = object
  src*: seq[calc.Token]
  current: int = 0

type AstKind* = enum
  Unary
  Binary

type Expr* = ref object
  case kind*: AstKind
  of Binary:
    left*: Expr
    op*: Token
    right*: Expr
  of Unary:
    val*: Token

const bindingPower = {'+': 10, '*': 20, '=': 5}.toTable

template peek(self: Parser): Token = self.src[self.current]

proc advance(self: var Parser): Token =
  self.current += 1
  self.src[self.current - 1]

proc expression(self: var Parser, rbp: int): Expr =
  var left = Expr(kind: Unary, val: self.advance())
  if self.peek.kind == tkEOF:
    return left

  var op = self.peek
  case op.kind:
  of tkAdd, tkMult:
    while bindingPower[op.val] > rbp and self.peek.kind != tkEOF:
      left = Expr(kind: Binary, left: left, op: self.advance(), right: self.expression(bindingPower[op.val]))
  else:
    return left
  left

proc parse*(self: var Parser): Expr =
  self.expression(0)

proc cleanPrint*(node: Expr, prefix: string = "", isLeft: bool = true) =
  const leftBar = "└──"
  const rightBar = "├──"

  case node.kind:
  of Binary:
    echo leftBar, node[].op
    cleanPrint(node.right, prefix & "    ", false)
    cleanPrint(node.left, prefix & "    ", true)
  of Unary:
    if isLeft:
      echo prefix, leftBar, node[].val
    else:
      echo prefix, rightBar, node[].val