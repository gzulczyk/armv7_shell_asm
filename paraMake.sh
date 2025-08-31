as -o main.o main.s
as -o read.o read.s
as -o display.o display.s
as -o execute.o execute.s
as -o concat.o concat.s
as -o end.o end.s
as -o not_found.o not_found.s

ld -o shell main.o read.o display.o execute.o concat.o end.o not_found.o