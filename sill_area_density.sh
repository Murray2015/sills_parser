#!/bin/bash -x

gmtset MAP_FRAME_TYPE plain
file="oga_output_trans_decomp.csv"
prj="-JM3i"
awk -F"," '{if(NR>1)print $4,$5}' ${file} > temp_sills_whitespace.txt
# Convert sills into latlon
cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_geog.txt

rgnoga=`gmtinfo Rockall-UK_coords_geog.txt -I0.2`

# Output the count in every 10 km block.
blockmean $rgnoga sills_geog.txt -I10000+e -C -Sn -fg > oga_counts_10000.txt

# Grid the counts
nearneighbor $rgnoga oga_counts_10000.txt -I1000+e -N6 -S30000+e -fg -Goga_counts_10000.nc

# Divide values by 10 to get sill area density
grdmath oga_counts_10000.nc 10 DIV = oga_counts_1000.nc


# Make map
outfile=oga_area_density.ps
makecpt -Chot -T0/0.8/0.1 -Z -D > sill_area_d.cpt
grdimage $prj $rgnoga oga_counts_1000.nc -Bx2 -By2 -BSWne -Csill_area_d.cpt -K > $outfile
pscoast -Gblack -Di $prj $rgnoga -K -O >> $outfile
psxy $prj $rgnoga -W0.5 Rockall-UK_coords_geog.txt -gd5k -K -O >> $outfile
psscale -D3.25i/1.2i/2i/0.25i -B0.2+l"Sill area density (km @+-1@+)" -Csill_area_d.cpt -O >> $outfile

psconvert -P -A0.5 $outfile
eog *jpg
