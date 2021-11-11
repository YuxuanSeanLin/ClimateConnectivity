import os
from glob import glob
import arcpy
from arcpy import env

wd = ''
for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
    for scen in ['ssp126', 'ssp245', 'ssp370', 'ssp585']:
        env.workspace = '%s/8_rs2point/%s/%s' % (wd, depth, scen)
        os.chdir('%s/8_rs2point/%s/%s' % (wd, depth, scen))
        files = sorted(glob("*shp"))
        for f in files:
            name = f.split('.shp')[0]
            to_path = "%s/9_idw/%s/%s/%s.tif" % (wd, depth, scen, name)

            with arcpy.EnvManager(mask="bathymetry/%s.tif" % depth, extent="-180 -90 180 90"):
                arcpy.gp.Idw_sa(f, "value", to_path, "1", "3", "VARIABLE 12", "")

        print("%s: %s --- complete" % (depth, scen))



