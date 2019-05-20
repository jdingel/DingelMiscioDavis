#!bin/bash

module load texlive
pdflatex paper_usa.tex
pdflatex paper_usa.tex
rm paper_usa.log paper_usa.aux paper_usa.out
mv paper_usa.pdf ../output/
module unload texlive
