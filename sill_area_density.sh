#!/bin/bash

gmtset MAP_FRAME_TYPE plain
file="oga_output_trans_decomp.csv"
linefile="Rockall-UK_coords_geog.txt"
misc="-Bx2 -By2 -BSWne"
# ogr2ogr -F "GMT" faults_misc.gmt extra_data_rockall/faults_misc.shp
# ogr2ogr -F "GMT" folds_tuitt.gmt extra_data_rockall/folds_tuitt.shp
# ogr2ogr -F "GMT" volc_tuitt.gmt extra_data_rockall/volc_tuitt.shp
gmtset FONT_LABEL 12p,Helvetica,black
gmtset FONT_ANNOT_PRIMARY 12p,Helvetica,black

cat << EOF > tmp_plume_centres.txt
-11.25 64.4 WM89
-16.8 68.8 LM94
-18 59 JW03
-16 59 JM06g
-16 60 JM06v
-14 62 Nea09
-7 62 Faroe
EOF

ogr2ogr -F "GMT" basalt_1.gmt basalt_1.shp
mapproject basalt_1.gmt -Ju+28/1:1 -I -C -F > basalt.txt
ogr2ogr -F "GMT" magee_2014_survey.gmt magee_2014_survey.shp


rockall_basemap()
{
  outfile="basemap_sills.ps"
  prj="-JM2.5i"
  rgn=-R-14/-5/56/60.3
  rgn2=-R-40/20/40/70
  # Make cpt for sill colour
  makecpt -T-10000/12000/100 -Z -D -Cetopo1 > etopo_rock.cpt
  makecpt -T-10/10/0.1 -Z -D -Cetopo1 > etopo_rock2.cpt
  pscoast $prj $rgn2 -Bx10 -By10 -BSWne -Dl -Gblack -Swhite -P -K > $outfile
  psxy tmp_plume_centres.txt $prj $rgn2 -Ss0.2 -Gred -Wred -K -O >> $outfile
  sed -n 1p tmp_plume_centres.txt | pstext $prj $rgn2 -D0.25i/0.1iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 2p tmp_plume_centres.txt | pstext $prj $rgn2 -D-0.2i/-0.1iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 3p tmp_plume_centres.txt | pstext $prj $rgn2 -D-0.2i/0.1iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 4p tmp_plume_centres.txt | pstext $prj $rgn2 -D-0.2i/-0.1iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 5p tmp_plume_centres.txt | pstext $prj $rgn2 -D-0.2i/0.15iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 6p tmp_plume_centres.txt | pstext $prj $rgn2 -D0.2i/-0.09iv -F+f8p,Helvetica -K -O >> $outfile
  sed -n 7p tmp_plume_centres.txt | pstext $prj $rgn2 -D0.2i/0.1iv -F+f8p,Helvetica -K -O >> $outfile
  echo "-14 60.3
  -14 56
  -5 56
  -5 60.3
  -14 60.3" | psxy $prj $rgn2 -L -W0.5,red -K -O >> $outfile
  echo "a" | pstext $prj $rgn2 -F+cBL -C25% -W1.5 -D0.2 -Gwhite  -K -O >> $outfile
  psbasemap $prj $rgn2 -B0 -K -O >> $outfile
  # psbasemap $prj $rgn -DjBL+w0.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c -K -O >> $outfile
  # read x0 y0 w h < tmp
  # gmt pscoast -Rg -JG0/50N/$w -Da -Gblack -A5000 -Bg -Wfaint -O -K -X$x0 -Y$y0 >> $outfile
  # echo "-14 56
  # -14 60.3
  # -5 60.3
  # -5 56
  # -14 56" | gmt psxy -Wred -Gred -R -J -O -K >> $outfile
  grdimage ~/Documents/global_data/ETOPO1_Ice_g_gmt4.grd -Cetopo1 $prj $rgn -X3i -Bx2 -By2 -BSWne -K -O >> $outfile
  grdcontour ~/Documents/global_data/ETOPO1_Ice_g_gmt4.grd -C500 $prj $rgn -Wgray10 -K -O >> $outfile
  psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cetopo_rock2.cpt -B4+l"Topography (km)" -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -W0.2,darkred -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  echo "-12 58 Rockall Basin" | pstext -J -R -F+a75 -K -O >> $outfile
  echo "-10 59 Rosemary Bank" | pstext -J -R -F+f8p,Helvetica,black -K -O >> $outfile
  echo "-11 57.3 Anton Dohrn" | pstext -J -R -K -F+f8p,Helvetica,black -O >> $outfile
  echo "-10.5 56.3 Hebrides Terrace" | pstext -J -R -K -F+f8p,Helvetica,black -O >> $outfile
  psxy well_location.txt -J -R -S+0.12i -Gblack -K -O >> $outfile
  psxy well_location.txt -J -R -Sc0.06i -Gblack -K -O >> $outfile
  psxy magee_2014_survey.gmt -W0.4,pink -L -J -R -K -O >> $outfile
  # for i in `seq 1 17`
  # do
  # awk -v i=$i '{if(NR==i)print $0}' well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.2i/0i -K -O >> $outfile
  # done
  sed -n 5p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D-0.2i/0i -K -O >> $outfile
  sed -n 6p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.25i/-0.02i -K -O >> $outfile
  sed -n 7p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.2i/0.02i -K -O >> $outfile
  sed -n 8p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.25i/0i -K -O >> $outfile
  sed -n 11p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.25i/-0.01i -K -O >> $outfile
  sed -n 12p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.2i/-0.04i -K -O >> $outfile
  sed -n 13p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.25i/0i -K -O >> $outfile
  sed -n 14p well_location.txt | pstext -J -R -F+f6,Helvetica,black -D0.25i/0i -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite  -K -O >> $outfile
  psbasemap $prj $rgn -B0 -O >> $outfile
  convert -trim -bordercolor white -border 30x30 -quality 100 -density 600 $outfile basemap_sills.png
  eog basemap_sills.png
}
# rockall_basemap


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
grdmath oga_counts_10000.nc 100 DIV = oga_counts_1000.nc
# Make map
outfile=oga_area_density.ps
makecpt -Chot -T0/0.1/0.01 -Z -D > sill_area_d.cpt
grdimage $prj $rgnoga oga_counts_1000.nc $misc -Csill_area_d.cpt -K > $outfile
pscoast -Gblack -Di $prj $rgnoga -K -O >> $outfile
psxy $prj $rgnoga -W0.5 $linefile -gd5k -K -O >> $outfile
psscale -D3.25i/1.2i/2i/0.25i -B0.02+l"Sill area density (km @+-2@+)" -Csill_area_d.cpt -O >> $outfile
psconvert -P -A0.5 $outfile
eog oga_area_density.jpg
}
# sill_area_density


