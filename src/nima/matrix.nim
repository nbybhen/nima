import std/rdstdin
import std/sequtils
import std/strutils
import std/strformat
import std/sugar
import std/math
import vector

type Matrix* = object
  rows: int
  cols: int
  data: seq[Vector] = @[newVector(@[])]

func getColumn(idx: int, m: Matrix): Vector =
  return m.data.mapIt(it[idx])

# TODO: Overload `+=` for mutating on basic operations
proc `+`*(m1, m2: Matrix): Matrix =
  if m1.rows != m2.rows or m1.cols != m2.cols:
    echo &"Matrices must be the same dimensions!"
    return
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(m1.data[i] + m2.data[i])

proc `-`*(m1, m2: Matrix): Matrix =
  if m1.rows != m2.rows or m1.cols != m2.cols:
    echo &"Matrices must be the same dimensions!"
    return
  result.rows = m1.rows
  result.cols = m1.cols
  for i in 0..<m1.rows:
    result.data.add(m1.data[i] - m2.data[i])

proc `*`*(m1, m2: Matrix): Matrix =
  if m1.cols != m2.rows:
    echo &"Matrices are not of compatible size!"
    return

  for row in m1.data:
    result.data.add(@[])
    for idx in 0..<m2.cols:
      result.data[^1].add(row * getColumn(idx, m2))

  result.rows = result.data.len
  result.cols = result.data[^1].len

# TODO: Look into initializing seq with size or using arrays over sequences.
# e.g. newSeqWith(rows, newSeq[int](cols))
proc newMatrix*(rows, cols: int = 0, data: seq[Vector]): Matrix =
  if rows == 0 and cols == 0:
    result.rows = data.len
    result.cols = data[0].len
  else:
    result.rows = rows
    result.cols = cols
  result.data = data

proc buildMatrix*(name: string): Matrix =
  let
    dim = readLineFromStdin(&"Enter the dimensions for Matrix {name} (e.g. '2x2'): ")
    s = split(dim, {'x'}, 1)
  (result.rows, result.cols) = (s[0].parseInt, s[1].parseInt)

  echo "Enter the matrix row by row (space-separated): "

  # TODO: Exception handling
  for i in 0..<result.rows:
    let row = readLine(stdin).splitWhitespace()
    if row.len != result.cols:
      echo &"Invalid number of arguments supplied: received {row.len} args, but expected {result.cols}."
      break
    result.data.add(row.mapIt(it.parseInt))

proc getMinor*(m: Matrix, row, col: int): Matrix =
  let minor = collect(newSeq):
    for i in 0..<m.rows:
      if i != row:
        let rowData = m.data[i]
        concat(rowData[0..<col], rowData[col+1..^1])
  newMatrix(data = minor)

proc determinant*(m: Matrix): int =
  case m.rows:
  of 2:
    result = (m.data[0][0] * m.data[1][1]) - (m.data[0][1] * m.data[1][0])
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
      result += (minor.determinant() * (topRow[i] * (-1) ^ i))
