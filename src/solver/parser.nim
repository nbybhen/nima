import std/[tables, strformat, sugar]
import lexer

type Parser* = object
  src*: seq[Token]
  current: int = 0

type 
  AstKind* = enum
    Unary
    Binary
    List
  StmtKind* = enum 
    ExprStmt
    VarStmt
    
type
  Expr* = ref object
    case kind*: AstKind
    of Binary:
      left*: Expr
      op*: Token
      right*: Expr
    of Unary:
      val*: Token
    of List:
      inner*: seq[Expr]   
  Stmt* = ref object
    case kind*: StmtKind
    of ExprStmt:
      expression*: Expr
    of VarStmt:
      varName*: Token
      varVal*: Expr

const bindingPower = {'+', '-': 10, '*': 20, '=': 5}.toTable

#
# Forward declarations
#

proc parseExpression(self: var Parser, rbp: int): Expr

proc led(self: var Parser, left: Expr): Expr {.inline.}

proc cleanExprPrint*(node: Expr, prefix: string = "", isLeft: bool = true)

#
# Helper functions
#

proc peek(self: Parser): Token {.inline.} = 
  self.src[self.current]

proc previous(self: Parser): Token {.inline.} =
  self.src[self.current - 1]

proc advance(self: var Parser): Token {.inline.} =
  self.current += 1
  self.previous()

proc check(self: var Parser, tkType: TokenKind): bool {.inline.} = 
  if self.peek.kind == tkEOF: false else: self.peek.kind == tkType

proc consume(self: var Parser, tkType: TokenKind): Token {.inline.} =
  if self.check(tkType): 
    return self.advance() 
  else: 
    echo &"Token is not of type {tkType}"

proc match(self: var Parser, tkTypes: varargs[TokenKind]): bool = 
  for tkType in tkTypes:
    if self.peek.kind == tkType:
      discard self.advance()
      return true
  return false

proc parseList(self: var Parser): Expr =
  if self.match(tkLeftBracket):
    var vec: seq[Expr] = @[]
    while not self.check(tkRightBracket):
      vec.add(self.parseExpression(0))

      discard self.match(tkComma)

    discard self.match(tkRightBracket)
    return Expr(kind: List, inner: vec)
  
    
#
# Parser
#

proc parseAssignment(self: var Parser): Stmt =
  let name = self.advance()
  if self.match(tkEqual):
    let val = self.parseExpression(0)
    return Stmt(kind: VarStmt, varName: name, varVal: val)

proc parseStatement(self: var Parser): Stmt = 
  case self.peek.kind:
  of tkIdent:
    return self.parseAssignment()
  else:
    return Stmt(kind: ExprStmt, expression: self.parseExpression(0))

proc parse*(self: var Parser): Stmt = 
  self.parseStatement()

proc nud(self: var Parser): Expr {.inline.} = 
  Expr(kind: Unary, val: self.advance())

proc parseExpression(self: var Parser, rbp: int): Expr =
  var left =
    if self.check(tkLeftBracket):
      self.parseList()
    else:
      self.nud()
 
  case self.peek.kind:
  of tkAdd, tkSub, tkMult, tkEqual:
    echo self.peek.repr
    while bindingPower.getOrDefault(self.peek.val, 0) > rbp and self.peek.kind != tkEOF:
      left = self.led(left)
  of tkComma, tkRightBracket, tkEOF:
    discard
  else:
    echo &"{self.peek.kind} is not yet implemented in parseExpression!"

  left

proc led(self: var Parser, left: Expr): Expr {.inline.} =
  let op = self.advance()
  let bp = bindingPower.getOrDefault(op.val, 0);

  Expr(kind: Binary, left: left, op: op, right: self.parseExpression(bp))


proc cleanExprPrint*(node: Expr, prefix: string = "", isLeft: bool = true) =
  const 
    rightBar = "└──"
    leftBar = "├──"
    spacing = "    "

  case node.kind:
  of Binary:
    echo prefix, rightBar, node[].op
    cleanExprPrint(node.left, prefix & spacing, true)
    cleanExprPrint(node.right, prefix & spacing, false)
  of Unary:
    if isLeft:
      echo prefix, leftBar, node[].val
    else:
      echo prefix, rightBar, node[].val
  of List:
    echo prefix, leftBar, "List:"
    for node in node.inner:
      cleanExprPrint(node, prefix & spacing, false)
  else:
    echo &"Printing for Expr::{node.kind} is not yet implemented!"
      

proc cleanStmtPrint*(node: Stmt, prefix: string = "", isLeft: bool = true) = 
  const 
    rightBar = "└──"
    leftBar = "├──"
    spacing = "    "

  case node.kind:
  of ExprStmt:
    node[].expression.cleanExprPrint(prefix, isLeft)
  of VarStmt:
    echo node[].varName
    node[].varVal.cleanExprPrint(prefix, isLeft)
  else:
    echo &"Printing for Stmt::{node.kind} is not yet implemented!"