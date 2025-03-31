import std/[tables, strformat]
import calc

type Parser* = object
  src*: seq[calc.Token]
  current: int = 0

type AstKind* = enum
  NUD,
  LED

type Ast* = ref object
  case kind*: AstKind
  of NUD:
    val*: Token
  of LED:
    left*: Ast
    op*: Token
    right*: Ast

const bindingPower = {'+': 10, '*': 20}.toTable

template peek(self: Parser): Token = self.src[self.current]

proc advance(self: var Parser): Token =
  self.current += 1
  self.src[self.current - 1]

proc expr(self: var Parser, rbp: int): Ast =
  var left = Ast(kind: NUD, val: self.advance())
  if self.peek.kind == tkEOF:
    return left

  var op = self.peek
  case op.kind:
  of tkAdd, tkMult:
    while bindingPower[op.val] > rbp and self.peek.kind != tkEOF:
      left = Ast(kind: LED, left: left, op: self.advance(), right: self.expr(bindingPower[op.val]))
  else:
    return left
  left

proc parse*(self: var Parser): Ast =
  self.expr(0)

proc print*(self: var Parser, node: Ast) =
  echo &"Root: {node[]}\n"
  case node.kind:
  of LED:
    echo "Left ->"
    self.print(node[].left)
    echo "Right ->"
    self.print(node[].right)
  of NUD:
    node[].val.echo "\n"
