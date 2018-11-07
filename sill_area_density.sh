#!/bin/bash

gmtset MAP_FRAME_TYPE plain
file="oga_output_trans_decomp.csv"
linefile="Rockall-UK_coords_geog.txt"
misc="-Bx2 -By2 -BSWne"
ogr2ogr -F "GMT" faults_misc.gmt extra_data_rockall/faults_misc.shp
ogr2ogr -F "GMT" folds_tuitt.gmt extra_data_rockall/folds_tuitt.shp
ogr2ogr -F "GMT" volc_tuitt.gmt extra_data_rockall/volc_tuitt.shp



sill_area_density()
{
prj="-JM3i"
awk -F"," '{if(NR>1)print $4,$5}' ${file} > temp_sills_whitespace.txt
# Convert sills into latlon
cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_geog.txt
rgnoga=`gmtinfo $linefile -I0.2`
# Output the count in every 10 km block.
blockmean $rgnoga sills_geog.txt -I10000+e -C -Sn -fg > oga_counts_10000.txt
# Grid the counts
nearneighbor $rgnoga oga_counts_10000.txt -I1000+e -N6 -S30000+e -fg -Goga_counts_10000.nc
# Divide values by 10 to get sill area density
grdmath oga_counts_10000.nc 10 DIV = oga_counts_1000.nc
# Make map
outfile=oga_area_density.ps
makecpt -Chot -T0/0.8/0.1 -Z -D > sill_area_d.cpt
grdimage $prj $rgnoga oga_counts_1000.nc $misc -Csill_area_d.cpt -K > $outfile
pscoast -Gblack -Di $prj $rgnoga -K -O >> $outfile
psxy $prj $rgnoga -W0.5 $linefile -gd5k -K -O >> $outfile
psscale -D3.25i/1.2i/2i/0.25i -B0.2+l"Sill area density (km @+-1@+)" -Csill_area_d.cpt -O >> $outfile
psconvert -P -A0.5 $outfile
eog *jpg
}
# sill_area_density


multi_map()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
outfile="intro_maps.ps"
prj="-JM2.5i"
rgn=`gmtinfo -I0.1 $linefile`
# Bathymetry map
makecpt -T0/4000/0.1 -I -Cabyss -Z -D > bathy.cpt
grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4i -K > $outfile
grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/1i/-2i/0.25i -Cbathy.cpt -B1000 -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k $misc -K -O >> $outfile

# Gravity map
makecpt -T0/100/1 -M -Cmagma -Z -D > grav.cpt
grdconvert ${datadir}bouguer20.tif oga_bouguer20_utm.nc
grdproject $rgn -Ju29/1:1 oga_bouguer20_utm.nc -Goga_bouguer20.nc -I -C -F
grdimage oga_bouguer20.nc -Cgrav.cpt $prj $rgn -X4i -K -O >> $outfile
grdcontour oga_bouguer20.nc -C20 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/1i/2i/0.25i -Cgrav.cpt -B25 -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k $misc -K -O >> $outfile

# Magnetic map
makecpt -T-400/400/10 -I -M -Cpolar -Z -D > mag.cpt
grdconvert ${datadir}rtpmaganomaly.tif oga_rtpmaganomaly_utm.nc
grdproject $rgn -Ju29/1:1 oga_rtpmaganomaly_utm.nc -Goga_rtpmaganomaly.nc -I -C -F
grdimage oga_rtpmaganomaly.nc -Cmag.cpt $prj $rgn -X-4i -Y-2.5i -K -O >> $outfile
grdcontour oga_rtpmaganomaly.nc -C100 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/1i/2i/0.25i -Cmag.cpt -B100 -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k $misc -K -O >> $outfile

# Legend
pslegend -Dx4.2i/0.6i+w3i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.25+r+f 0.2i red 0.5,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 0.5,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
EOF

convert -trim -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile intro_maps.jpg
}
# multi_map

sill_stat_hist()
{
# Histogram of sill lengths, transgressive heights and emplacement depth
awk -F"," '{if(NR>1)print $2/1000, $3, $7}' ${file} > temp_sills_whitespace.txt
outfile=sill_stat_hist.ps
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/60/0/120 -W1 -Bx10+l"Diameter (km)" -By50+l"Frequency" -BSWne -Gblack -i0 -K > $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -W0.1 -Bx1+l"Transgressive height (km)" -BsNwe -Gblack -i1 -X2.5i -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -W0.1 -Bx1+l"Emplacement depth (km)" -BSwne -Gblack -i2 -X2.5i -O >> $outfile
psconvert $outfile -A0.5 -P
}
# sill_stat_hist

# Derivative maps of gravity and magnetic data, with extra lines of major faults, with sill counts overlain.



# Number of sills In each lithology, eg vaila (automate - get horizons and find distance between.)


eog *jpg
exit
