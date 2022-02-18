all:
	bison -d bison.y
	flex flex.l
	gcc -o parser bison.tab.c lex.yy.c
clean:
	rm bison.tab.c bison.tab.h lex.yy.c parser
