import nima/[types, matrix, vector]
import solver/[parser, calc, interpreter]
import std/[strformat, sugar, math, rdstdin, sequtils]
import argparse

proc writeVersion(): string = "0.0.1"

proc buildMatrix*(name: string): Matrix[float] =
  let
    dim = readLineFromStdin(&"Enter the dimensions for Matrix {name} (e.g. '2x2'): ")
    s = split(dim, {'x'}, 1)
  (result.rows, result.cols) = (s[0].parseInt, s[1].parseInt)

  echo "Enter the matrix row by row (space-separated): "

  # TODO: Exception handling
  for i in 0..<result.rows:
    let row = readLine(stdin).splitWhitespace()
    assert(row.len == result.cols, &"Invalid number of arguments supplied: received {row.len} args, but expected {result.cols}.")
    result.data.add(row.mapIt(it.parseFloat))

proc buildVector*(name: string): Vector[float] =
  echo "Enter vector elements separated by spaces: "
  result = readLine(stdin).splitWhitespace().mapIt(it.parseFloat)

proc soeRepl(): Matrix[float] =
  # TODO: Exception handling + input cleaning
  let num = readLineFromStdin("Enter the number of equations (e.g. 3): ").parseInt
  var mtx = initMatrix[float](num, num, d = @[])
  var vec = initMatrix[float](num, 1, d = @[initVector[float]()])
  for i in 0..<num:
    mtx.data[i] = (readLine(stdin).splitWhitespace().mapIt(it.parseFloat))
    vec.data[i] = @[mtx.data[i].pop()]
    if i != num - 1:
      mtx.data.add(@[])
      vec.data.add(@[])
  result = mtx.inverse()
  result = (result * vec)
  result.data = result.data.mapIt(it.map(x => round(x, 2)))

when isMainModule:
  while true:
    let repl = readLineFromStdin("\n> ")
    var lexer = Lexer(src: repl)
    
    var p = Parser(src: lexer.tokenize())
    let parsed = p.parse()
    p.print(parsed)

    var compiler = Interpreter(tree: parsed)
    compiler.interpret()

  # var parser = newParser:
  #   help(&"Nima {writeVersion()} (CLI calculator)")
  #   command("solve"):
  #     flag("--soe", help="Solves a system of equations")
  #     run:
  #       if opts.soe:
  #         echo "Solving system of equations..."
  #         # TODO: Format returned data
  #         echo &"Solution: {soeRepl().data}"
  #   command("vector"):
  #     flag("--scale", help="Multiplies vector by scalar")
  #     option("--s", help="Value to multiply vector by", default=some("1"))
  #     run:
  #       if opts.scale:
  #         echo "Scaling vector..."
  #         var vecA = buildVector("A")
  #         vecA.scalarMult(opts.s.parseFloat())
  #         echo &"Vector A: {repr(vecA)}"
  #   command("matrix"):
  #     flag("--add", help="Add two matrices")
  #     flag("--sub", help="Subtract two matrices")
  #     flag("--mul", help="Multiply two matrices")
  #     flag("--det", help="Calculate determinant")
  #     flag("--inv", help="Calculate inverse")
  #     run:
  #       let matA = buildMatrix("A")
  #       if opts.add:
  #         let matB = buildMatrix("B")
  #         echo &"Matrix C: {matA + matB}"
  #       elif opts.sub:
  #         let matB = buildMatrix("B")
  #         echo &"Matrix C: {matA - matB}"
  #       elif opts.mul:
  #         let matB = buildMatrix("B")
  #         echo &"Matrix C: {matA * matB}"
  #       elif opts.det:
  #         echo &"Determinant of Matrix A: {matA.determinant()}"
  #       elif opts.inv:
  #         echo &"Inverse of Matrix A: {repr(matA.inverse())}"
  # parser.run()
