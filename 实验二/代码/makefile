a.out : main.c my_print.o
	gcc -g main.c my_print.o
my_print.o : my_print.asm
	nasm -felf64 my_print.asm
clean : 
	rm my_print.o