import unittest
import std/[times, strformat]
import nima/vector

suite "Vector operations":
  const start = cpuTime()
  var vecA = initVector(@[1,2,3])
  var vecB = initVector(@[4,5,6])

  test "Addition":
    let vecC = vecA + vecB
    check vecC == initVector(@[5,7,9])

  test "Subtraction":
    let vecD = vecA - vecB
    check vecD == initVector(@[-3,-3,-3])

  test "Multiplication":
    let vecE = vecA * vecB
    check vecE == 32

  test "Scalar multiplication":
    vecA.scalarMult(10)
    check vecA == initVector(@[10,20,30])

  echo &"=== Time elapsed: {cpuTime() - start} ==="
