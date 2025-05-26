import std/[tables, strformat]
import lexer

type Parser* = object
  src*: seq[lexer.Token]
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

proc advance(self: var Parser): Token {.inline.} =
  self.current += 1
  self.src[self.current - 1]

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

  if op.val == '=':
    if left.kind != Unary:
      # TODO: Handle this error if left is a Binary operation
      discard
    return Expr(kind: Binary, left: left, op: op, right: self.expression(bp - 1))
  Expr(kind: Binary, left: left, op: op, right: self.expression(bp))


proc parse*(self: var Parser): Expr =
  self.expression(0)

proc cleanPrint*(node: Expr, prefix: string = "", isLeft: bool = true) =
  const rightBar = "└──"
  const leftBar = "├──"

  case node.kind:
  of Binary:
    echo prefix, rightBar, node[].op
    cleanPrint(node.left, prefix & "    ", true)
    cleanPrint(node.right, prefix & "    ", false)
  of Unary:
    if isLeft:
      echo prefix, leftBar, node[].val
    else:
      echo prefix, rightBar, node[].val