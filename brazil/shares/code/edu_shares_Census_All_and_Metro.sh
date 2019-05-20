#!/bin/sh

cd ../output/

##Combine msa_compare_zipf_China_municipios_2000.tex and msa_compare_zipf_China_municipios_2010.tex
cat edu_shares_Census_fullpop.tex | sed -n '4,$p' | sed -e '$d'| sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | awk '{$1=$1;print}' | sed '1i\Brazil&All' > temp1.tex
cat edu_shares_Census.tex | sed -n '4,$p' | sed -e '$d'| sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | sed 's/^[^\&]*\&//g'| awk '{$1=$1;print}' | sed '1i\Metro' > temp2.tex
paste -d "\&" temp1.tex temp2.tex | awk '{print $0" \\\\"}' | sed  '1 s/$/ \\midrule/' | sed '1i\\\begin{tabular}{lcc} \\toprule \n' | sed '/^\s*$/d' > edu_shares_Census_All_and_Metro.tex
echo "\bottomrule \end{tabular}" >> edu_shares_Census_All_and_Metro.tex

rm temp1.tex temp2.tex