multi_map()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
# datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
outfile="intro_maps.ps"
prj="-JM2.5i"
rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Bathymetry map
makecpt -T0/2500/0.1 -I -Crainbow -Z -D > bathy.cpt
makecpt -T0/2.5/0.01 -I -Crainbow -Z -D > bathy2.cpt
grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4i -K > $outfile
grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.4i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile
psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

# Gravity map
makecpt -T0/100/1 -M -Cmagma -Z -D > grav.cpt
grdconvert ${datadir}bouguer20.tif oga_bouguer20_utm.nc
grdproject $rgn -Ju29/1:1 oga_bouguer20_utm.nc -Goga_bouguer20.nc -I -C -F
grdimage oga_bouguer20.nc -Cgrav.cpt $prj $rgn -X3.6i -K -O >> $outfile
grdcontour oga_bouguer20.nc -C20 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.6i/0.4i+w1.5i/0.15i+e -Cgrav.cpt -B25+l"Bouguer gravity (mGal)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -Bx2 -By2 -BS -St0.2 -Gred -Wred -K -O >> $outfile
psbasemap $prj $rgn -B0 -O -K >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

# Magnetic map
makecpt -T-400/400/10 -M -Cpolar -Z -D > mag.cpt
makecpt -T-4/4/0.1 -M -Cpolar -Z -D > mag2.cpt
grdconvert ${datadir}rtpmaganomaly.tif oga_rtpmaganomaly_utm.nc
grdproject $rgn -Ju29/1:1 oga_rtpmaganomaly_utm.nc -Goga_rtpmaganomaly.nc -I -C -F
grdimage oga_rtpmaganomaly.nc -Cmag.cpt $prj $rgn -X-3.6i -Y-2.4i -K -O >> $outfile
grdcontour oga_rtpmaganomaly.nc -C100 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.4i+w1.5i/0.15i+e -Cmag2.cpt -Bx2+l"Magnetic anomaly (nT)" -By+l"x10@+2@+" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BSW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile
psxy $prj $rgn sills_geog.txt  -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite  -K -O >> $outfile


# Legend
pslegend -Dx3.8i/0.5i+w2i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.5+r+f 0.2i red 1,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 1,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
S 0.1i c 0.05i white 0.5,black 0.5i Sill
EOF

convert -trim +repage -flatten -backgroundcolor white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile intro_maps.jpg
eog intro_maps.jpg
}
# multi_map


sill_stat_hist()
{
# Histogram of sill lengths, transgressive heights and emplacement depth
awk -F"," '{if(NR>1)print $2/1000, $3, $7}' ${file} > temp_sills_whitespace.txt
# Select sills within the limits of the Magee survey
awk -F"," '{if(NR>1)print $4, $5, $2/1000, $3, $7}'  oga_output_trans_decomp.csv | mapproject -Ju+29/1:1 -I -C -F | gmtselect -Fmagee_2014_survey.gmt | awk '{print $3, $4, $5}' > temp_sills_whitespace_oga-magee.txt
outfile=sill_stat_hist.ps
# Calculate summary stats
gmtmath temp_sills_whitespace.txt -C0,1,2 LOWER -S  = stats_lower.txt
gmtmath temp_sills_whitespace.txt -C0,1,2 25 PQUANT -S  = stats_lq.txt
gmtmath temp_sills_whitespace.txt -C0,1,2 -S  MEAN = stats_mean.txt
gmtmath temp_sills_whitespace.txt -C0,1,2 -S  MEDIAN = stats_median.txt
gmtmath temp_sills_whitespace.txt -C0,1,2 75 PQUANT -S  = stats_uq.txt
gmtmath temp_sills_whitespace.txt -C0,1,2 UPPER -S  = stats_upper.txt
plot_stat(){
  file=$1
  col=$2
  colour=$3
  echo $file $col $colour
  awk -v col=$col '{print $col, 0"\n" $col, 150"\n"}' < $file | psxy -J -R -K -O -W2,${colour} >> $outfile
}
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/40/0/150 -W1 -Bx10+l"Diameter (km)" -By50+l"Frequency" -BSWne -Gblack -i0 -K > $outfile
plot_stat stats_lower.txt 1 red
plot_stat stats_lq.txt 1 orange
plot_stat stats_median.txt 1 yellow
plot_stat stats_mean.txt 1 green
plot_stat stats_uq.txt 1 blue
plot_stat stats_upper.txt 1 violet
echo "a" | pstext -J -R -F+cTR -C35% -W1.5 -D-0.3 -Gwhite -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/40/0/150 -W1 -Bx10+l"Diameter (km)" -By50+l"Frequency" -BSWne -Gblack -i0 -O -K >> $outfile
pshistogram jackson_sills.txt -J -R0/40/0/50 -W2 -L0.5,red -i0 -S -Z1 -K -O >> $outfile
pshistogram magee_sills.txt -J -R0/40/0/50 -W2 -L0.5,green -i0 -S -Z1 -K -O >> $outfile
pshistogram reynolds_sills.txt -J -R0/40/0/50 -W2 -L0.5,blue -i0 -S -Z1 -K -O >> $outfile
pshistogram temp_sills_whitespace_oga-magee.txt  -J -R0/40/0/50 -W2 -L0.5,green,- -i0 -S -Z1 -K -O >> $outfile
psbasemap -R -J -B0 -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i  -R0/5/0/150 -W0.1 -Bx1+l"Transgressive height (km)" -BsNwe -Gblack -i2 -X2.5i -K -O >> $outfile
plot_stat stats_lower.txt 3 red
plot_stat stats_lq.txt 3 orange
plot_stat stats_median.txt 3 yellow
plot_stat stats_mean.txt 3 green
plot_stat stats_uq.txt 3 blue
plot_stat stats_upper.txt 3 violet
echo "b" | pstext -R -J -F+cTR -C35% -W1.5 -D-0.3 -Gwhite -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i  -R0/5/0/150 -W0.1 -Bx1+l"Transgressive height (km)" -BsNwe -Gblack -i2 -K -O >> $outfile
pshistogram magee_sills.txt -J -R0/5/0/70 -W0.2 -L0.5,green -i2 -S -Z1 -K -O >> $outfile
pshistogram temp_sills_whitespace_oga-magee.txt  -J -R0/5/0/70 -W0.2 -L0.5,green,- -i2 -S -Z1 -K -O >> $outfile
psbasemap -R -J -B0 -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/10/0/150 -W0.1 -Bx2+l"Emplacement depth (km)" -BSwne -Gblack -i1 -X2.5i -K -O >> $outfile
plot_stat stats_lower.txt 2 red
plot_stat stats_lq.txt 2 orange
plot_stat stats_median.txt 2 yellow
plot_stat stats_mean.txt 2 green
plot_stat stats_uq.txt 2 blue
plot_stat stats_upper.txt 2 violet
echo "c" | pstext -J -R -F+cTR -C35% -W1.5 -D-0.3 -Gwhite -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/10/0/150 -W0.1 -Bx2+l"Emplacement depth (km)" -BSwne -Gblack -i1 -K -O >> $outfile
pshistogram jackson_sills.txt -J -R0/10/0/50 -W0.2 -L0.5,red -i1 -S -Z1 -K -O >> $outfile
pshistogram magee_sills.txt -J -R0/10/0/50 -W0.2 -L0.5,green -i1 -S -Z1 -K -O >> $outfile
pshistogram reynolds_sills.txt -J -R0/10/0/50 -W0.2 -L0.5,blue -i1 -S -Z1 -K -O >> $outfile
pshistogram temp_sills_whitespace_oga-magee.txt  -J -R0/10/0/50 -W0.2 -L0.5,green,- -i1 -S -Z1 -K -O >> $outfile
psbasemap -R -J -B0 -O >> $outfile
psconvert $outfile -A0.5 -P
eog sill_stat_hist.jpg
}
sill_stat_hist


