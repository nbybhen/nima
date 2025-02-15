import nima/matrix
import std/strformat
import argparse

proc writeVersion(): string = "0.0.1"

var parser = newParser:
  help(&"Nima {writeVersion()} (CLI calculator)")
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
