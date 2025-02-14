import nima/matrix
import std/strformat
import argparse

proc writeVersion(): string = "0.0.1"

var parser = newParser:
  help(&"Nima {writeVersion()} (CLI calculator)")
  run:
    echo parser.help
  command("matrix"):
    flag("--add", help="Add two numbers")
    run:
      if opts.add:
        echo "Adding two matrices..."
        var
          matA = buildMatrix("A")
          matB = buildMatrix("B")
        echo &"Matrix C: {matA + matB}"
parser.run()