vert_der()
{
  # Vertical derivative maps of gravity and magnetic data, with extra lines of major faults, with sill counts overlain.
  outfile="vert_deriv_maps.ps"
  prj="-JM3i"
  rgn=`gmtinfo -I0.01 $linefile`
  ginc=0.02
  # Make make same grid increment for XOR masking
  grdsample oga_bouguer20.nc $rgn -I${ginc} -Goga_bouguer20_resamp.nc
  grdsample oga_rtpmaganomaly.nc $rgn -I${ginc} -Goga_rtpmaganomaly_resamp.nc
  # Make continuous grids
  grd2xyz oga_bouguer20.nc | surface $rgn -I${ginc} -Goga_bouguer20_surf.nc
  grd2xyz oga_rtpmaganomaly.nc | surface $rgn -I${ginc} -Goga_rtpmaganomaly_surf.nc
  # Take derivatives
  grdfft oga_bouguer20_surf.nc -D -Goga_bouguer20_dz.nc -fg
  grdfft oga_rtpmaganomaly_surf.nc -D -Goga_rtpmaganomaly_dz.nc -fg
  # Cut grids with grid masks
  grdmath oga_bouguer20_dz.nc oga_bouguer20_resamp.nc XOR = oga_bouguer20_dz_cut.nc
  grdmath oga_rtpmaganomaly_dz.nc oga_rtpmaganomaly_resamp.nc XOR = oga_rtpmaganomaly_dz_cut.nc


  # Gravity map
  makecpt -T-0.005/0.005/0.0001 -M -Cblue,white,orange -Z -D > gravdz.cpt
  grdimage oga_bouguer20_dz_cut.nc -Cgravdz.cpt $prj $rgn -Y1.5i -K > $outfile
  grdcontour oga_bouguer20_dz_cut.nc -C50 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D0.5i/-0.5i+w2i/0.15i+h+e -Cgravdz.cpt -B0.004+l"Gravity d/dz" -By+l"mGal m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k $misc -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gred -Wblack -K -O >> $outfile
  echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Magnetic map
  makecpt -T-0.05/0.05/0.001 -M -Cgreen,white,orange -Z -D > magdz.cpt
  grdimage oga_rtpmaganomaly_dz_cut.nc -Cmagdz.cpt $prj $rgn -X3.25i -K -O >> $outfile
  grdcontour oga_rtpmaganomaly_dz_cut.nc -C2000 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D0.5i/-0.5i+w2i/0.15i+h+e  -Cmagdz.cpt -B0.04+l"Magnetic d/dz"  -By+l"nT m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BSwEn -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gred -Wblack -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -O >> $outfile
  psconvert -A0.5 -P $outfile
  eog vert_deriv_maps.jpg
}
# vert_der


horz_dir()
{
  # Derivative maps of gravity and magnetic data, with extra lines of major faults, with sill counts overlain.
  outfile="horz_deriv_maps.ps"
  prj="-JM3i"
  rgn=`gmtinfo -I0.01 $linefile`
  ginc=0.02
  # Make make same grid increment for XOR masking
  grdsample oga_bouguer20.nc $rgn -I${ginc} -Goga_bouguer20_resamp.nc
  grdsample oga_rtpmaganomaly.nc $rgn -I${ginc} -Goga_rtpmaganomaly_resamp.nc
  # Make continuous grids
  grd2xyz oga_bouguer20.nc | surface $rgn -I${ginc} -Goga_bouguer20_surf.nc
  grd2xyz oga_rtpmaganomaly.nc | surface $rgn -I${ginc} -Goga_rtpmaganomaly_surf.nc
  # Take derivatives
  grdmath -M oga_bouguer20_surf.nc DDX SQR oga_bouguer20_surf.nc DDY SQR ADD SQRT = oga_bouguer20_THD.nc
  grdmath -M oga_rtpmaganomaly_surf.nc DDX SQR oga_rtpmaganomaly_surf.nc DDY SQR ADD SQRT = oga_rtpmaganomaly_THD.nc
  # Cut grids with grid masks
  grdmath oga_bouguer20_THD.nc oga_bouguer20_resamp.nc XOR = oga_bouguer20_THD_cut.nc
  grdmath oga_rtpmaganomaly_THD.nc oga_rtpmaganomaly_resamp.nc XOR = oga_rtpmaganomaly_THD_cut.nc

  # Gravity map
  makecpt -T0/0.004/0.0001 -M -Ccubhelix -Z -D > gravTHD.cpt
  grdimage oga_bouguer20_THD_cut.nc -CgravTHD.cpt $prj $rgn -Y1.5i -K > $outfile
  grdcontour oga_bouguer20_THD_cut.nc -C50 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D0.5i/-0.5i+w2i/0.15i+h+e -CgravTHD.cpt -B0.001+l"Gravity THG" -By+l"mGal m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k $misc -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gred -Wblack -K -O >> $outfile
  echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Magnetic map
  makecpt -T0/0.05/0.001 -M -Cviridis -Z -D > magTHD.cpt
  grdimage oga_rtpmaganomaly_THD_cut.nc -CmagTHD.cpt $prj $rgn -X3.25i -K -O >> $outfile
  grdcontour oga_rtpmaganomaly_THD_cut.nc -C2000 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D0.5i/-0.5i+w2i/0.15i+h+e  -CmagTHD.cpt -B0.01+l"Magnetic THG" -By+l"nT m@+-1@+"  -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W0.5,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W0.5,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BSwEn -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gred -Wblack -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -O >> $outfile
  psconvert -A0.5 -P $outfile
  eog horz_deriv_maps.jpg
}
# horz_dir


