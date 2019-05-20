#!/bin/sh

##Combine msa_compare_zipf_India_SDT_2001.tex and msa_compare_zipf_India_SDT_2011.tex
grep -v '{tabular}' ../output/msa_compare_zipf_India_SDT_2001.tex | sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | awk '{$1=$1;print}' >  ../output/temp1.tex
grep -v '{tabular}' ../output/msa_compare_zipf_India_SDT_2011.tex | sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | sed 's/^[^\&]*\&//g'| awk '{$1=$1;print}' > ../output/temp2.tex
paste -d "\&" ../output/temp1.tex ../output/temp2.tex | awk '{print $0" \\\\"}' | sed  '1 s/$/ \\midrule/' > ../output/temp3.tex
echo "\bottomrule \end{tabular}" >> ../output/temp3.tex
sed '1i\\\begin{tabular}{lcccccccc} \\toprule \n&\\multicolumn{4}{c}{2001}\&\\multicolumn{4}{c}{2011} \\\\ \\cmidrule(lr){2-5} \\cmidrule(lr){6-9} \n' ../output/temp3.tex \
| sed '/^\s*$/d' \
> ../output/msa_compare_zipf_India_SDT_2001_2011.tex

rm ../output/temp1.tex ../output/temp2.tex ../output/temp3.tex
