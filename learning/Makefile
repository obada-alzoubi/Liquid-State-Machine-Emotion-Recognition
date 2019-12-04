
SUBDIRS=svm_toolbox/@rbf svm_toolbox/@smosvctutor

default: subdirs spikes2alpha.mexglx spikes2exp.mexglx spikes2count.mexglx

subdirs: $(SUBDIRS)
	@(for i in $(SUBDIRS); do $(MAKE) -C $$i; done)


spikes2alpha.mexglx: spikes2alpha.c
	mex -O spikes2alpha.c

spikes2exp.mexglx: spikes2exp.c
	mex -O spikes2exp.c  

spikes2count.mexglx: spikes2count.c
	mex -O spikes2count.c

spikes2alpha.c: spikes2pulse.c
	sed -e s/SPIKES2PULSE/SPIKES2ALPHA/ -e s%__PULSE_TYPE__%"*x += ((tmp=delta/tau1)<-30) ? 0 : (exp(tmp)-exp(delta/tau2));"% spikes2pulse.c > spikes2alpha.c

spikes2exp.c: spikes2pulse.c
	sed -e s/SPIKES2PULSE/SPIKES2EXP/   -e s%__PULSE_TYPE__%"*x += ((tmp=delta/tau1)<-30) ? 0 : exp(tmp);"% spikes2pulse.c > spikes2exp.c

spikes2count.c: spikes2pulse.c
	sed -e s/SPIKES2PULSE/SPIKES2COUNT/ -e s%__PULSE_TYPE__%"*x += (int)(delta>-tau1); "% spikes2pulse.c > spikes2count.c

mrproper: clean

clean:
	rm -f  spikes2alpha.c spikes2exp.c spikes2count.c *.mexglx:

distclean:
	rm -f *.o