pot_der_4()
{
  # Vertical derivative maps of gravity and magnetic data, with extra lines of major faults, with sill counts overlain.
  outfile="pot_deriv_maps_4.ps"
  prj="-JM3i"
  # rgn=`gmtinfo -I0.01 $linefile`
  rgn=-R-14/-5/56/60.3
  ginc=0.02
  # Make make same grid increment for XOR masking
  # grdsample oga_bouguer20.nc $rgn -I${ginc} -Goga_bouguer20_resamp.nc
  # grdsample oga_rtpmaganomaly.nc $rgn -I${ginc} -Goga_rtpmaganomaly_resamp.nc
  # # Make continuous grids
  # grd2xyz oga_bouguer20.nc | surface $rgn -I${ginc} -Goga_bouguer20_surf.nc
  # grd2xyz oga_rtpmaganomaly.nc | surface $rgn -I${ginc} -Goga_rtpmaganomaly_surf.nc
  # # Take derivatives
  # grdfft oga_bouguer20_surf.nc -D -Goga_bouguer20_dz.nc -fg
  # grdfft oga_rtpmaganomaly_surf.nc -D -Goga_rtpmaganomaly_dz.nc -fg
  # # Cut grids with grid masks
  # grdmath oga_bouguer20_dz.nc oga_bouguer20_resamp.nc XOR = oga_bouguer20_dz_cut.nc
  # grdmath oga_rtpmaganomaly_dz.nc oga_rtpmaganomaly_resamp.nc XOR = oga_rtpmaganomaly_dz_cut.nc


  # Gravity map
  makecpt -T-0.005/0.005/0.0001 -M -Cblue,white,orange -Z -D > gravdz.cpt
  grdimage oga_bouguer20_dz_cut.nc -Cgravdz.cpt $prj $rgn -X1.5i -Y4.5i -K > $outfile
  grdcontour oga_bouguer20_dz_cut.nc -C50 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D-0.8i/0.4i+w2i/0.15i+e+m -Cgravdz.cpt -B0.004+l"Gravity d/dz" -By+l"mGal m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BW -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Magnetic map
  makecpt -T-0.05/0.05/0.001 -M -Cgreen,white,orange -Z -D > magdz.cpt
  grdimage oga_rtpmaganomaly_dz_cut.nc -Cmagdz.cpt $prj $rgn -X3i -K -O >> $outfile
  grdcontour oga_rtpmaganomaly_dz_cut.nc -C2000 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D3.2i/0.4i+w2i/0.15i+e  -Cmagdz.cpt -B0.04+l"Magnetic d/dz"  -By+l"nT m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Derivative maps of gravity and magnetic data, with extra lines of major faults, with sill counts overlain.
  # grdsample oga_bouguer20.nc $rgn -I${ginc} -Goga_bouguer20_resamp.nc
  # grdsample oga_rtpmaganomaly.nc $rgn -I${ginc} -Goga_rtpmaganomaly_resamp.nc
  # # Make continuous grids
  # grd2xyz oga_bouguer20.nc | surface $rgn -I${ginc} -Goga_bouguer20_surf.nc
  # grd2xyz oga_rtpmaganomaly.nc | surface $rgn -I${ginc} -Goga_rtpmaganomaly_surf.nc
  # # Take derivatives
  # grdmath -M oga_bouguer20_surf.nc DDX SQR oga_bouguer20_surf.nc DDY SQR ADD SQRT = oga_bouguer20_THD.nc
  # grdmath -M oga_rtpmaganomaly_surf.nc DDX SQR oga_rtpmaganomaly_surf.nc DDY SQR ADD SQRT = oga_rtpmaganomaly_THD.nc
  # # Cut grids with grid masks
  # grdmath oga_bouguer20_THD.nc oga_bouguer20_resamp.nc XOR = oga_bouguer20_THD_cut.nc
  # grdmath oga_rtpmaganomaly_THD.nc oga_rtpmaganomaly_resamp.nc XOR = oga_rtpmaganomaly_THD_cut.nc

  # Gravity map
  makecpt -T0/0.004/0.0001 -M -Ccubhelix -Z -D > gravTHD.cpt
  grdimage oga_bouguer20_THD_cut.nc -CgravTHD.cpt $prj $rgn -Y-2.72i -X-3i -K -O >> $outfile
  grdcontour oga_bouguer20_THD_cut.nc -C50 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D-0.8i/0.38i+w2i/0.15i+e+m -CgravTHD.cpt -B0.002+l"Gravity THG" -By+l"mGal m@+-1@+" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BSW -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Magnetic map
  makecpt -T0/0.05/0.001 -M -Cviridis -Z -D > magTHD.cpt
  grdimage oga_rtpmaganomaly_THD_cut.nc -CmagTHD.cpt $prj $rgn -X3i -K -O >> $outfile
  grdcontour oga_rtpmaganomaly_THD_cut.nc -C2000 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D3.2i/0.4i+w2i/0.15i+e  -CmagTHD.cpt -B0.02+l"Magnetic THG" -By+l"nT m@+-1@+"  -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BS -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
  echo "d" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB- -O >> $outfile
  psconvert -A0.75 -P -E600 pot_deriv_maps_4.ps
  eog pot_deriv_maps_4.jpg
}
# pot_der_4


multi_map_diam()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
outfile="sill_diam_maps.ps"
prj="-JM2.5i"
# rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Make sill file
awk -F"," '{if(NR>1)print $4,$5,$2/1000.0,$3,$7}' ${file} > temp_sills_whitespace.txt
# Convert sills into latlon
cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_x_y_diam_emdepth_trans.txt
# Make cpt for sill colour
makecpt -T0/20/2.5 -D -Crainbow > diam.cpt
# Bathymetry map
makecpt -T0/4000/0.1 -I -Cabyss -Z -D > bathy.cpt
makecpt -T0/4/0.01 -I -Cabyss -Z -D > bathy2.cpt
grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4i -K > $outfile
grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cdiam.cpt -Wblack -i0,1,2 -K -O >> $outfile
echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BW -K -O >> $outfile
psbasemap $prj $rgn -B0 -O -K >> $outfile

# Gravity map
makecpt -T0/100/1 -M -Cmagma -Z -D > grav.cpt
grdconvert ${datadir}bouguer20.tif oga_bouguer20_utm.nc
grdproject $rgn -Ju29/1:1 oga_bouguer20_utm.nc -Goga_bouguer20.nc -I -C -F
grdimage oga_bouguer20.nc -Cgrav.cpt $prj $rgn -X3.6i -K -O >> $outfile
grdcontour oga_bouguer20.nc -C20 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cgrav.cpt -B25+l"Bouguer gravity (mGal)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cdiam.cpt -Wblack -i0,1,2 -K -O >> $outfile
echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BS -K -O >> $outfile
psbasemap $prj $rgn -B0 -O -K >> $outfile


