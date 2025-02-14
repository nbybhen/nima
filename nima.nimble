# Package

version       = "0.1.0"
author        = "nbybhen"
description   = "A CLI calculator"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nima"]


# Dependencies

requires "nim >= 2.2.2"
requires "argparse >= 4.0.0"
