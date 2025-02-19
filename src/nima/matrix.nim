import std/rdstdin
import std/sequtils
import std/strutils
import std/strformat
import std/sugar
import std/math
import vector

type Matrix*[T] = object
  rows*: int
  cols*: int
  data*: seq[Vector[T]]

func getColumn[T](idx: int, m: Matrix[T]): Vector[T] =
  return m.data.mapIt(it[idx])

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
      # TODO: Uhhh change this??? (Look into splitting Matrix/Vector types)
      result.data[^1].add((((row * getColumn(idx, m2)).float).formatFloat(ffDecimal, 2).parseFloat).T)

  result.rows = result.data.len
  result.cols = result.data[^1].len

proc `*=`*[T](m: var Matrix[T], scalar: float) =
  for i in 0..<m.rows:
    m.data[i] = m.data[i].mapIt(((it * scalar).formatFloat(ffDecimal, 2).parseFloat).T)

# TODO: Look into initializing seq with size or using arrays over sequences.
# e.g. newSeqWith(rows, newSeq[int](cols))
proc newMatrix*[T](rows, cols: int = 0, data: seq[Vector[T]]): Matrix[T] =
  if rows == 0 and cols == 0:
    result.rows = data.len
    result.cols = data[0].len
  else:
    result.rows = rows
    result.cols = cols
  result.data = data

proc getMinor*[T](m: Matrix[T], row, col: int): Matrix[T] =
  assert(m.rows > 2 and m.cols > 2, "Matrix must be greater than 2x2")
  let minor = collect(newSeq):
    for i in 0..<m.rows:
      if i != row:
        let rowData = m.data[i]
        concat(rowData[0..<col], rowData[col+1..^1])
  newMatrix(data = minor)

proc determinant*[T](m: Matrix[T]): T =
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
      let minor = getMinor(m, 0, i)
      result += (minor.determinant() * (topRow[i] * ((-1) ^ i).T))

proc adjugate[T](m: var Matrix[T]) =
  for i in 0..<ceil(m.rows/2).int:
    for j in (i+1)..<m.cols:
      if i != j:
        (m.data[i][j], m.data[j][i]) = (m.data[j][i], m.data[i][j])


proc inverse*[T](m: Matrix[T]): Matrix[T] =
  assert(m.rows == m.cols, "Matrix must be square")
  assert(m.determinant() != 0, "Matrix must be invertible")
  result.rows = m.rows
  result.cols = m.cols

  for i in 0..<m.rows:
    result.data.add(@[])
    for j in 0..<m.cols:
      let minor = getMinor(m, i, j)
      result.data[^1].add(minor.determinant() * ((-1) ^ (i + j)).T)
  result.adjugate()
  result *= (1 / m.determinant())
