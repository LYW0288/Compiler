CC = gcc
F = flex
S = ./scanner

all:	scanner.l parser.y
	flex scanner.l
	byacc -d -v parser.y
	gcc  y.tab.c y.tab.h lex.yy.c code.c -ly -ll -o codegen
.PHONY: clean
clean:
	rm -f codegen lex.yy.c y.output y.tab.c y.tab.h

