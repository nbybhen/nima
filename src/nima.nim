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
    option("--s", help="Value to multiply vector by", default=some("1"))
    run:
      if opts.scale:
        echo "Scaling vector..."
        var vecA = buildVector()
        vecA.scalarMult(opts.s.parseInt())
        echo &"VecA: {repr(vecA)}"
  command("matrix"):
    flag("--add", help="Add two matrices")
    flag("--sub", help="Subtract two matrices")
    flag("--mul", help="Multiply two matrices")
    flag("--det", help="Calculate determinant")
    run:
      let matA = buildMatrix("A")
      if opts.add:
        let matB = buildMatrix("B")
        echo &"Matrix C: {matA + matB}"
      elif opts.sub:
        let matB = buildMatrix("B")
        echo &"Matrix C: {matA - matB}"
      elif opts.mul:
        let matB = buildMatrix("B")
        echo &"Matrix C: {matA * matB}"
      elif opts.det:
        echo &"Determinant of Matrix A: {matA.determinant()}"
parser.run()
