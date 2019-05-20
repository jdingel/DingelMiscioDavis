#!bin/bash

module load texlive
pdflatex paper_brazil.tex
pdflatex paper_brazil.tex
rm paper_brazil.log paper_brazil.aux paper_brazil.out
mv paper_brazil.pdf ../output/
module unload texlive
