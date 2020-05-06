cmake_minimum_required(VERSION 3.10.2)
project(parseme)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -s")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -DNDEBUG -s")
add_executable(parseme main.cpp token.h lexer.cpp lexer.h parser.cpp parser.h crypto.h aes.cpp aes.h des.cpp des.h crypto.cpp rc4.cpp rc4.h)