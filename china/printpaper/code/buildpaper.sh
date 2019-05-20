#!bin/bash

module load texlive
pdflatex paper_china.tex
pdflatex paper_china.tex
rm paper_china.log paper_china.aux paper_china.out
mv paper_china.pdf ../output/
module unload texlive
