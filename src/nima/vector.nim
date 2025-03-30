import std/sequtils
import types

proc initVector*[T: IntOrFloat](data: seq[T] = @[]): Vector[T] = data

func scalarMult*[T](self: var Vector[T], scalar: T) =
  self.applyIt(it * scalar)

# === Operator Overloading ===

proc `+`*[T](self, other: Vector[T]): Vector[T] {.inline.} =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] + it[1]))

proc `-`*[T](self, other: Vector[T]): Vector[T] {.inline.} =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] - it[1]))

proc `*`*[T](self, other: Vector[T]): T {.inline.} =
  assert(self.len == other.len, "Vectors must be the same length")
  zip(self, other).mapIt(it[0] * it[1]).foldl(a + b)

proc `*=`*[T](self: var Vector[T], scalar: T) {.inline.} =
  self.applyIt(it * scalar)