# Magnetic map
makecpt -T-400/400/10 -M -Cpolar -Z -D > mag.cpt
makecpt -T-4/4/0.1 -M -Cpolar -Z -D > mag2.cpt
grdconvert ${datadir}rtpmaganomaly.tif oga_rtpmaganomaly_utm.nc
grdproject $rgn -Ju29/1:1 oga_rtpmaganomaly_utm.nc -Goga_rtpmaganomaly.nc -I -C -F
grdimage oga_rtpmaganomaly.nc -Cmag.cpt $prj $rgn -X-3.6i -Y-2.5i -K -O >> $outfile
grdcontour oga_rtpmaganomaly.nc -C100 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cmag2.cpt -B2+l"Magnetic anomaly (nT)" -By+l"x10@+2@+" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cdiam.cpt -Wblack -i0,1,2 -K -O >> $outfile
echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BSW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile



# Legend
pslegend -Dx4i/0.2i+w2.2i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.5+r+f 0.2i red 1,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 1,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
G 1l
S 0.1i c 0.05i white 0.5,black 0.5i Sill (fill colour as below)
G 1l
B diam.cpt 0i 0.15i+ef -B5+l"Sill diameter (km)"
EOF

convert -trim +repage -flatten -background white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_diam_maps.jpg
eog sill_diam_maps.jpg
}
# multi_map_diam


multi_map_emd()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
outfile="sill_emd_maps.ps"
prj="-JM2.5i"
# rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Make sill file
awk -F"," '{if(NR>1)print $4,$5,$2/1000.0,$3,$7}' ${file} > temp_sills_whitespace.txt
# Convert sills into latlon
cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_x_y_diam_emdepth_trans.txt
# Make cpt for sill colour
makecpt -T0/8/1 -D -Crainbow > emd.cpt
# Bathymetry map
makecpt -T0/4000/0.1 -I -Cabyss -Z -D > bathy.cpt
makecpt -T0/4/0.01 -I -Cabyss -Z -D > bathy2.cpt
grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4i -K > $outfile
grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cemd.cpt -Wblack -i0,1,3 -K -O >> $outfile
echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Gravity map
makecpt -T0/100/1 -M -Cmagma -Z -D > grav.cpt
grdconvert ${datadir}bouguer20.tif oga_bouguer20_utm.nc
grdproject $rgn -Ju29/1:1 oga_bouguer20_utm.nc -Goga_bouguer20.nc -I -C -F
grdimage oga_bouguer20.nc -Cgrav.cpt $prj $rgn -X3.6i -K -O >> $outfile
grdcontour oga_bouguer20.nc -C20 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/0.35i+w1.5i/0.15i+e -Cgrav.cpt -B25+l"Bouguer gravity (mGal)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cemd.cpt -Wblack -i0,1,3 -K -O >> $outfile
echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BS -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Magnetic map
makecpt -T-400/400/10 -M -Cpolar -Z -D > mag.cpt
makecpt -T-4/4/0.1 -M -Cpolar -Z -D > mag2.cpt
grdconvert ${datadir}rtpmaganomaly.tif oga_rtpmaganomaly_utm.nc
grdproject $rgn -Ju29/1:1 oga_rtpmaganomaly_utm.nc -Goga_rtpmaganomaly.nc -I -C -F
grdimage oga_rtpmaganomaly.nc -Cmag.cpt $prj $rgn -X-3.6i -Y-2.5i -K -O >> $outfile
grdcontour oga_rtpmaganomaly.nc -C100 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.75i/0.35i+w1.5i/0.15i+e -Cmag2.cpt -B2+l"Magnetic anomaly (nT)" -By+l"x10@+2@+" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cemd.cpt -Wblack -i0,1,3 -K -O >> $outfile
echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BSW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile


# Legend
pslegend -Dx4i/0.2i+w2.2i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.5+r+f 0.2i red 1,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 1,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
G 1l
S 0.1i c 0.05i white 0.5,black 0.5i Sill (fill colour as below)
G 1l
B emd.cpt 0i 0.15i+ef -B2+l"Sill emplacement depth (km)"
EOF

convert -trim +repage -flatten -background white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_emd_maps.jpg
eog sill_emd_maps.jpg
}
# multi_map_emd


multi_map_th()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
outfile="sill_th_maps.ps"
prj="-JM2.5i"
# rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Make sill file
awk -F"," '{if(NR>1)print $4,$5,$2/1000.0,$3,$7}' ${file} > temp_sills_whitespace.txt
# Convert sills into latlon
cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_x_y_diam_emdepth_trans.txt
# Make cpt for sill colour
makecpt -T0/2/0.25 -D -Crainbow > th.cpt
# Bathymetry map
makecpt -T0/4000/0.1 -I -Cabyss -Z -D > bathy.cpt
makecpt -T0/4/0.01 -I -Cabyss -Z -D > bathy2.cpt
grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4i -K > $outfile
grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Gravity map
makecpt -T0/100/1 -M -Cmagma -Z -D > grav.cpt
grdconvert ${datadir}bouguer20.tif oga_bouguer20_utm.nc
grdproject $rgn -Ju29/1:1 oga_bouguer20_utm.nc -Goga_bouguer20.nc -I -C -F
grdimage oga_bouguer20.nc -Cgrav.cpt $prj $rgn -X3.5i -K -O >> $outfile
grdcontour oga_bouguer20.nc -C20 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cgrav.cpt -B25+l"Bouguer gravity (mGal)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BS -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Magnetic map
makecpt -T-400/400/10 -M -Cpolar -Z -D > mag.cpt
makecpt -T-4/4/0.1 -M -Cpolar -Z -D > mag2.cpt
grdconvert ${datadir}rtpmaganomaly.tif oga_rtpmaganomaly_utm.nc
grdproject $rgn -Ju29/1:1 oga_rtpmaganomaly_utm.nc -Goga_rtpmaganomaly.nc -I -C -F
grdimage oga_rtpmaganomaly.nc -Cmag.cpt $prj $rgn -X-3.5i -Y-2.5i -K -O >> $outfile
grdcontour oga_rtpmaganomaly.nc -C100 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cmag2.cpt -B2+l"Magnetic anomaly (nT)" -By+l"x10@+2@+" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BSW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Legend
pslegend -Dx4i/0.2i+w2.2i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.5+r+f 0.2i red 1,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 1,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
G 1l
S 0.1i c 0.05i white 0.5,black 0.5i Sill (fill colour as below)
G 1l
B th.cpt 0i 0.15i+ef -B0.5+l"Sill transgressive height (km)"
EOF

convert -trim +repage -flatten -background white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_th_maps.jpg
eog sill_th_maps.jpg
}
# multi_map_th


