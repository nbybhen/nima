import std/sequtils
import std/strutils


type Vector* = seq[int]

proc `+`*(self, other: Vector): Vector =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] + it[1]))

proc `-`*(self, other: Vector): Vector =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] - it[1]))

proc `*`*(self, other: Vector): int =
  assert(self.len == other.len, "Vectors must be the same length")
  zip(self, other).mapIt(it[0] * it[1]).foldl(a + b)

proc buildVector*(): Vector =
  echo "Enter vector elements separated by spaces: "
  result = readLine(stdin).splitWhitespace().mapIt(it.parseInt)

proc newVector*(data: seq[int]): Vector =
  result = data

proc scalarMult*(self: var Vector, scalar: int) =
  self.applyIt(it * scalar)
