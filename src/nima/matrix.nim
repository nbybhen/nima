import std/[sequtils, strutils, strformat, sugar, math]
import vector
import types

type Matrix*[T: IntOrFloat] = object
  rows*, cols* = 0
  data*: seq[Vector[T]]

# TODO: Optional argument for d arg
template initMatrix*[T: IntOrFloat](r: int = 0, c: int = 0, d: seq[seq[T]]): Matrix[T] =
  var res = Matrix[T](rows: r, cols: c, data: d)
  if d.len() > 0:
    if r == 0:
      res.rows = d.len()
    if c == 0:
      res.cols = d[0].len()
  else:
    res.data = newSeqWith(r, newSeq[T](c))
  res

func getMinor*[T](m: Matrix[T], row, col: int): Matrix[T] =
  assert(m.rows > 2 and m.cols > 2, "Matrix must be larger than 2x2.")
  let minor = collect(newSeq):
    for i in 0..<m.rows:
      if i != row:
        let rowData = m.data[i]
        concat(rowData[0..<col], rowData[col+1..^1])
  initMatrix(d = minor)

func getColumn*[T](idx: int, m: Matrix[T]): Vector[T] =
  return m.data.mapIt(it[idx])

func determinant*[T](m: Matrix[T]): T =
  case m.rows:
  of 2:
    result = m.data[0][0] * m.data[1][1] - m.data[0][1] * m.data[1][0]
  of 3:
    result = (m.data[0][0] * m.data[1][1] * m.data[2][2]) +
              (m.data[0][1] * m.data[1][2] * m.data[2][0]) +
              (m.data[0][2] * m.data[1][0] * m.data[2][1]) -
              (m.data[0][2] * m.data[1][1] * m.data[2][0]) -
              (m.data[0][1] * m.data[1][0] * m.data[2][2]) -
              (m.data[0][0] * m.data[1][2] * m.data[2][1])
  else:
    var topRow = m.data[0]
    for i in 0..<m.rows:
      let minor = m.getMinor(0, i)
      result += minor.determinant() * topRow[i] * (-1 ^ i).T

func transpose*[T](m: Matrix[T]): Matrix[T] =
  result.rows = m.cols
  result.cols = m.rows

  for i in 0..<result.rows:
    result.data.add(@[])
    for j in 0..<result.cols:
      result.data[^1].add(m.data[j][i])

func inverse*[T](m: Matrix[T]): Matrix[T] =
  assert(m.rows == m.cols, &"Invalid {m.rows}x{m.cols}: Matrix must be square")
  assert(m.determinant() != 0, "Matrix must be invertible")
  result.rows = m.rows
  result.cols = m.cols
  case m.rows:
  of 2:
    result.data.add(@[m.data[1][1], -m.data[0][1]])
    result.data.add(@[-m.data[1][0], m.data[0][0]])
  else:
    for i in 0..<m.rows:
      result.data.add(@[])
      for j in 0..<m.cols:
        let minor = m.getMinor(i, j)
        result.data[^1].add(minor.determinant() * (-1 ^ (i + j)).T)
    result = result.transpose()
  result *= (1 / m.determinant())

# === Operator Overloading ===

# TODO: Overload `+=` for mutating on basic operations
proc `+`*[T](m1, m2: Matrix[T]): Matrix[T] =
  assert(m1.rows == m2.rows and m1.cols == m2.cols, "Matrices must be the same dimensions!")
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(m1.data[i] + m2.data[i])

proc `-`*[T](m1, m2: Matrix[T]): Matrix[T] =
  assert(m1.rows == m2.rows and m1.cols == m2.cols, "Matrices must be the same dimensions!")
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(m1.data[i] - m2.data[i])

proc `*`*[T](m1, m2: Matrix[T]): Matrix[T] =
  assert(m1.cols == m2.rows, "Matrices are not of compatible size!")

  for row in m1.data:
    result.data.add(@[])
    for idx in 0..<m2.cols:
      when T is int:
        result.data[^1].add(row * getColumn(idx, m2))
      else:
        result.data[^1].add((row * getColumn(idx, m2)).formatFloat(ffDecimal, 6).parseFloat)

  result.rows = result.data.len
  result.cols = result.data[^1].len

proc `*=`*[T](m: var Matrix[T], scalar: float) =
  for i in 0..<m.rows:
    when T is int:
      m.data[i] = m.data[i].mapIt(it * scalar)
    else:
      m.data[i] = m.data[i].mapIt((it * scalar).formatFloat(ffDecimal, 6).parseFloat)
