=Basic Fortran project=

This is a basic makefile to set up fortran projects, which includes automatic
module dependancy generation.

Directory structure:

* src/bin: Each file will be compiled into a binary and put into `bin`.
* src/test: Each file will be compiled into a binary and put into `test`. The
  binaries will be run when calling `make check`
* src/lib: Each directory will be compiled into a static library and put under
  `lib`, the libraries will be linked with the binaries.

