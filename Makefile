define Documentation
	@file main.cpp

	@license MIT License

	Copyright (c) 2019 Caio Marcelo Campoy Guedes

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	@author Caio Marcelo Campoy Guedes <caio@assistatecnologia.com.br>
endef

CC = g++

# Folders
SRCDIR := src
BUILDDIR := build
TARGETDIR := bin
TESTBUILDDIR := build_tests

# Targets
EXECUTABLE := template-executable-name
TARGET := $(TARGETDIR)/$(EXECUTABLE)

# Final Paths
INSTALLBINDIR := /usr/local/bin

# Code Lists
SRCEXT := cpp
HEADEREXT := h
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))

# Folder Lists
INCDIRS := $(shell find $(SRCDIR)/**/* -name '*.$(SRCEXT)' -exec dirname {} \; | sort | uniq)
INCLIST := $(patsubst $(SRCDIR)/%,-I $(SRCDIR)/%,$(INCDIRS))
BUILDLIST := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(INCDIRS))

# Add installation dependecies on the list below, these will be installed using apt
PACKAGES += build-essential

# Shared Compiler Flags
CFLAGS := -std=c++17 -O3 -pedantic -Wpedantic -Wall -Wextra -Wunused -Wshadow -Wpointer-arith -Wcast-qual -Wno-missing-braces -ftree-vectorize
INC := -I include $(INCLIST) -I /usr/local/include
LIB := -pthread -lm -lrt

ifeq ($(debug), 1)
CFLAGS += -g -ggdb3 -D DEBUG -lasan -fasynchronous-unwind-tables
else
CFLAGS += -DNDEBUG
endif

ifeq ($(BUILDLIST),)
	BUILDLIST := ./build
endif

$(TARGET): $(OBJECTS)
	@mkdir -p $(TARGETDIR)
	@echo  "Linking all targets..."
	@$(CC) $^ -o $(TARGET) $(LIB)
	@echo "Successfully compiled at $(TARGET)"

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(BUILDLIST)
	@echo "CC    $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

memtest: $(TARGET)
	valgrind --leak-check=full --show-leak-kinds=all --log-file=valgrind-out.txt $(TARGET)

clean:
	@echo "Cleaning $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGETDIR)

distclean:
	@echo "Removing $(EXECUTABLE) "; rm $(INSTALLBINDIR)/$(EXECUTABLE)

install-dependencies:
	dpkg-query -W ${PACKAGES} || sudo apt-get install ${PACKAGES}

install:
	@echo "Installing $(EXECUTABLE)"; cp $(TARGET) $(INSTALLBINDIR)

run:
	${TARGET}

.PHONY: clean