scatter_plot()
{
  #,diameter,emplacement_depth,midpoint_x,midpoint_y,name,transgressive_height

  # Convert sills into GMT format. Note space removal from name with tr.
  tr -d " " <  ${file} | awk -F"," '{if(NR==1)print "# midpoint_x midpoint_y name diameter emplacement_depth transgressive_height"; else print $4,$5,$6,$2,$3,$7}' > sills_gmt_format.txt
  # Convert sills into latlon
  mapproject -Ju+29/1:1 -I -C -F sills_gmt_format.txt  > sills_gmt_format_geog.txt
  sed -i '1c #midpoint_x midpoint_y name diameter emplacement_depth transgressive_height' sills_gmt_format_geog.txt

  # Sample bathy
  grdtrack sills_gmt_format_geog.txt -Goga_bathy.nc > temp1
  # Sample grav
  grdtrack temp1 -Goga_bouguer20.nc > temp2
  # Sample mag, and remove tab separators
  grdtrack temp2 -Goga_rtpmaganomaly.nc | tr "\t" " " > sills_gmt_format_geog_sampled.txt
  # Rename header and tidy temp files
  sed -i '1c midpoint_x midpoint_y bathy grav mag name emplacement_depth transgressive_height' sills_gmt_format_geog_sampled.txt
  #rm temp1 temp2

  # Run in R
  Rscript pairs_plot.R

  # Display
  eog rockall_sills_scatterplot_matrix.png
}
# scatter_plot


grid_sill_vals()
{
  rgn=-R-14/-5/56/60.3
  # Convert sills into GMT format. Note space removal from name with tr.
  tr -d " " <  ${file} | awk -F"," '{if(NR==1)print "#midpoint_x midpoint_y name diameter emplacement_depth transgressive_height"; else print $4,$5,$6,$2,$3,$7}' > sills_gmt_format.txt
  # Convert sills into latlon
  mapproject -Ju+29/1:1 -I -C -F sills_gmt_format.txt  > sills_gmt_format_geog.txt
  sed -i '1c #midpoint_x midpoint_y name diameter emplacement_depth transgressive_height' sills_gmt_format_geog.txt

  # diameter no preprocess
  nearneighbor sills_gmt_format_geog.txt $rgn -fg -S20k -N3 -I10k -i0,1,3 -Gdiam_no_preproc.nc
  makecpt `grdinfo -T100 diam_no_preproc.nc` -Z -Crainbow > temp_diam.cpt
  grdimage -JM6i -B2 diam_no_preproc.nc -Ctemp_diam.cpt -B+t"Diameter no preprocess" -P -K > temp_diam.ps
  pscoast -J -R -Gblack -K -O >> temp_diam.ps
  psscale -J -R -D6.25i/3i/3i/0.25i -B1000 -Ctemp_diam.cpt -O >> temp_diam.ps
  evince temp_diam.ps

  # em depth no preprocess
  nearneighbor sills_gmt_format_geog.txt $rgn -fg -S20k -N3 -I10k -i0,1,4 -Gemdepth_no_preproc.nc
  makecpt `grdinfo -T1 emdepth_no_preproc.nc` -Z -Crainbow > temp_em.cpt
  grdimage -JM6i -B2 emdepth_no_preproc.nc -Ctemp_em.cpt -B+t"Emplacement depth no preprocess" -P -K > temp_em.ps
  pscoast -J -R -Gblack -K -O >> temp_em.ps
  psscale -J -R -D6.5i/3i/3i/0.25i -Ctemp_em.cpt -O >> temp_em.ps
  evince temp_em.ps

  # th no proprocess
  nearneighbor sills_gmt_format_geog.txt $rgn -fg -S20k -N3 -I10k -i0,1,5 -Gth_no_preproc.nc
  makecpt `grdinfo -T0.5 th_no_preproc.nc` -Z -Crainbow > temp_th.cpt
  grdimage -JM6i -B2 th_no_preproc.nc -Ctemp_th.cpt -B+t"Transgressive height no preprocess" -P -K > temp_th.ps
  pscoast -J -R -Gblack -K -O >> temp_th.ps
  psscale -J -R -D6.25i/3i/3i/0.25i -B1000 -Ctemp_diam.cpt -O >> temp_th.ps
  evince temp_th.ps


  # diameter with preprocess
  blockmean sills_gmt_format_geog.txt -i0,1,3 $rgn -I5k -fg > temp
  nearneighbor temp $rgn -fg -S20k -N3 -I5k  -Gdiam_with_preproc.nc
  grdmath diam_with_preproc.nc 1000 DIV = diam_with_preproc_km.nc
  makecpt `grdinfo -T100 diam_with_preproc.nc` -Z -Crainbow > temp_diam.cpt
  grdimage -JM6i -B2 diam_with_preproc.nc -Ctemp_diam.cpt -B+t"Diameter with preprocess" -P -K > temp_pre_diam.ps
  pscoast -J -R -Gblack -K -O >> temp_pre_diam.ps
  psscale -J -R -D6.25i/3i/3i/0.25i -B1000 -Ctemp_diam.cpt -O >> temp_pre_diam.ps
  evince temp_pre_diam.ps

  # em depth with preprocess
  blockmean sills_gmt_format_geog.txt -i0,1,4 $rgn -I5k -fg > temp
  nearneighbor temp $rgn -fg -S20k -N3 -I5k -Gemdepth_with_preproc.nc
  makecpt `grdinfo -T1 emdepth_with_preproc.nc` -Z -Crainbow > temp_em.cpt
  grdimage -JM6i -B2 emdepth_with_preproc.nc -Ctemp_em.cpt -B+t"Emplacement depth with preprocess" -P -K > temp_pre_em.ps
  pscoast -J -R -Gblack -K -O >> temp_pre_em.ps
  psscale -J -R -D6.5i/3i/3i/0.25i -Ctemp_em.cpt -O >> temp_pre_em.ps
  evince temp_pre_em.ps

  # th with proprocess
  blockmean sills_gmt_format_geog.txt -i0,1,5 $rgn -I5k -fg  > temp
  nearneighbor temp $rgn -fg -S20k -N3 -I5k -Gth_with_preproc.nc
  makecpt `grdinfo -T0.5 th_with_preproc.nc` -Z -Crainbow > temp_th.cpt
  grdimage -JM6i -B2 th_with_preproc.nc -Ctemp_th.cpt -B+t"Transgressive height with preprocess" -P -K > temp_pre_th.ps
  pscoast -J -R -Gblack -K -O >> temp_pre_th.ps
  psscale -J -R -D6.25i/3i/3i/0.25i -B1000 -Ctemp_diam.cpt -O >> temp_pre_th.ps
  evince temp_pre_th.ps
}
# grid_sill_vals


