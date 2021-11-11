# processed by Climate Data Operator
# GFDL-ESM4 example

cd /mnt/hgfs/cmip6/data/thetao_add

for yr in {2095..2100};do
ifile="thetao_Omon_GFDL-ESM4_ssp126_r1i1p1f1_gn_209501-210012.nc"
ofile="${yr}/thetao_Omon_GFDL-ESM4_ssp126_r1i1p1f1_gn_209501-210012_${yr}.nc"
cdo -yearmean -sellonlatbox,-180,180,-90,90 -remapbil,r360*180 -selyear,${yr} ${ifile} ${ofile}
echo $ofile
done

