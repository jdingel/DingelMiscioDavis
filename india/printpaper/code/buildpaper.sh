#!bin/bash

module load texlive
pdflatex paper_india.tex
pdflatex paper_india.tex
rm paper_india.log paper_india.aux paper_india.out
mv paper_india.pdf ../output/
module unload texlive
