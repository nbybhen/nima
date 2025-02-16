import unittest
import nima/vector

suite "Vector operations":
  var vecA = newVector(data = @[1,2,3])
  test "Scalar multiplication":
    vecA.scalarMult(10)
    check vecA == newVector(data = @[10,20,30])
