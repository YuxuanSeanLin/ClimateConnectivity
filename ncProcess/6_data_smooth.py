## arcpy focal statisics

import os
from glob import glob
import arcpy
from arcpy import env

# for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
#     for scen in ['historical', 'ssp126', 'ssp245', 'ssp370', 'ssp585']:
#         for para in os.listdir(r'D:\Users\Yuxuan Lin\Documents\LocalFiles\5_data_expand\%s\%s' % (depth, scen)):

for depth in ['bathypelagic']:
    for scen in ['ssp585']:
        for para in ['si', 'so', 'talk', 'thetao', 'zooc']:
            from_path = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\5_data_expand\%s\%s\%s' % (depth, scen, para)
            to_path = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\6_data_smooth\%s\%s\%s' % (depth, scen, para)
            for f in os.listdir(from_path):
                masktif = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\4_data_mdmean\%s\%s\%s\%s' % (depth, scen, para, f)
                with arcpy.EnvManager(mask=masktif):
                    out_raster = arcpy.ia.FocalStatistics("%s/%s" % (from_path, f), 
                                                          "Rectangle 3 3 CELL", "MEAN"); 
                    out_raster.save("%s/%s" % (to_path, f))
                print("%s finish" % f)
            print("======== %s - %s - %s : complete ========" % (depth, scen, para))


