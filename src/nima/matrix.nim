import std/[sequtils, strutils, strformat, sugar, math]
import vector
import types

# TODO: Optional argument for d arg
proc initMatrix*[T: IntOrFloat](r: int = 0, c: int = 0, d: seq[seq[T]]): Matrix[T] =
  result = Matrix[T](rows: r, cols: c, data: d)
  if d.len() > 0:
    if r == 0:
      result.rows = d.len()
    if c == 0:
      result.cols = d[0].len()
  else:
    result.data = newSeqWith(r, newSeq[T](c))

func getMinor*[T](self: Matrix[T], row, col: int): Matrix[T] =
  assert(self.rows > 2 and self.cols > 2, "Matrix must be larger than 2x2.")
  let minor = collect(newSeq):
    for i in 0..<self.rows:
      if i != row:
        let rowData = self.data[i]
        concat(rowData[0..<col], rowData[col+1..^1])
  initMatrix(d = minor)

func getColumn*[T](self: Matrix[T], idx: int): Vector[T] =
  return self.data.mapIt(it[idx])

func determinant*[T](self: Matrix[T]): T =
  case self.rows:
  of 2:
    result = self.data[0][0] * self.data[1][1] - self.data[0][1] * self.data[1][0]
  of 3:
    result = (self.data[0][0] * self.data[1][1] * self.data[2][2]) +
              (self.data[0][1] * self.data[1][2] * self.data[2][0]) +
              (self.data[0][2] * self.data[1][0] * self.data[2][1]) -
              (self.data[0][2] * self.data[1][1] * self.data[2][0]) -
              (self.data[0][1] * self.data[1][0] * self.data[2][2]) -
              (self.data[0][0] * self.data[1][2] * self.data[2][1])
  else:
    var topRow = self.data[0]
    for i in 0..<self.rows:
      let minor = self.getMinor(0, i)
      result += minor.determinant() * topRow[i] * (-1 ^ i).T

func transpose*[T](self: Matrix[T]): Matrix[T] =
  result.rows = self.cols
  result.cols = self.rows

  for i in 0..<result.rows:
    result.data.add(@[])
    for j in 0..<result.cols:
      result.data[^1].add(self.data[j][i])

func inverse*[T](self: Matrix[T]): Matrix[T] =
  assert(self.rows == self.cols, &"Invalid {self.rows}x{self.cols}: Matrix must be square")
  assert(self.determinant() != 0, "Matrix must be invertible")
  result.rows = self.rows
  result.cols = self.cols
  case self.rows:
  of 2:
    result.data.add(@[self.data[1][1], -self.data[0][1]])
    result.data.add(@[-self.data[1][0], self.data[0][0]])
  else:
    for i in 0..<self.rows:
      result.data.add(@[])
      for j in 0..<self.cols:
        let minor = self.getMinor(i, j)
        result.data[^1].add(minor.determinant() * (-1 ^ (i + j)).T)
    result = result.transpose()
  result *= (1 / self.determinant())

# === Operator Overloading ===

# TODO: Overload `+=` for mutating on basic operations
proc `+`*[T](m1, m2: Matrix[T]): Matrix[T] {.inline.} =
  assert(m1.rows == m2.rows and m1.cols == m2.cols, "Matrices must be the same dimensions!")
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(m1.data[i] + m2.data[i])

proc `-`*[T](m1, m2: Matrix[T]): Matrix[T] {.inline.} =
  assert(m1.rows == m2.rows and m1.cols == m2.cols, "Matrices must be the same dimensions!")
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(m1.data[i] - m2.data[i])

proc `*`*[T](m1, m2: Matrix[T]): Matrix[T] {.inline.} =
  assert(m1.cols == m2.rows, "Matrices are not of compatible size!")

  for row in m1.data:
    result.data.add(@[])
    for idx in 0..<m2.cols:
      when T is int:
        result.data[^1].add(row * m2.getColumn(idx))
      else:
        result.data[^1].add((row * m2.getColumn(idx)).formatFloat(ffDecimal, 6).parseFloat)

  result.rows = result.data.len
  result.cols = result.data[^1].len

proc `*=`*[T](m: var Matrix[T], scalar: float) {.inline.} =
  for i in 0..<m.rows:
    when T is int:
      m.data[i] = m.data[i].mapIt(it * scalar)
    else:
      m.data[i] = m.data[i].mapIt((it * scalar).formatFloat(ffDecimal, 6).parseFloat)
