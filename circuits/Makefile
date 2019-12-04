SUBDIRS=@neural_microcircuit/private @balanced_fanin_circuit/private

default: aliases subdirs

aliases:
	@ln -f -s neural_microcircuit.m @neural_microcircuit/multi_pool_circuit.m 
	@ln -f -s @neural_microcircuit @multi_pool_circuit
	@ln -f -s small_microcircuit.m @small_microcircuit/small_circuit_template.m 
	@ln -f -s @small_microcircuit @small_circuit_template

subdirs: $(SUBDIRS)
	@(for i in $(SUBDIRS); do $(MAKE) -C $$i; done)


clean:
	@(for i in $(SUBDIRS); do $(MAKE) -C $$i clean; done)
	rm -f @small_circuit_template @multi_pool_circuit @neural_microcircuit/multi_pool_circuit.m @small_microcircuit/small_circuit_template.m
 
distclean:
	@(for i in $(SUBDIRS); do $(MAKE) -C $$i distclean; done)
	@rm -f *~
	@find . -name auto -exec rm -rf {} \;

mrproper:
	@(for i in $(SUBDIRS); do $(MAKE) -C $$i clean; done)
	@rm -f *~
	@find . -name auto -exec rm -rf {} \;
