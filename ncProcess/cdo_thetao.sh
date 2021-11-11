
cd /mnt/hgfs/cmip6/data/thetao_add/ssp126

txtfiles=`ls *.txt`
for txt in ${txtfiles};do
yr=${txt%%.*}
echo $yr

ncfiles=`sed -n '1p' ${txt}`
for f in ${ncfiles};do
	ofile="${yr}/${f%%.*}_${yr}.nc"
	echo $f
	echo $ofile
	cdo -yearmean -sellonlatbox,-180,180,-90,90 -remapbil,r360*180 -selyear,${yr} ${f} ${ofile}
done
done


#### TaiESM1

cd /mnt/hgfs/cmip6/data/thetao_add

for scen in ssp126;do
dname="/mnt/hgfs/cmip6/data/thetao_add/${scen}"
echo $dname
cd ${dname}
for yr in {2051..2099};do
ifile="thetao_Omon_TaiESM1_${scen}_r1i1p1f1_gn_${yr}01-${yr}12.nc"
ofile="${yr}/thetao_Omon_TaiESM1_${scen}_r1i1p1f1_gn_${yr}01-${yr}12_${yr}.nc"
cdo -yearmean -sellonlatbox,-180,180,-90,90 -remapbil,r360*180 -selyear,${yr} ${ifile} ${ofile}
echo $ofile
done
done

cd /mnt/hgfs/cmip6/data/thetao_add/ssp126
for yr in {2085..2094};do
ifile="thetao_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_208501-209412.nc"
ofile="${yr}/thetao_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_208501-209412_${yr}.nc"
cdo -yearmean -sellonlatbox,-180,180,-90,90 -remapbil,r360*180 -selyear,${yr} ${ifile} ${ofile}
echo $ofile
done

thetao_Omon_CanESM5_ssp585_r1i1p1f1_gn_207101-208012
thetao_Omon_CanESM5_ssp585_r1i1p1f1_gn_208101-209012.nc


