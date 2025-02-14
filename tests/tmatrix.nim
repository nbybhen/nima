import unittest
import nima/matrix

suite "Basic operations":
  var matA: Matrix = newMatrix(2, 2, @[@[1, 2], @[3, 4]])
  var matB: Matrix = newMatrix(2, 2, @[@[5, 6], @[7, 8]])

  test "Addition":
    check matA + matB == newMatrix(2, 2, @[@[6, 8], @[10, 12]])

  test "Subtraction":
    check matA - matB == newMatrix(2, 2, @[@[-4, -4], @[-4, -4]])

  test "Multiplication (dot product)":
    check matA * matB == newMatrix(2, 2, @[@[19, 22], @[43, 50]])
