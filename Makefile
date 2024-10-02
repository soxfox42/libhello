all: shared static included precompiled dynamic optimized fortran \
	julia python r cpp luajit rust zig ruby ada go gforth
	@ # cobol clisp freebasic

setup:
	@ mkdir -p bin lib build

libhello: setup
	@ gcc -fPIC -shared -o lib/libhello.so src/libhello.c -Iinclude

shared: libhello
	@ echo -e "\e[35mUsing shared library.\e[m"
	@ gcc -o bin/shared_hello src/hello.c -Llib -lhello -Iinclude
	@ LD_LIBRARY_PATH=lib bin/shared_hello

static: setup
	@ echo -e "\e[35mUisng static library.\e[m"
	@ gcc -c -o build/libhello.o src/libhello.c -Iinclude
	@ ar rcs lib/libhello.a build/libhello.o
	@ gcc -o bin/static_hello src/hello.c lib/libhello.a -Iinclude
	@ bin/static_hello

included: setup
	@ echo -e "\e[35mUsing included library.\e[m"
	@ gcc -o bin/included_hello src/included_hello.c -Iinclude
	@ bin/included_hello

precompiled: setup
	@ echo -e "\e[35mUsing precompiled header and code.\e[m"
	@ gcc -x c-header include/libhello.h -o build/libhello.h.gch
	@ gcc -c src/libhello.c -o build/libhello.o -Iinclude
	@ gcc -o bin/precompiled_hello src/hello.c build/libhello.o -include include/libhello.h -Iinclude
	@ bin/precompiled_hello

dynamic: libhello
	@ echo -e "\e[35mUsing dynamic linking.\e[m"
	@ gcc -o bin/dynamic_hello src/dynamic_hello.c -ldl -Iinclude
	@ bin/dynamic_hello

optimized: setup
	@ echo -e "\e[35mUsing link time optimization.\e[m"
	@ gcc -c -O2 -flto src/libhello.c -o build/libhello.o -Iinclude
	@ gcc -c -O2 -flto src/hello.c -o build/hello.o -Iinclude
	@ gcc -O2 -flto build/hello.o build/libhello.o -o bin/optimized_hello -Iinclude
	@ bin/optimized_hello

fortran: libhello
	@ echo -e "\e[35mUsing Fortran bindings.\e[m"
	@ gfortran -c -o build/hello_f90.o src/hello.f90 -Jbuild -Iinclude
	@ gfortran -o bin/fortran_hello build/hello_f90.o -Llib -lhello -Jbuild
	@ LD_LIBRARY_PATH=lib bin/fortran_hello

cobol: libhello
	@ echo -e "\e[35mUsing Cobol bindings.\e[m"
	@ cobc -O2 -o bin/cobol_hello src/hello.cbl -Llib -lhello
	@ LD_LIBRARY_PATH=lib bin/cobol_hello

julia: libhello
	@ echo -e "\e[35mUsing Julia bindings.\e[m"
	@ julia src/hello.jl

python: libhello
	@ echo -e "\e[35mUsing Python bindings.\e[m"
	@ python src/hello.py

r: libhello
	@ echo -e "\e[35mUsing R bindings.\e[m"
	@ Rscript src/hello.R

cpp: libhello
	@ echo -e "\e[35mUsing C++ bindings.\e[m"
	@ g++ -o bin/cpp_hello src/hello.cpp -Llib -lhello -Iinclude
	@ LD_LIBRARY_PATH=lib bin/cpp_hello

luajit: libhello
	@ echo -e "\e[35mUsing LuaJIT bindings.\e[m"
	@ luajit src/hello.lua

zig: libhello
	@ echo -e "\e[35mUsing Zig bindings.\e[m"
	@ zig build-obj src/hello.zig -Llib -lhello -lc -femit-bin=build/zig_hello.o > /dev/null 2>&1
	@ zig build-exe build/zig_hello.o -Llib -lhello -lc -femit-bin=bin/zig_hello > /dev/null 2>&1
	@ LD_LIBRARY_PATH=lib bin/zig_hello

rust: libhello
	@ echo -e "\e[35mUsing Rust bindings.\e[m"
	@ cd src/rust_hello && cargo build --quiet --release
	@ LD_LIBRARY_PATH=lib src/rust_hello/target/release/rust_hello

clisp: libhello
	@ echo -e "\e[35mUsing CLisp bindings.\e[m"
	@ clisp src/hello.lisp

ruby: libhello
	@ echo -e "\e[35mUsing Ruby bindings.\e[m"
	@ ruby src/hello.rb

ada: libhello
	@ echo -e "\e[35mUsing Ada bindings.\e[m"
	@ gnatmake -q -c -Iinclude -o build/hello.o src/hello.adb
	@ mv hello.ali hello.o libhello.ali libhello.o build
	@ gnatbind -x build/hello.ali
	@ gnatlink build/hello.ali -Llib -lhello -o bin/ada_hello
	@ LD_LIBRARY_PATH=lib bin/ada_hello

go: libhello
	@ echo -e "\e[35mUsing Go bindings.\e[m"
	@ go build -o bin/go_hello src/hello.go
	@ LD_LIBRARY_PATH=lib bin/go_hello

freebasic: libhello
	@ echo -e "\e[35mUsing FreeBASIC bindings.\e[m"
	@ fbc -o bin/freebasic_hello src/hello.bas -p hello -l lib
	@ LD_LIBRARY_PATH=lib bin/freebasic_hello

gforth: libhello
	@ echo -e "\e[35mUsing GForth bindings.\e[m"
	@ C_INCLUDE_PATH=include LIBRARY_PATH=lib LD_LIBRARY_PATH=lib gforth src/hello.fth

clean:
	@ rm -rf build bin lib src/rust_hello/target