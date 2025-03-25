import std/sequtils
import types

type Vector*[T: IntOrFloat] = seq[T]

proc newVector*[T: IntOrFloat](data: seq[T]): Vector[T] =
  result = data

template initVector*[T: IntOrFloat](d: seq[T] = @[]): Vector[T] =
  d

func scalarMult*[T](self: var Vector[T], scalar: T) =
  self.applyIt(it * scalar)

proc `+`*[T](self, other: Vector[T]): Vector[T] =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] + it[1]))

proc `-`*[T](self, other: Vector[T]): Vector[T] =
  assert(self.len == other.len, "Vectors must be the same length")
  result.add(zip(self, other).mapIt(it[0] - it[1]))

proc `*`*[T](self, other: Vector[T]): T =
  assert(self.len == other.len, "Vectors must be the same length")
  zip(self, other).mapIt(it[0] * it[1]).foldl(a + b)

proc `*=`*[T](self: var Vector[T], scalar: T) =
  self.applyIt(it * scalar)
