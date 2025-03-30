type
  IntOrFloat* = int | float
  Vector*[T: IntOrFloat] = seq[T]
  Matrix*[T: IntOrFloat] = object
    rows*, cols* = 0
    data*: seq[Vector[T]]
