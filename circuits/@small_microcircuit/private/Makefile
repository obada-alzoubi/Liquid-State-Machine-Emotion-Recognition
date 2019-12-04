default: conn.mexglx

conn.mexglx: asamin.c asa.c
	mex asamin.c asa.c -DUSER_ACCEPTANCE_TEST#TRUE -DUSER_ASA_OUT#TRUE

clean:
	@rm -f conn.mexglx

distclean:
	@rm -f *.o

mrproper:
	@rm -f conn.mexglx *.o
