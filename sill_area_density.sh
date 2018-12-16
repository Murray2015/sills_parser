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
datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
outfile="intro_maps.ps"
prj="-JM2.5i"
rgn=`gmtinfo -I0.1 $linefile`
rgn=-R-14/-5/56/60.3
# Bathymetry map
makecpt -T0/4000/0.1 -I -Cabyss -Z -D > bathy.cpt
makecpt -T0/4/0.01 -I -Cabyss -Z -D > bathy2.cpt
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

convert -trim -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile intro_maps.jpg
eog intro_maps.jpg
}
# multi_map


sill_stat_hist()
{
# Histogram of sill lengths, transgressive heights and emplacement depth
awk -F"," '{if(NR>1)print $2/1000, $3, $7}' ${file} > temp_sills_whitespace.txt
outfile=sill_stat_hist.ps
pshistogram temp_sills_whitespace.txt -JX2.5i -R0/40/0/150 -W1 -Bx10+l"Diameter (km)" -By50+l"Frequency" -BSWne -Gblack -i0 -K > $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -W0.1 -Bx1+l"Transgressive height (km)" -BsNwe -Gblack -i2 -X2.5i -K -O >> $outfile
pshistogram temp_sills_whitespace.txt -JX2.5i -W0.1 -Bx2+l"Emplacement depth (km)" -BSwne -Gblack -i1 -X2.5i -O >> $outfile
psconvert $outfile -A0.5 -P
eog sill_stat_hist.jpg
}
# sill_stat_hist

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
  echo "d" | pstext $prj $rgn -F+cBL -C25% -W1.5 -D0.2 -Gwhite -O >> $outfile
  psconvert -A0.75 -P -E600 pot_deriv_maps_4.ps
  eog pot_deriv_maps_4.jpg
}
pot_der_4


multi_map_diam()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
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

convert -trim -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_diam_maps.jpg
eog sill_diam_maps.jpg
}
# multi_map_diam


multi_map_emd()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
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

convert -trim -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_emd_maps.jpg
eog sill_emd_maps.jpg
}
# multi_map_emd


multi_map_th()
{
# Dataset maps x3, and in 4th panel add legend + add extra symbols, eg igneous centres and regional faults. Add text to map eg rosemary bank - Get OGA grav and mag data.
datadir="/home/murray/Documents/Work/rockall_potential_fields/Rockall_Trough/Processed/grids/geotiff/"
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

convert -trim -rotate 90 -bordercolor white -border 30x30 -quality 100 -density 600 $outfile sill_th_maps.jpg
eog sill_th_maps.jpg
}
# multi_map_th




exit
