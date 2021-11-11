import arcpy
from arcpy import env
import os
from glob import glob


input_mpa = r'D:\Users\Yuxuan Lin\Documents\ArcGIS\Default.gdb\MPA_u0_Dissolve'
out_path = r"D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_units\MPA1"

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Fishnet_units'
os.chdir(r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Fishnet_units')
grids = sorted(glob('*shp'))

for input_grid in grids:
    Id = input_grid.split('.')[0]
    try:
        arcpy.Intersect_analysis(in_features=[input_grid, input_mpa], out_feature_class='%s/MPA1_%s.shp' % (out_path, Id), join_attributes="ALL")
        print('%s complete' % Id)
    except:
        pass




