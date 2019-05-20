#!/bin/sh

cd ../output/

##Combine pairwise_edu.tex pairwise_edu_2000_4group.tex and pairwise_edu_4group_0.tex
cat ../output/pairwise_edu.tex | sed 's/\\multicolumn{4}{c}{Pairwise comparisons} \\\\ \\hline/\\multicolumn{4}{c}{Brazil (2010)} \\\\/' | sed '3d' | sed -n '2,$p' | sed -e '$d'| sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | awk '{$1=$1;print}'> ../output/temp1.tex
cat ../input/pairwise_edu_2000_4group.tex | sed 's/\\multicolumn{4}{c}{Pairwise comparisons} \\\\ \\hline/\\multicolumn{4}{c}{China (2000)} \\\\/' | sed '3d' | sed -n '2,$p' | sed -e '$d'| sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | awk '{$1=$1;print}'> ../output/temp2.tex
cat ../input/pairwise_edu_4group_0.tex | sed 's/\\multicolumn{4}{c}{Pairwise comparisons} \\\\ \\hline/\\multicolumn{4}{c}{India (2001)} \\\\/' | sed '3d' | sed -n '2,$p' | sed -e '$d'| sed -e 's/[ ^t]*$//' -e "s/\midrule//" -e 's,\\\\,,' -e  's, \\,,' | tr -d "\r" | awk '{$1=$1;print}'> ../output/temp3.tex
paste -d "\&" temp1.tex temp2.tex temp3.tex | awk '{print $0" \\\\"}' | sed  '1 s/$/ \\midrule/' > ../output/temp4.tex
echo "\\\\ \multicolumn{2}{l}{Weighted} & &$\surd$ &&&&$\surd$ &&&&$\surd$ \\\\" >> ../output/temp4.tex
echo "\bottomrule \end{tabular}" >> ../output/temp4.tex
sed '1s/^/\\begin{tabular}{cccccccccccccccc}\n\\toprule/' ../output/temp4.tex \
| sed 's/hline//g' \
| sed 's/\\midrule/\\cmidrule(lr){1-4}\\cmidrule(lr){5-8}\\cmidrule(lr){9-12}/' \
| sed 's/comparisons/Pairings/g' \
| sed 's/Outcome \& Weighted Outcome/\\multicolumn{2}{c}{Success rates}/g' \
| sed 's/Bins\(.*\) \\\\/Bins \1 \\\\ \\cmidrule(lr){1-4}\\cmidrule(lr){5-8}\\cmidrule(lr){9-12}/' \
> ../output/edu_pairwise.tex
rm ../output/temp1.tex ../output/temp2.tex ../output/temp3.tex ../output/temp4.tex
