Developer Notes
===============

<!-- markdown-toc start -->
**Table of Contents**

- [Developer Notes](#developer-notes)
    - [Coding Style (General)](#coding-style-general)
    - [Coding Style (C++)](#coding-style-c)
    - [Coding Style (Doxygen-compatible comments)](#coding-style-doxygen-compatible-comments)
    - [Development tips and tricks](#development-tips-and-tricks)
        - [Compiling for debugging](#compiling-for-debugging)
        - [Valgrind suppressions file](#valgrind-suppressions-file)
        - [Performance profiling with perf](#performance-profiling-with-perf)
    - [Ignoring IDE/editor files](#ignoring-ideeditor-files)
- [Development guidelines](#development-guidelines)
    - [General C++](#general-c)
    - [C++ data structures](#c-data-structures)
    - [Strings and formatting](#strings-and-formatting)
    - [Scripts](#scripts)
        - [Shebang](#shebang)
    - [Source code organization](#source-code-organization)
    - [Release notes](#release-notes)

<!-- markdown-toc end -->

Coding Style (General)
----------------------

Various coding styles have been used during my development process, the result
is a combination of my style and part of [Google's style guide](https://google.github.io/styleguide/cppguide.html).

Coding Style (C++)
------------------

- **Indentation and whitespace rules** as specified in
[src/.clang-format](/src/.clang-format). You can use the provided
  - Braces on the same line for everything.
  - 4 space indentation (no tabs) for every block.
  - No indentation for `public`/`protected`/`private`.
  - No extra spaces inside parenthesis; don't do ( this ).
  - No space after function names; one space after `if`, `for` and `while`.
  - If an `if` only has a single-statement `then`-clause, it can appear
    on the same line as the `if`, without braces. In every other case,
    braces are required, and the `then` and `else` clauses must appear
    correctly indented on a new line.

- **Symbol naming conventions**. 
  - Variable (including function arguments) and namespace names are all lowercase and should use `_` to separate words (snake_case).
    - Class member variables have a `m_` prefix.
    - Global variables have a `g_` prefix.
  - Constant names use camelCase and starts with a k (kThisIsConstant).
  - Class names, function names, and method names are camelCase.

- **Miscellaneous**
  - `++i` is preferred over `i++`.
  - `nullptr` is preferred over `NULL` or `(void*)0`.
  - `static_assert` is preferred over `assert` where possible. Generally; compile-time checking is preferred over run-time checking.
  - `enum class` is preferred over `enum` where possible. Scoped enumerations avoid two potential pitfalls/problems with traditional C++ enumerations: implicit conversions to int, and name clashes due to enumerators being exported to the surrounding scope.
  - `constexpr` is preferred over `const`
Block style example:
```c++
int g_count = 0;

namespace foo {
    class Class {
    private:
        std::string m_name;
    public:
        // Comment summarising what this section of code does, prefer DOXYGEN
        bool function(const std::string& s, int n) {
            for (int i = 0; i < n; ++i) {
                int total_sum = 0;
                // When something fails, return early
                if (!something()) return false;
                ...
                if (somethingElse(i)) {
                    total_sum += computeSomething(g_count);
                } else {
                    doSomething(m_name, total_sum);
                }
            }

            // Success return is usually at the end
            return true;
        }
    }
} // namespace foo
```

Coding Style (Doxygen-compatible comments)
------------------------------------------

Prefer [Doxygen](http://www.doxygen.nl/) to generate your documentation.

Use Doxygen-compatible comment blocks for functions, methods, and fields.

For example, to describe a function use:

```c++
/**
 * ... text ...
 * @brief Brief description
 * @param[in] arg1    A description
 * @param[in] arg2    Another argument description
 * @pre Precondition for function...
 */
bool function(int arg1, const char *arg2)
```

A complete list of `@xxx` commands can be found at http://www.doxygen.nl/manual/commands.html.
As Doxygen recognizes the comments by the delimiters (`/**` and `*/` in this case), you don't
*need* to provide any commands for a comment to be valid; just a description text is fine.

To describe a class, use the same construct above the class definition:
```c++
/**
 * Alerts are for notifying old versions if they become too obsolete and
 * need to upgrade. The message is displayed in the status bar.
 * @see GetWarnings()
 */
class CAlert {
```

To describe a member or variable use:
```c++
int var; //!< Detailed description after the member
```

or
```c++
//! Description before the member
int var;
```

A full list of comment syntaxes picked up by Doxygen can be found at http://www.doxygen.nl/manual/docblocks.html,
but the above styles are favored.

Development tips and tricks
---------------------------

### Compiling for debugging

Invoke the makefile with `-debug=1` to add additional compiler flags 
that produce better debugging builds.

### Valgrind suppressions file

### Performance profiling with perf

Profiling is a good way to get a precise idea of where time is being spent in
code. One tool for doing profiling on Linux platforms is called
[`perf`](http://www.brendangregg.com/perf.html), and has been integrated into
the functional test framework. Perf can observe a running process and sample
(at some frequency) where its execution is.

Perf installation is contingent on which kernel version you're running; see
[this StackExchange
thread](https://askubuntu.com/questions/50145/how-to-install-perf-monitoring-tool)
for specific instructions.

Certain kernel parameters may need to be set for perf to be able to inspect the
running process's stack.

```sh
$ sudo sysctl -w kernel.perf_event_paranoid=-1
$ sudo sysctl -w kernel.kptr_restrict=0
```

Make sure you [understand the security
trade-offs](https://lwn.net/Articles/420403/) of setting these kernel
parameters.

You could then analyze the results by running:

```sh
perf report --stdio | c++filt | less
```

or using a graphical tool like [Hotspot](https://github.com/KDAB/hotspot).

See the functional test documentation for how to invoke perf within tests.


**Sanitizers**

Bitcoin Core can be compiled with various "sanitizers" enabled, which add
instrumentation for issues regarding things like memory safety, thread race
conditions, or undefined behavior. This is controlled with the
`--with-sanitizers` configure flag, which should be a comma separated list of
sanitizers to enable. The sanitizer list should correspond to supported
`-fsanitize=` options in your compiler. These sanitizers have runtime overhead,
so they are most useful when testing changes or producing debugging builds.

Some examples:

```bash
# Enable both the address sanitizer and the undefined behavior sanitizer
./configure --with-sanitizers=address,undefined

# Enable the thread sanitizer
./configure --with-sanitizers=thread
```

If you are compiling with GCC you will typically need to install corresponding
"san" libraries to actually compile with these flags, e.g. libasan for the
address sanitizer, libtsan for the thread sanitizer, and libubsan for the
undefined sanitizer. If you are missing required libraries, the configure script
will fail with a linker error when testing the sanitizer flags.

Not all sanitizer options can be enabled at the same time, e.g. trying to build
with `--with-sanitizers=address,thread` will fail as
these sanitizers are mutually incompatible. Refer to your compiler manual to
learn more about these options and which sanitizers are supported by your
compiler.

Additional resources:

 * [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html)
 * [LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html)
 * [MemorySanitizer](https://clang.llvm.org/docs/MemorySanitizer.html)
 * [ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html)
 * [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
 * [GCC Instrumentation Options](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html)
 * [Google Sanitizers Wiki](https://github.com/google/sanitizers/wiki)
 * [Issue #12691: Enable -fsanitize flags in Travis](https://github.com/bitcoin/bitcoin/issues/12691)


Ignoring IDE/editor files
--------------------------

In closed-source environments in which everyone uses the same IDE, it is common
to add temporary files it produces to the project-wide `.gitignore` file.

However, in open source software, where everyone uses
their own editors/IDE/tools, it is less common. Only you know what files your
editor produces and this may change from version to version. The canonical way
to do this is thus to create your local gitignore. Add this to `~/.gitconfig`:

```
[core]
        excludesfile = /home/.../.gitignore_global
```

(alternatively, type the command `git config --global core.excludesfile ~/.gitignore_global`
on a terminal)

Then put your favourite tool's temporary filenames in that file, e.g.
```
# NetBeans
nbproject/
```

Another option is to create a per-repository excludes file `.git/info/exclude`.
These are not committed but apply only to one repository.

If a set of tools is used by the build system or scripts the repository (for
example, lcov) it is perfectly acceptable to add its files to `.gitignore`
and commit them.

Development guidelines
============================

A few non-style-related recommendations for developers.

General C++
-------------

For general C++ guidelines, you may refer to the [C++ Core
Guidelines](https://isocpp.github.io/CppCoreGuidelines/).

Common misconceptions are clarified in those sections:

- Passing (non-)fundamental types in the [C++ Core
  Guideline](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rf-conventional).

- Assertions should not have side-effects.

  - *Rationale*: Even though the source code is set to refuse to compile
    with assertions disabled, having side-effects in assertions is unexpected and
    makes the code harder to understand.

- If you use the `.h`, you must link the `.cpp`.

  - *Rationale*: Include files define the interface for the code in implementation files. Including one but
      not linking the other is confusing. Please avoid that. Moving functions from
      the `.h` to the `.cpp` should not result in build errors.

- Use the RAII (Resource Acquisition Is Initialization) paradigm where possible. For example, by using
  `unique_ptr` for allocations in a function.

  - *Rationale*: This avoids memory and resource leaks, and ensures exception safety.

- Use `MakeUnique()` to construct objects owned by `unique_ptr`s.

  - *Rationale*: `MakeUnique` is concise and ensures exception safety in complex expressions.
    `MakeUnique` is a temporary project local implementation of `std::make_unique` (C++14).

C++ data structures
--------------------

- Never use the `std::map []` syntax when reading from a map, but instead use `.find()`.

  - *Rationale*: `[]` does an insert (of the default element) if the item doesn't
    exist in the map yet. This has resulted in memory leaks in the past, as well as
    race conditions (expecting read-read behavior). Using `[]` is fine for *writing* to a map.

- Do not compare an iterator from one data structure with an iterator of
  another data structure (even if of the same type).

  - *Rationale*: Behavior is undefined. In C++ parlor this means "may reformat
    the universe", in practice this has resulted in at least one hard-to-debug crash bug.

- Watch out for out-of-bounds vector access. `&vch[vch.size()]` is illegal,
  including `&vch[0]` for an empty vector. Use `vch.data()` and `vch.data() +
  vch.size()` instead.

- Vector bounds checking is only enabled in debug mode. Do not rely on it.

- Initialize all non-static class members where they are defined.
  If this is skipped for a good reason (i.e., optimization on the critical
  path), add an explicit comment about this.

  - *Rationale*: Ensure determinism by avoiding accidental use of uninitialized
    values. Also, static analyzers balk about this.
    Initializing the members in the declaration makes it easy to
    spot uninitialized ones.

```cpp
class A {
    uint32_t m_count{0};
}
```

- By default, declare single-argument constructors `explicit`.

  - *Rationale*: This is a precaution to avoid unintended conversions that might
    arise when single-argument constructors are used as implicit conversion
    functions.

- Use explicitly signed or unsigned `char`s, or even better `uint8_t` and
  `int8_t`. Do not use bare `char` unless it is to pass to a third-party API.
  This type can be signed or unsigned depending on the architecture, which can
  lead to interoperability problems or dangerous conditions such as
  out-of-bounds array accesses.

- Prefer explicit constructions over implicit ones that rely on 'magical' C++ behavior.

  - *Rationale*: Easier to understand what is happening, thus easier to spot mistakes, even for those
  that are not language lawyers.

Strings and formatting
------------------------
- Use `std::string`, avoid C string manipulation functions.

  - *Rationale*: C++ string handling is marginally safer, less scope for
    buffer overflows, and surprises with `\0` characters. Also, some C string manipulations
    tend to act differently depending on platform, or even the user locale.

- Avoid using locale dependent functions if possible. You can use the provided

  - *Rationale*: Unnecessary locale dependence can cause bugs that are very tricky to isolate and fix.

  - These functions are known to be locale dependent:
    `alphasort`, `asctime`, `asprintf`, `atof`, `atoi`, `atol`, `atoll`, `atoq`,
    `btowc`, `ctime`, `dprintf`, `fgetwc`, `fgetws`, `fprintf`, `fputwc`,
    `fputws`, `fscanf`, `fwprintf`, `getdate`, `getwc`, `getwchar`, `isalnum`,
    `isalpha`, `isblank`, `iscntrl`, `isdigit`, `isgraph`, `islower`, `isprint`,
    `ispunct`, `isspace`, `isupper`, `iswalnum`, `iswalpha`, `iswblank`,
    `iswcntrl`, `iswctype`, `iswdigit`, `iswgraph`, `iswlower`, `iswprint`,
    `iswpunct`, `iswspace`, `iswupper`, `iswxdigit`, `isxdigit`, `mblen`,
    `mbrlen`, `mbrtowc`, `mbsinit`, `mbsnrtowcs`, `mbsrtowcs`, `mbstowcs`,
    `mbtowc`, `mktime`, `putwc`, `putwchar`, `scanf`, `snprintf`, `sprintf`,
    `sscanf`, `stoi`, `stol`, `stoll`, `strcasecmp`, `strcasestr`, `strcoll`,
    `strfmon`, `strftime`, `strncasecmp`, `strptime`, `strtod`, `strtof`,
    `strtoimax`, `strtol`, `strtold`, `strtoll`, `strtoq`, `strtoul`,
    `strtoull`, `strtoumax`, `strtouq`, `strxfrm`, `swprintf`, `tolower`,
    `toupper`, `towctrans`, `towlower`, `towupper`, `ungetwc`, `vasprintf`,
    `vdprintf`, `versionsort`, `vfprintf`, `vfscanf`, `vfwprintf`, `vprintf`,
    `vscanf`, `vsnprintf`, `vsprintf`, `vsscanf`, `vswprintf`, `vwprintf`,
    `wcrtomb`, `wcscasecmp`, `wcscoll`, `wcsftime`, `wcsncasecmp`, `wcsnrtombs`,
    `wcsrtombs`, `wcstod`, `wcstof`, `wcstoimax`, `wcstol`, `wcstold`,
    `wcstoll`, `wcstombs`, `wcstoul`, `wcstoull`, `wcstoumax`, `wcswidth`,
    `wcsxfrm`, `wctob`, `wctomb`, `wctrans`, `wctype`, `wcwidth`, `wprintf`

- For `strprintf`, `LogPrint`, `LogPrintf` formatting characters don't need size specifiers.

  - *Rationale*: Bitcoin Core uses tinyformat, which is type safe. Leave them out to avoid confusion.

Scripts
--------------------------

### Shebang

- Use `#!/usr/bin/env bash` instead of obsolete `#!/bin/bash`.

  - [*Rationale*](https://github.com/dylanaraps/pure-bash-bible#shebang):

    `#!/bin/bash` assumes it is always installed to /bin/ which can cause issues;

    `#!/usr/bin/env bash` searches the user's PATH to find the bash binary.

  OK:
```bash
#!/usr/bin/env bash
```

  Wrong:
```bash
#!/bin/bash
```

Source code organization
--------------------------

- Implementation code should go into the `.cpp` file and not the `.h`, unless necessary due to template usage or
  when performance due to inlining is critical.

  - *Rationale*: Shorter and simpler header files are easier to read and reduce compile time.

- Use only the lowercase alphanumerics (`a-z0-9`), underscore (`_`) and hyphen (`-`) in source code filenames.

  - *Rationale*: `grep`:ing and auto-completing filenames is easier when using a consistent
    naming pattern. Potential problems when building on case-insensitive filesystems are
    avoided when using only lowercase characters in source code filenames.

- Every `.cpp` and `.h` file should `#include` every header file it directly uses classes, functions or other
  definitions from, even if those headers are already included indirectly through other headers.

  - *Rationale*: Excluding headers because they are already indirectly included results in compilation
    failures when those indirect dependencies change. Furthermore, it obscures what the real code
    dependencies are.

- Don't import anything into the global namespace (`using namespace ...`). Use
  fully specified types such as `std::string`.

  - *Rationale*: Avoids symbol conflicts.

- Terminate namespaces with a comment (`// namespace mynamespace`). The comment
  should be placed on the same line as the brace closing the namespace, e.g.

```c++
namespace mynamespace {
...
} // namespace mynamespace

namespace {
...
} // namespace
```

  - *Rationale*: Avoids confusion about the namespace context.

- Use `#include <primitives/transaction.h>` bracket syntax instead of
  `#include "primitives/transactions.h"` quote syntax.

  - *Rationale*: Bracket syntax is less ambiguous because the preprocessor
    searches a fixed list of include directories without taking location of the
    source file into account. This allows quoted includes to stand out more when
    the location of the source file actually is relevant.

- Use include guards to avoid the problem of double inclusion. The header file
  `foo/bar.h` should use the include guard identifier `BITCOIN_FOO_BAR_H`, e.g.

```c++
#ifndef BITCOIN_FOO_BAR_H
#define BITCOIN_FOO_BAR_H
...
#endif // BITCOIN_FOO_BAR_H
```

Release notes
-------------

Release notes should be written for any PR that:

- introduces a notable new feature
- fixes a significant bug
- changes an API or configuration model
- makes any other visible change to the end-user experience.

Release notes should be added to a PR-specific release note file at
`/doc/release-notes-<PR number>.md` to avoid conflicts between multiple PRs.
All `release-notes*` files are merged into a single
[/doc/release-notes.md](/doc/release-notes.md) file prior to the release.