multi_map_all_sills()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads"
outfile="multi_map_all_sills.ps"
prj="-JM2.5i"
# rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Make cpt for sill colour
makecpt -T0/12/2 -M -Z -D -Cplasma > diam_grd.cpt
# Diameter map
grdimage diam_with_preproc_km.nc -Cdiam_grd.cpt $prj $rgn -Y4i -K > $outfile
grdcontour diam_with_preproc_km.nc -C2 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cdiam_grd.cpt -B5+l"Sill diameter (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
# psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Transgressive height map
makecpt -T0/1.5/0.25 -M -Cmagma -Z -D > th_grd.cpt
grdimage th_with_preproc.nc -Cth_grd.cpt $prj $rgn -X3.5i -K -O >> $outfile
grdcontour th_with_preproc.nc -C1 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cth_grd.cpt -B0.5+l"Transgressive height (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
# psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BS -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Emplacement depth map
makecpt -T0/6/1 -M -Cinferno -M -Z -D > em_grd.cpt
grdimage emdepth_with_preproc.nc -Cem_grd.cpt $prj $rgn -X-3.5i -Y-2.5i -K -O >> $outfile
grdcontour emdepth_with_preproc.nc -C1 $prj $rgn -Wgray10 -K -O >> $outfile
pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
psscale -D2.65i/0.35i+w1.5i/0.15i+e -Cem_grd.cpt -B2+l"Emplacement depth (km)" -K -O >> $outfile
psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
# psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB- -t50 -K -O >> $outfile
echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BSW -K -O >> $outfile
psbasemap $prj $rgn -B0 -K -O >> $outfile

# Legend
pslegend -Dx4i/0.3i+w2.2i -O <<EOF >> $outfile
S 0.1i t 0.2i red red 0.5i Volcanic centre
S 0.1i f0.25/0.5+r+f 0.2i red 1,red 0.5i Fault
S 0.1i f0.2/0.05+t 0.2i red 1,red 0.5i Inversion structure
S 0.1i - 0.2i black 1 0.5i Seismic line
S 0.1i s 0.2i p200/14:FdarkorangeB- 0 0.5i Basalt
S 0.1i c 0.05i white 0.5,black 0.5i Sill
EOF

convert -trim +repage -flatten -background white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile multi_map_all_sills.jpg
eog multi_map_all_sills.jpg
}
# multi_map_all_sills


seismic_image()
{
  # ## Get line coords
  # segyread tape=OGA_A012.sgy | segyclean | sugethw key=sx,sy output=geom > linecoords.txt
  # mapproject linecoords.txt -Ju+28/1:1 -I -C -F > linecoords_geog.txt
  # # Extract mag
  # grdtrack linecoords_geog.txt -Goga_rtpmaganomaly.nc > mag_extract.txt
  # grdtrack linecoords_geog.txt -Goga_rtpmaganomaly_dz_cut.nc > dz_mag_extract.txt
  # grdtrack linecoords_geog.txt -Goga_rtpmaganomaly_THD_cut.nc > THD_mag_extract.txt
  # # Extract grav
  # grdtrack linecoords_geog.txt -Goga_bouguer20.nc > boug_grav_extract.txt
  # grdtrack linecoords_geog.txt -Goga_bouguer20_dz_cut.nc > dz_grav_extract.txt
  # grdtrack linecoords_geog.txt -Goga_bouguer20_THD_cut.nc > THD_grav_extract.txt
  # # Plot line
  # segy2grd OGA_A012.sgy -GOGA_A012.nc -I1/0.004 -R1/7582/0/10
  outfile=seis_OGA_A012.ps
  makecpt -Cdarkblue,white,darkred -D -Z -T-400/400/10 > myseis.cpt
  gmtset FONT_LABEL 12p,Helvetica,black
  gmtset FONT_ANNOT_PRIMARY 12p,Helvetica,black
  grdimage OGA_A012.nc -JX6i/-3i -R1/7582/0/6 -Cmyseis.cpt -Bx1000+l"CDP" -By2+l"TWT (s)" -BSWne -P -K > $outfile
  echo "1250 2.4
  1600 5" | psxy -R -J -W1,red,- -K -O >> $outfile
  echo "1500 3.5 77 0.2i" | psxy -J -R -Sv0.1i+l+ea30 -Gred -W1,red -K -O >> $outfile
  ## Plot potential fields
  gmtset FONT_LABEL 12p,Helvetica,red
  gmtset FONT_ANNOT_PRIMARY 12p,Helvetica,red
  psxy boug_grav_extract.txt -JX6i/1.5i -R58.9533953568/59.4564513411/10/75 -i1,2 -W1,red -Y3i -Bx0 -By20+l"Bouguer Gravity (mGal)" -BsEn -K -O >> $outfile
  # psxy mag_extract.txt -JX6i/1.5i -R58.9533953568/59.4564513411/-182/-45 -i1,2 -W1,green -B0 -K -O >> $outfile
  gmtset FONT_LABEL 12p,Helvetica,darkred
  gmtset FONT_ANNOT_PRIMARY 12p,Helvetica,darkred
  psxy THD_grav_extract.txt -JX6i/1.5i -R58.9533953568/59.4564513411/0/0.004 -i1,2 -W1,darkred -Bx0 -By0.001+l"THD Gravity (mGal m@+-1@+)" -BsWn -O >> $outfile
  # psxy THD_mag_extract.txt -JX6i/1.5i -R58.9533953568/59.4564513411/0.001/0.02 -i1,2 -W1,darkgreen -B0 -O >> $outfile
  convert -trim +repage -flatten -background white -bordercolor white -border 30x30 -quality 100 -density 600 seis_OGA_A012.ps seis_OGA_A012.png
  eog seis_OGA_A012.png
}
# seismic_image

