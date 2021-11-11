import os
from glob import glob
import arcpy
from arcpy import env

dir = 'D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/CMIP6'
# ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']

for depth in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
    for scen in ['historical', 'ssp126', 'ssp245', 'ssp370', 'ssp585']:
        for para in os.listdir('%s/8_rs2point/%s/%s' % (dir, depth, scen)):
            env.workspace = '%s/8_rs2point/%s/%s/%s' % (dir, depth, scen, para)
            os.chdir('%s/8_rs2point/%s/%s/%s' % (dir, depth, scen, para))
            files = sorted(glob("*shp"))
            for f in files:
                name = f.split('.shp')[0]
                to_path = "%s/9_idw/%s/%s/%s/%s.tif" % (dir, depth, scen, para, name)

                with arcpy.EnvManager(mask=r"D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\CMIP6\bathymetry\%s.tif" % depth, extent="-180 -90 180 90"):
                    arcpy.gp.Idw_sa(f, "value", to_path, "1", "3", "VARIABLE 12", "")
            
            print("%s  %s: %s --- complete" % (depth, scen, para))



