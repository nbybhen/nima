import std/[strformat, strutils]

type TokenKind* = enum
  tkInt
  tkIdent
  tkFloat
  tkLeftParen
  tkRightParen
  tkLeftBracket
  tkRightBracket
  tkEqual
  tkComma
  tkAdd
  tkMult
  tkEOF

type Token* = object
  case kind*: TokenKind
  of tkInt:
    valInt*: int
  of tkFloat:
    valFloat*: float
  of tkIdent:
    valIdent*: string
  else:
    val*: char

type Lexer* = object
  src*: string
  start, current: int = 0
  tokens: seq[Token] = @[]

template isAtEnd(self: Lexer): bool = self.current >= self.src.len

template isAlpha(c: char): bool = c in 'a'..'z' or c in 'A'..'Z'

template isNumeric(c: char): bool = c in '0'..'9' or c == '.'

proc advance(self: var Lexer): char =
  self.current += 1
  self.src[self.current - 1]

proc peek(self: Lexer): char =
  if self.isAtEnd():
    return '\0'
  else:
    return self.src[self.current]

proc makeStringTk(self: var Lexer): Token =
  self.start = self.current - 1
  while not self.isAtEnd() and self.peek().isAlpha():
    discard self.advance()

  # TODO: Check for "keywords"
  Token(kind: tkIdent, valIdent: self.src[self.start..<self.current])

proc makeNumberTk(self: var Lexer): Token =
  self.start = self.current - 1
  var kind: TokenKind = tkInt
  while not self.isAtEnd() and self.peek().isNumeric():
    if self.peek() == '.':
      kind = tkFloat
    discard self.advance()

  case kind:
  of tkInt:
    return Token(kind: tkInt, valInt: self.src[self.start..<self.current].parseInt)
  of tkFloat:
    return Token(kind: tkFloat, valFloat: self.src[self.start..<self.current].parseFloat)
  else:
    return

proc tokenize*(self: var Lexer): seq[Token] =
  while not self.isAtEnd():
    case self.advance():
    of 'a'..'z', 'A'..'Z':
      self.tokens.add(self.makeStringTk())
    of '0'..'9':
      self.tokens.add(self.makeNumberTk())
    of '[':
      self.tokens.add(Token(kind: tkLeftBracket, val: '['))
    of ']':
      self.tokens.add(Token(kind: tkRightBracket, val: ']'))
    of '=':
      self.tokens.add(Token(kind: tkEqual, val: '='))
    of '+':
      self.tokens.add(Token(kind: tkAdd, val: '+'))
    of '*':
      self.tokens.add(Token(kind: tkMult, val: '*'))
    of ' ': discard
    of ',':
      self.tokens.add(Token(kind: tkComma, val: ','))
    else:
      echo &"Invalid token: {self.src[self.current-1]}"
      break

  self.tokens.add(Token(kind: tkEOF, val: '\0'))
  self.tokens
