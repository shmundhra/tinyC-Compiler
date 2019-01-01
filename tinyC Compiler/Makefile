all: compile.out

compile: lex.yy.o y.tab.o ass6_16CS10057_translator.o 
	g++ lex.yy.o y.tab.o ass6_16CS10057_translator.o -lfl -o compile
	# Enter 'make run' to generate Quad and Assembly Language File 

y.tab.o:	y.tab.c
	g++ -c y.tab.c

lex.yy.o:	lex.yy.c
	g++ -c lex.yy.c

lex.yy.c:	ass6_16CS10057.l y.tab.c
	flex ass6_16CS10057.l

y.tab.c:	ass6_16CS10057.y
	yacc --verbose -dtv ass6_16CS10057.y

ass6_16CS10057_translator.o: ass6_16CS10057_translator.h ass6_16CS10057_translator.cxx
	g++ -c ass6_16CS10057_translator.cxx

myl.o:	myl.c myl.h
	gcc -c myl.c

clean:
	rm compile.out compile y.tab.o lex.yy.o lex.yy.c y.tab.c y.tab.h y.output ass6_16CS10057_translator.o test1_quads.s test2_quads.s test3_quads.s test4_quads.s test5_quads.s test1.out test2.out test3.out test4.out test5.out


run:
	./compile < ass6_16CS10057_test1.c > test1_quads.s
	./compile < ass6_16CS10057_test2.c > test2_quads.s
	./compile < ass6_16CS10057_test3.c > test3_quads.s
	./compile < ass6_16CS10057_test4.c > test4_quads.s
	./compile < ass6_16CS10057_test5.c > test5_quads.s