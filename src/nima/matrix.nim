import std/rdstdin
import std/sequtils
import std/strutils
import std/strformat
import std/sugar

type Matrix* = object
  rows: int
  cols: int
  data: seq[seq[int]] = @[@[]]

func getColumn(idx: int, m: Matrix): seq[int] =
  return m.data.mapIt(it[idx])

# TODO: Overload `+=` for mutating on basic operations
proc `+`*(m1: Matrix, m2: Matrix): Matrix =
  if m1.rows != m2.rows or m1.cols != m2.cols:
    echo &"Matrices must be the same dimensions!"
    return
  result.rows = m1.rows
  result.cols = m1.cols

  for i in 0..<m1.rows:
    result.data.add(@[])
    for j in 0..<m1.cols:
      result.data[i].add(m1.data[i][j] + m2.data[i][j])

proc `-`*(m1: Matrix, m2: Matrix): Matrix =
  if m1.rows != m2.rows or m1.cols != m2.cols:
    echo &"Matrices must be the same dimensions!"
    return
  result.rows = m1.rows
  result.cols = m1.cols
  for i in 0..<m1.rows:
    result.data.add(@[])
    for j in 0..<m1.cols:
      result.data[i].add(m1.data[i][j] - m2.data[i][j])

proc `*`*(m1: Matrix, m2: Matrix): Matrix =
  if m1.cols != m2.rows:
    echo &"Matrices are not of compatible size!"
    return

  for row in m1.data:
    result.data.add(@[])
    for idx in 0..<m2.cols:
      var rowcol = zip(row, getColumn(idx, m2))
      result.data[^1].add(rowcol.map(x => x[0] * x[1]).foldl(a + b))

  result.rows = result.data.len
  result.cols = result.data[^1].len

# TODO: Look into initializing seq with size or using arrays over sequences.
# e.g. newSeqWith(rows, newSeq[int](cols))
proc newMatrix*(rows, cols: int = 0, data: seq[seq[int]] = @[@[]]): Matrix =
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

proc scalarMult*(s: int, m: var Matrix) =
  m.data = m.data.mapIt(it.map(inner => inner * s))
