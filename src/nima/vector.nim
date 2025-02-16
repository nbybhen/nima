import std/sequtils
import std/strutils


type Vector = object
  data: seq[int]

proc buildVector*(): Vector =
  echo "Enter vector elements separated by spaces: "
  result.data = readLine(stdin).splitWhitespace().mapIt(it.parseInt)

proc newVector*(data: seq[int]): Vector =
  result.data = data

proc scalarMult*(vec: var Vector, scalar: int) =
  vec.data.applyIt(it * scalar)
