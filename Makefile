CXX = zig c++
CFLAGS = -std=c++17 -O2 -Werror -Wall -Wextra
LDFLAGS = -lglfw -lvulkan -ldl

vulkman: vulkman.cpp

.PHONY: clean

clean:
	rm -f ./vulkman
