## arcpy focal statisics

import os
from glob import glob
import arcpy
from arcpy import env

wd = ''

## moving window averaging ##

for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
    for scen in ['ssp126', 'ssp245', 'ssp370', 'ssp585']:
        from_path = '%s/thetao_expand/%s/%s' % (wd, depth, scen)
        to_path = '%s/thetao_smooth/%s/%s' % (wd, depth, scen)
        for f in os.listdir(from_path):
            masktif = '%s/thetao_smooth/%s/%s/%s' % (wd, depth, scen, f)
            with arcpy.EnvManager(mask=masktif):
                out_raster = arcpy.ia.FocalStatistics("%s/%s" % (from_path, f), 
                                                      "Rectangle 3 3 CELL", "MEAN"); 
                out_raster.save("%s/%s" % (to_path, f))
            print("%s finish" % f)
        print("======== %s - %s: complete ========" % (depth, scen))

        
## IDW interpolation ##

for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
    for scen in ['ssp126', 'ssp245', 'ssp585']:
        env.workspace = '%s/thetao_exp2p/%s/%s' % (wd, depth, scen)
        os.chdir('%s/thetao_exp2p/%s/%s' % (wd, depth, scen))
        files = sorted(glob("*shp"))
        for f in files:
            name = f.split('.shp')[0]
            to_path = "%s/thetao_idw/%s/%s/%s.tif" % (wd, depth, scen, name)

            with arcpy.EnvManager(mask="%s/bathymetry/%s.tif" % (wd, depth), extent="-180 -90 180 90"):
                arcpy.gp.Idw_sa(f, "value", to_path, "1", "3", "VARIABLE 12", "")

        print("%s: %s --- complete" % (depth, scen)) 
        
