all:
	flex -o scanner.c scanner.l
	gcc -o scanner -lfl scanner.c
	./scanner test.txt

clean:
	rm scanner scanner.c
