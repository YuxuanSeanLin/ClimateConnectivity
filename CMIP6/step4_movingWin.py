## arcpy focal statisics

import os
from glob import glob
import arcpy
from arcpy import env

wd = ''
for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
    for scen in ['ssp126', 'ssp245', 'ssp370', 'ssp585']:
        from_path = '%s/5_data_expand/%s/%s' % (wd, depth, scen)
        to_path = '%s/6_data_smooth/%s/%s' % (wd, depth, scen)
        for f in os.listdir(from_path):
            masktif = '%s/4_data_mdmean/%s/%s/%s' % (wd, depth, scen, f)
            with arcpy.EnvManager(mask=masktif):
                out_raster = arcpy.ia.FocalStatistics("%s/%s" % (from_path, f), 
                                                      "Rectangle 3 3 CELL", "MEAN"); 
                out_raster.save("%s/%s" % (to_path, f))
            print("%s finish" % f)
        print("======== %s - %s: complete ========" % (depth, scen))

        
        
