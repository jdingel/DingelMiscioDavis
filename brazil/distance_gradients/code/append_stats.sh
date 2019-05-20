# append p-values and N_clusters from Chow test
sed 's/\\midrule/Microregion \$p\$-value \nMicroregion Clusters \nArranjo \$p\$-value \nArranjo Clusters\n\\midrule/' ../output/distance_gradient_college_nostats.tex > ../output/temp.tex
for metro in arranjos microregions
do
  metro_title=${metro^}
  x=$(grep -n "${metro_title%?} \$\p\$-value" ../output/temp.tex | cut -d : -f 1)
  y=$(grep -n "${metro_title%?} Clusters" ../output/temp.tex | cut -d : -f 1)
  for bright in {10..50..10}
  do
    p_val=$(head -1 ../output/college_distance_gradient_ntl${bright}_${metro}_chow.txt)
    clust=$(tail -1 ../output/college_distance_gradient_ntl${bright}_${metro}_chow.txt)
    sed -i "${x}s/$/ \& ${p_val}/" ../output/temp.tex
    sed -i "${y}s/$/ \& ${clust}/" ../output/temp.tex
  done
  sed -i "${x}s/$/ \\\\\\\\/" ../output/temp.tex
  sed -i "${y}s/$/ \\\\\\\\/" ../output/temp.tex
done
cat ../output/temp.tex > ../output/distance_gradient_college.tex
rm ../output/temp.tex
