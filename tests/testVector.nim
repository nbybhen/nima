import unittest
import nima/vector

suite "Vector operations":
  var vecA = newVector(@[1,2,3])
  var vecB = newVector(@[4,5,6])

  test "Addition":
    let vecC = vecA + vecB
    check vecC == newVector(@[5,7,9])

  test "Subtraction":
    let vecD = vecA - vecB
    check vecD == newVector(@[-3,-3,-3])

  test "Multiplication":
    let vecE = vecA * vecB
    check vecE == 32

  test "Scalar multiplication":
    vecA.scalarMult(10)
    check vecA == newVector(@[10,20,30])
