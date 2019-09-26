# CPPTemplate

This project gives you a complete C++17 template. Remove the example in the src folder and start coding! The only requisite is that you have a compiler that supports C++17 and Make. 

[READ THE DEVELOPER NOTES](https://github.com/caiomcg/CPPTemplate/blob/master/doc/developer-notes.md)


## Make options

The provided Makefile is shipped with my prefered compilation flags, change them however you like and don't forget to rename the executable.

### Targets

* default: Will compile your executable
* clean: Will remove the created folders with the object file and executable (bin/build)
* distclean: Will remove the executable from the computer (if intalled)
* install: Install the executable at the desired folder (defaults to: /user/local/bin
* run: Runs the executable at bin
* memtest: Invokes valgrind with leack check full and show all leaks

### Options

The makefile provides the option to enable debugging for the application, if this is the case the debug flag will be activated along with address sanitizer and it will enable the DEBUG macro that can be used throughout your implementation.

### Compilation flags

* -std=c++17: Enables C++ 17
* -O3: Highest level of optimization
* -pedantic: Issue all the warnings demanded by strict ISO C and ISO C++
* -WPedantic: Does not cause warning messages for use of the alternate keywords whose names begin and end with ‘__’
* -Wall: Enables all the warnings about constructions that some users consider questionable
* -Wextra: Enables some extra warning flags that are not enabled by -Wall
* -Wunused: Enables unused variables warnings
* -Wshadow: Warn whenever a local variable or type declaration shadows another variable
* -Wpointer-arith: Warn about anything that depends on the “size of” a function type or of void
* -Wcast-qual: Warn whenever a pointer is cast so as to remove a type qualifier from the target type
* -Wno-missing-braces: Warn missing braces
* -ftree-vectorize: Vectorizes loops whenever possible
