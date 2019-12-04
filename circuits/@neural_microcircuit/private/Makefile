default: conn.mexglx

conn.mexglx: conn.c randgen.c
	mex conn.c randgen.c

clean:
	@rm -f conn.mexglx

distclean:
	@rm -f *.o

mrproper:
	@rm -f conn.mexglx *.o
