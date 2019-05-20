#!/bin/bash
convert ../output/nightlight_raster_township_2000_map_uncropped.png -gravity North -chop 0x18 ../output/temp1.png
convert ../output/temp1.png -gravity South -chop 0x18 ../output/temp2.png
convert ../output/temp2.png -gravity West -chop 45x0 ../output/nightlight_raster_township_2000_map.png
rm ../output/temp1.png ../output/temp2.png
convert -density 600 ../output/nightlight_raster_township_2000_map.png ../output/nightlight_raster_township_2000_map_hidef.png

convert ../output/radar_map_townships_2000_30_uncropped.png -gravity North -chop 0x18 ../output/temp1.png
convert ../output/temp1.png -gravity South -chop 0x18 ../output/temp2.png
convert ../output/temp2.png -gravity West -chop 50x0 ../output/radar_map_townships_2000_30.png
rm ../output/temp1.png ../output/temp2.png
convert -density 600 ../output/radar_map_townships_2000_30.png ../output/radar_map_townships_2000_30_hidef.png

convert ../output/assignment_map_townships_2000_metros_NTL30_uncropped.png -gravity North -chop 0x18 ../output/temp1.png
convert ../output/temp1.png -gravity South -chop 0x18 ../output/temp2.png
convert ../output/temp2.png -gravity West -chop 50x0 ../output/assignment_map_townships_2000_metros_NTL30.png
rm ../output/temp1.png ../output/temp2.png
convert -density 600 ../output/assignment_map_townships_2000_metros_NTL30.png ../output/assignment_map_townships_2000_metros_NTL30_hidef.png