combo_binned_diam_em_tr()
{
  # Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
  gmtset FONT_TITLE 14p,Helvetica,black MAP_TITLE_OFFSET -10p
  datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
  outfile="combo_diam_em_tr.jpg.ps"
  prj="-JM2.5i"
  # rgn=`gmtinfo -I0.1 $linefile`
  rgn=-R-14/-5/56/60.3
  grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
  grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
  makecpt -T0/2500/0.1 -I -Cabyss -Z -D > bathy.cpt
  makecpt -T0/2.5/0.01 -I -Cabyss -Z -D > bathy2.cpt
  # Make sill file
  awk -F"," '{if(NR>1)print $4,$5,$2/1000.0,$3,$7}' ${file} > temp_sills_whitespace.txt
  # Convert sills into latlon
  cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_x_y_diam_emdepth_trans.txt
  # Make cpt for sill colour
  makecpt -T0/20/2.5 -D -Crainbow > diam.cpt
  # Diameter map
  grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -Y4.5i -K > $outfile
  grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  # psscale -D2.65i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
  psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cdiam.cpt -Wblack -i0,1,2 -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BW+t"Diameter (km)" -K -O >> $outfile
  psbasemap $prj $rgn -B0 -O -K >> $outfile

  # Emplacement depth
  grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn  -X2.6i -K -O >> $outfile
  grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D2.75i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
  psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cemd.cpt -Wblack -i0,1,3 -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BS+t"Emplacement depth (km)" -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile


  # Transgressive height
  grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -X-2.6i -Y-2.75i -K -O >> $outfile
  grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  # psscale -D2.65i/0.35i+w-1.5i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -K -O >> $outfile
  psxy $prj $rgn sills_x_y_diam_emdepth_trans.txt -Sc0.05 -Cth.cpt -Wblack -i0,1,4 -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -Bx2 -By2 -BWS+t"Transgressive height (km)" -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile



# Legend
echo "B diam.cpt 0i 0.15i+ef -B5+l\"Sill diameter (km)\"
G 2l
B emd.cpt 0i 0.15i+ef -B2+l\"Emplacement depth (km)\"
G 2l
B th.cpt 0i 0.15i+ef -B0.5+l\"Transgressive height (km)\""> leg.txt
  pslegend leg.txt -Dx2.75i/0.1i+w2.25i -O >> $outfile

  gmtset FONT_TITLE 24p,Helvetica,black MAP_TITLE_OFFSET 14p


  convert -trim +repage -flatten -background white -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile combo_diam_em_tr.jpg
  eog combo_diam_em_tr.jpg
}
# combo_binned_diam_em_tr


crustal_thickness_map()
{
  datadir="/home/murray/Documents/Work/rockall/rockall_potential_fields/old_downloads/"
  outfile="crustal_thickness_map.ps"
  prj="-JM2.5i"
  # rgn=`gmtinfo -I0.1 $linefile`
  rgn=-R-14/-5/56/60.3
  grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
  grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
  grdmath oga_bathy.nc 1000 DIV -4.82956 MUL 25.8269 ADD = crustal_thickness.nc
  # Make sill file
  awk -F"," '{if(NR>1)print $4,$5,$2/1000.0,$3,$7}' ${file} > temp_sills_whitespace.txt
  # Convert sills into latlon
  cat temp_sills_whitespace.txt | mapproject -Ju+29/1:1 -I -C -F > sills_x_y_diam_emdepth_trans.txt

  # Bathymetry map
  makecpt -T0/2500/0.1 -I -Crainbow -Z -D > bathy.cpt
  makecpt -T0/2.5/0.01 -I -Crainbow -Z -D > bathy2.cpt
  grdconvert ${datadir}bathymetry.tif oga_bathy_utm.nc
  grdproject $rgn -Ju29/1:1 oga_bathy_utm.nc -Goga_bathy.nc -I -C -F
  grdimage oga_bathy.nc -Cbathy.cpt $prj $rgn -P -Y4i -K > $outfile
  grdcontour oga_bathy.nc -C250 $prj $rgn -Wgray10 -K -O >> $outfile
  pscoast $prj $rgn -Di -Gblack -K -O >> $outfile
  psscale -D2.75i/0.15i+w-2i/0.15i+e -Cbathy2.cpt -B1+l"Bathymetry (km)" -K -O >> $outfile
  psxy $prj $rgn faults_misc.gmt -Sf0.25/0.25+r+f -W1,red -K -O >> $outfile
  psxy $prj $rgn folds_tuitt.gmt -Sf0.2/0.05+t -Gred -W1,red -K -O >> $outfile
  psxy $prj $rgn volc_tuitt.gmt -St0.2 -Gred -Wred -K -O >> $outfile
  psxy $prj $rgn $linefile -gd5k -Bx2 -By2 -BW -K -O >> $outfile
  psbasemap $prj $rgn -B0 -K -O >> $outfile
  psxy $prj $rgn sills_geog.txt -Sc0.05 -Gwhite -Wblack -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "a" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Crustal thickness map
  makecpt -Cviridis -T10/25/0.2 -D -Z -Mwhite > thickness.cpt
  grdimage crustal_thickness.nc -Cthickness.cpt $prj $rgn -Bx2 -By2 -BSwne -P -X3.6i -K -O >> $outfile
  grdcontour crustal_thickness.nc $prj $rgn -C1 -K -O >> $outfile
  psscale $rgn $prj -D2.75i/0.15i+w2i/0.15i+e -B5+l"Seafloor to moho thickness (km)" -Cthickness.cpt -K -O >> $outfile
  psxy sills_x_y_diam_emdepth_trans.txt $prj $rgn -Sc0.05 -Gwhite -W0.1 -i0,1 -K -O >> $outfile
  psxy basalt.txt $prj $rgn -Gp200/14:FdarkorangeB-  -K -O >> $outfile
  echo "c" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -K -O >> $outfile

  # Scatter graph
  psxy all_crustalthickness.txt -R0/5/2/35 -JX2.5i/2i -Sc0.1 -Gblack -Bx1+l"Seafloor depth (km)" -By10+l"Crustal thickness (km)" -P -BSWne -i0,2 -X-3.6i -Y-2.5i -K -O >> $outfile
  makecpt -Crainbow -T1/11/1 > scatter.cpt
  counter=1
  for i in `ls *moho_crustalthickness.txt`
  do
  col=`cat scatter.cpt | awk -v counter=$counter '{if(NR==counter+1) print $2}' `
  echo $counter $col
  psxy $i -G${col} -Sc0.1 -W${col} -J -R -i0,2 -K -O >> $outfile
  ((counter++))
  done
echo "S 0.1i c 0.1i 283.33-1-1 0.25p 0.3i Funck et al. 2017 RAPIDS-1
S 0.1i c 0.1i 250-1-1 0.25p 0.3i Hauser et al. 1995 n-s RAPIDS
S 0.1i c 0.1i 216.67-1-1 0.25p 0.3i Klingelhofer et al. 2005 line D
S 0.1i c 0.1i 183.33-1-1 0.25p 0.3i Klingelhofer et al. 2005 line E
S 0.1i c 0.1i 150-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-31
S 0.1i c 0.1i 116.67-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-33
S 0.1i c 0.1i 83.333-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-34
S 0.1i c 0.1i 50-1-1 0.25p 0.3i Roberts et al. 1988 profile 1
S 0.1i c 0.1i 16.667-1-1 0.25p 0.3i Roberts et al. 1988 profile 5" > leg.txt
  pslegend leg.txt -Dx3.5i/0.1i+w2i -R -J -K -O  >> $outfile
  psxy -R -J points_regressed.txt -L+d+p2,pink -W2,red -i0,2,3 -K -O >> $outfile
  psbasemap -J -R -B0 -K -O >> $outfile
  echo "b" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -O >> $outfile

  psconvert -A0.5 $outfile
  eog crustal_thickness_map.jpg
}
# crustal_thickness_map

exit
