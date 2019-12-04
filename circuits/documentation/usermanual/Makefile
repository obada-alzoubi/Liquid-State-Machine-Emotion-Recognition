L2HUTILS=../../../develop/post_l2h

NAVBUTTONS=$(L2HUTILS)/contents.gif $(L2HUTILS)/next.gif $(L2HUTILS)/prev.gif \
	   $(L2HUTILS)/contents.png $(L2HUTILS)/next.png $(L2HUTILS)/prev.png

POSTL2H = $(L2HUTILS)/post_l2h

TEXFILES = usermanual.tex \
	   um-tp-html.tex \
           um-tp-paper.tex \
	   about.tex \
           prelim.tex \
           tutorial.tex \
	   input_output.tex \
           neural_microcircuit.tex \
	   delay_lines.tex \
	   small_circuits.tex

EPSFIG=$(wildcard *.eps)
PDFFIG=$(patsubst %.eps,%.pdf,$(EPSFIG))

default: dvi pdf ps html

pdf: $(PDFFIG) usermanual.pdf

dvi: usermanual.dvi

ps: usermanual.ps.gz

html: usermanual.html

usermanual.html: $(TEXFILES) usermanual.bbl latex2html-init usermanual.dvi
	@echo running latex2html ...
	@latex2html -init_file latex2html-init -image_type gif -local_icons -white -math -html_version 4.0 -antialias usermanual > /dev/null
	@echo post processing latex2html output ...
	@(for f in *.html; do \
            $(POSTL2H) $$f > /tmp/f.$$$$; \
            mv /tmp/f.$$$$ $$f; \
          done; )
	@cp $(NAVBUTTONS) .

usermanual.pdf: $(TEXFILES) usermanual.bbl
	@( echo "generating $@ ..." ; \
	   aux=`basename $< .tex`.aux ; \
	   rm -rf $$aux ; \
	   log=`basename $< .tex`.log ; \
	   pdflatex $< > /dev/null 2>&1 ; \
	   pdflatex $< > /dev/null 2>&1 ; \
	   latex_count=5 ; \
	   while egrep -s 'Rerun (LaTeX|to get cross-references right)' $$log && [ $$latex_count -gt 0 ] ; do \
	     echo "Rerunning pdflatex...." ; \
	     pdflatex $< > /dev/null 2>&1 ; \
	     latex_count=`expr $$latex_count - 1` ;\
	   done \
	)

usermanual.bbl: $(TEXFILES) references.bib
	@latex usermanual > /dev/null
	@bibtex usermanual > /dev/null

usermanual.ps.gz: usermanual.dvi
	@echo "generating $@ ..." ;
	@dvips $< -o  > /dev/null 2>&1 ;
	@gzip -f `basename $< .dvi`.ps

usermanual.dvi: $(TEXFILES) usermanual.bbl
	@( echo "generating $@ ..." ; \
	   log="usermanual.log" ; \
	   latex usermanual > /dev/null 2>&1 ; \
	   latex_count=5 ; \
	   while egrep -s 'Rerun (LaTeX|to get cross-references right)' $$log && [ $$latex_count -gt 0 ] ; do \
	     echo "Rerunning latex...." ; \
	     latex usermanual > /dev/null 2>&1 ; \
	     latex_count=`expr $$latex_count - 1` ;\
	   done \
	)

$(PDFFIG): %.pdf: %.eps
	@echo "generating $@ ..." ;
	@epstopdf $< ;

mrproper: clean
	@rm -f usermanual.pdf usermanual.ps* *.aux *.bbl *.blg *.dvi *.log
	@rm -f *.out *.toc *.html *.pl images.ps *.gif *.png *.old WARNINGS commonstuff.tex images.tex
	@rm -rf auto
	@rm -f class*.tex ??-fields-*.tex fields-*.tex desc-*.tex um_class_ref.tex *.brf

clean: texclean
	@rm -f usermanual.html usermanual.pdf progmanual.ps.gz

distclean: texclean
	@rm -f WARNINGS commonstuff.tex *.pl images.tex ??-fields-*.tex fields-*.tex desc-*.tex

texclean:
	@rm -f *.aux *.bbl *.blg *.dvi *.log *.out *.toc

