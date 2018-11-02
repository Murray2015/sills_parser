#!/bin/bash 

file="oga_output_trans_decomp.csv"
prj="-JX3i"
awk -F"," '{if(NR>1)print $4,$5}' ${file} > file_whitespace.txt
rgn=`gmtinfo file_whitespace.txt -I10000`

# Convert survey lines to utm 
mapproject `gmtinfo Rockall-UK_coords_geog.txt -I1` -C -F -Ju+29/1:1 Rockall-UK_coords_geog.txt > Rockall-UK_coords_utm29.txt

rgnoga=`gmtinfo Rockall-UK_coords_utm29.txt -I1000`

# Output the count in every 10 km block. 
blockmean $rgnoga file_whitespace.txt -I10000 -C -Sn > oga_counts_10000.txt

# Grid the counts 
nearneighbor $rgnoga oga_counts_10000.txt -I1000 -N6 -S30000 -Goga_counts_10000.nc

# Divide values by 10 to get sill area density
grdmath oga_counts_10000.nc 10 DIV = oga_counts_1000.nc


# Make map
grdimage $prj $rgnoga oga_counts_1000.nc -Bx200000 -By200000 -BSWne -Chot -K > oga_area_density.ps
psxy $prj $rgnoga -W0.5 Rockall-UK_coords_utm29.txt -gd10000 -K -O >> oga_area_density.ps

psscale -D3.25i/1.5i/2i/0.25i -B0.2+l"Sill area density (km @+-1@+)" -Chot -O >> oga_area_density.ps

okular oga_area_density.ps