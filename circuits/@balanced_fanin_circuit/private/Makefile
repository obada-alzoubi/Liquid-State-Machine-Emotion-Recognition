default: fanin_conn.mexglx rand_conn.mexglx mirror_conn.mexglx gradient_conn.mexglx patch_conn.mexglx randpos_conn.mexglx

fanin_conn.mexglx: fanin_conn.c randgen.c
	mex fanin_conn.c randgen.c

rand_conn.mexglx: rand_conn.c randgen.c
	mex rand_conn.c randgen.c

mirror_conn.mexglx: mirror_conn.c randgen.c
	mex mirror_conn.c randgen.c

gradient_conn.mexglx: gradient_conn.c randgen.c
	mex gradient_conn.c randgen.c

patch_conn.mexglx: patch_conn.c randgen.c
	mex patch_conn.c randgen.c

randpos_conn.mexglx: randpos_conn.c randgen.c
	mex randpos_conn.c randgen.c

clean:
	@rm -f fanin_conn.mexglx rand_conn.mexglx mirror_conn.mexglx gradient_conn.mexglx patch_conn.mexglx randpos_conn.mexglx

distclean:
	@rm -f *.o

mrproper:
	@rm -f fanin_conn.mexglx rand_conn.mexglx mirror_conn.mexglx gradient_conn.mexglx patch_conn.mexglx randpos_conn.mexglx *.o
