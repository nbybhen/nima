import unittest
import std/strformat
import nima/matrix

suite "Matrix operations":
  var matA: Matrix[int] = newMatrix(2, 2, @[@[1, 2], @[3, 4]])
  var matB: Matrix[int] = newMatrix(2, 2, @[@[5, 6], @[7, 8]])
  var matC: Matrix[int] = newMatrix(data = @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]])
  var matA3x3: Matrix[int] = newMatrix(3, 3, @[@[0, 3, 5], @[5, 5, 2], @[3, 4, 3]])
  var matB3x3: Matrix[int] = newMatrix(3, 3, @[@[2, 0, -2], @[0, -1, 1], @[4, -2, 2]])

  test "Addition":
    check matA + matB == newMatrix(2, 2, @[@[6, 8], @[10, 12]])

  test "Subtraction":
    check matA - matB == newMatrix(2, 2, @[@[-4, -4], @[-4, -4]])

  test "Multiplication (dot product)":
    check matA * matB == newMatrix(2, 2, @[@[19, 22], @[43, 50]])

  test "Determinant":
    check matA.determinant() == -2
    check matB.determinant() == -2
    check matC.determinant() == 0
    check matA3x3.determinant() == -2
    check matB3x3.determinant() == -8
    check newMatrix(data = @[@[2, 1, 3, 4], @[0, -1, 2, 1], @[3, 2, 0, 5], @[-1, 3, 2, 1]]).determinant() == 35
    check newMatrix(data = @[@[4, 3, 2, 2], @[0, 1, -3, 3], @[0, -1, 3, 3], @[0, 3, 1, 1]]).determinant() == -240

  test "Inverse":
    var matT = newMatrix(data = @[ @[3.0, 0.0, 2.0], @[2.0, 0.0, -2.0], @[0.0, 1.0, 1.0] ])
    check matT.inverse() == newMatrix(data = @[ @[0.2, 0.2, 0], @[-0.2, 0.3, 1], @[0.2, -0.3, 0] ])

  # TODO
  test "Transpose":
    var matT = newMatrix(data = @[ @[6, 4, 24], @[1, -9, 8] ])
    check matT.transpose() == newMatrix(data = @[ @[6, 1], @[4, -9], @[24, 8] ])
