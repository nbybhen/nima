import std/sequtils

type Vector*[T] = seq[T]

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

proc newVector*[T](data: seq[T]): Vector[T] =
  result = data

proc scalarMult*[T](self: var Vector[T], scalar: T) =
  self.applyIt(it * scalar)
