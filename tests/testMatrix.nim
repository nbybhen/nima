import unittest
import std/[strformat, times]
import nima/matrix

suite "Matrix operations":
  const start = cpuTime()
  var matA = initMatrix(d = @[@[1, 2], @[3, 4]])
  var matB = initMatrix(d = @[@[5, 6], @[7, 8]])
  var matC = initMatrix(d = @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]])
  var matA3x3 = initMatrix(d = @[@[0, 3, 5], @[5, 5, 2], @[3, 4, 3]])
  var matB3x3 = initMatrix(d = @[@[2, 0, -2], @[0, -1, 1], @[4, -2, 2]])

  test "Addition":
    check matA + matB == initMatrix(2, 2, @[@[6, 8], @[10, 12]])

  test "Subtraction":
    check matA - matB == initMatrix(2, 2, @[@[-4, -4], @[-4, -4]])

  test "Multiplication (dot product)":
    check matA * matB == initMatrix(2, 2, @[@[19, 22], @[43, 50]])

  test "Determinant":
    check matA.determinant() == -2
    check matB.determinant() == -2
    check matC.determinant() == 0
    check matA3x3.determinant() == -2
    check matB3x3.determinant() == -8
    check initMatrix(d = @[@[2, 1, 3, 4], @[0, -1, 2, 1], @[3, 2, 0, 5], @[-1, 3, 2, 1]]).determinant() == 35
    check initMatrix(d = @[@[4, 3, 2, 2], @[0, 1, -3, 3], @[0, -1, 3, 3], @[0, 3, 1, 1]]).determinant() == -240

  test "Inverse":
    var matT = initMatrix(d = @[ @[3.0, 0.0, 2.0], @[2.0, 0.0, -2.0], @[0.0, 1.0, 1.0] ])
    check matT.inverse() == initMatrix(d = @[ @[0.2, 0.2, 0], @[-0.2, 0.3, 1], @[0.2, -0.3, 0] ])

  # TODO
  test "Transpose":
    var matT = initMatrix(d = @[ @[6, 4, 24], @[1, -9, 8] ])
    check matT.transpose() == initMatrix(d = @[ @[6, 1], @[4, -9], @[24, 8] ])

  echo &"=== Time Elapsed: {cpuTime() - start} ==="
