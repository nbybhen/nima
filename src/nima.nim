import nima/matrix
import nima/vector
import std/strformat
import std/rdstdin
import argparse

proc writeVersion(): string = "0.0.1"

var parser = newParser:
  help(&"Nima {writeVersion()} (CLI calculator)")
  command("vector"):
    flag("--scale", help="Multiplies vector by scalar")
    option("--val", help="Value to multiply vector by", default=some("1"))
    run:
      if opts.scale:
        echo "Scaling vector..."
        var vecA = buildVector()
        vecA.scalarMult(opts.val.parseInt())
        echo &"VecA: {repr(vecA)}"
  command("matrix"):
    flag("--add", help="Add two numbers")
    flag("--det", help="Calculate determinant")
    run:
      if opts.add:
        echo "Adding two matrices..."
        var
          matA = buildMatrix("A")
          matB = buildMatrix("B")
        echo &"Matrix C: {matA + matB}"
      elif opts.det:
        echo "Calculating determinant..."
        var
          matA = buildMatrix("A")
        echo &"Determinant of Matrix A: {matA.determinant()}"
parser.run()
