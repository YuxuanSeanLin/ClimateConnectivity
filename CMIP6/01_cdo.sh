# Processed by Climate Data Operator (https://code.mpimet.mpg.de/projects/cdo)

cd /mnt/hgfs/cmip6

for yr in {2020..2100};do
ifile="<filename>"
ofile="<filename>"
cdo -yearmean -sellonlatbox,-180,180,-90,90 -remapbil,r360×180 -selyear,${yr} ${ifile} ${ofile}
echo $ofile
done

