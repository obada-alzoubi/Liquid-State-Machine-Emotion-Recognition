L2HUTILS=../../../develop/post_l2h
NAVBUTTONS=$(L2HUTILS)/contents.gif $(L2HUTILS)/next.gif $(L2HUTILS)/prev.gif \
	   $(L2HUTILS)/contents.png $(L2HUTILS)/next.png $(L2HUTILS)/prev.png

POSTL2H = $(L2HUTILS)/post_l2h

default: dvi pdf html

pdf: usermanual.pdf

dvi: usermanual.dvi

html: usermanual.html

usermanual.html: *.tex usermanual.bbl latex2html-init
	@latex2html -init_file latex2html-init -image_type gif -local_icons -white -math -html_version 4.0 usermanual > /dev/null
	@echo post processing latex2html output
	@(for f in *.html; do \
            $(POSTL2H) $$f > /tmp/f.$$$$; \
            mv /tmp/f.$$$$ $$f; \
          done; )
	@cp $(NAVBUTTONS) .

usermanual.pdf: usermanual.tex  usermanual.bbl um-*.tex
	@(if pdflatex usermanual | grep -e ".*Rerun to get cross-references right"; then \
	    echo running pdflatex again ... ;\
	    pdflatex usermanual > /dev/null; \
          fi)

usermanual.bbl: *.tex references.bib
	@latex usermanual > /dev/null
	@bibtex usermanual > /dev/null

usermanual.dvi: *.tex usermanual.bbl
	@latex usermanual
	@bibtex usermanual
	@(if latex usermanual | grep -e ".*Rerun to get cross-references right"; then \
	    echo running flatex again ... ;\
	    latex usermanual > /dev/null; \
          fi)

mrproper: clean
	@rm -f usermanual.pdf usermanual.ps* *.aux *.bbl *.blg *.dvi *.log
	@rm -f *.brf *.out *.toc *.html *.pl *.gif *.png *.old WARNINGS commonstuff.tex images.tex
	@rm -rf auto

clean: texclean
	rm -f usermanual.html usermanual.pdf progmanual.ps.gz

distclean: texclean
	@rm -f WARNINGS commonstuff.tex *.pl images.tex

texclean:
	rm -f *.aux *.bbl *.blg *.dvi *.log *.out *.toc

