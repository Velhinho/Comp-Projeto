LANG=minor
EXT=spl# file extension: .$(EXT)
LIB=lib# compiler library directory
UTIL=util# compiler library: lib$(LIB).a
RUN=run# runtime directory
EXS=exs# examples directory
CC=gcc
CFLAGS=-g -DYYDEBUG
LDLIBS=run/lib$(LANG).a
AS=nasm -felf32
LD=ld -m elf_i386

.SUFFIXES: .asm $(EXT)

$(LANG): minor.y minor.l code.brg
	byacc -dv minor.y
	flex -ld minor.l
	$(CC) -o $(LANG) $(CFLAGS) -lfl lex.yy.c y.tab.c


clean::
	make -C $(LIB) clean
	make -C $(RUN) clean
	make -C $(EXS) clean
	rm -f *.o $(LANG) lib$(LANG).a lex.yy.c y.tab.c y.tab.h y.tab.h.gch y.output yyselect.c *.asm *~
