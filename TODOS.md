## Features

### General
- [x] Add unit tests
- [x] Add CLI parsing
- [ ] Static alternatives (?)
- [ ] Trace dynamic size
- [ ] Complete REPL
- [ ] Add flag for verbose debugging

### Matrices
Planning on taking heavy functionality inspiration from Ruby's `Matrix` library (listed [in References](#references-and-resources))
- [x] Basic operations `(+, -, *)`
- [x] Scalar multiplication
- [x] Dot product
- [x] Determinant
- [x] Convert to `Matrix[T]`
- [x] Inverse
- [x] Transpose

### Vectors
- [x] Basic operations (+, -, *)
- [ ] Scalar multiplication
- [x] Convert to `Vector[T]`

### Solver
- [x] Systems of equations

### Expressions (TODO)
Working on creating a REPL for practical usage of the nima library using an interpreter. Currently in the process of both designing how the REPL should be interacted with syntactically, while also testing different implementations within the lexing / parsing / interpreting process!
- [ ] "Complete" basic syntax for REPL
- [ ] Implement basic data types (match with `nima`'s data types)
- [ ] Implement operations on types
- [ ] Implement functions
- [ ] Implement flag for debug printing

## References and Resources
Since this project is mostly for educational purpose (both in software development as well as mathematics), I thought it'd be helpful to compile a list of some of the most valuable sources used for learning during development:
- [3Blue1Brown](https://www.youtube.com/@3blue1brown)
- [Ruby's `Matrix` library implementation](https://github.com/ruby/matrix/blob/master/lib/matrix.rb)