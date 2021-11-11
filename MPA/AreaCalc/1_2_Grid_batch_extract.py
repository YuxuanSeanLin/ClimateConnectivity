import arcpy
from arcpy import env
import os
from glob import glob

out_path = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Seascape_units'
grid_1deg = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\process\Grid_seascape.shp'

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Fishnet_units'
os.chdir(r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Fishnet_units')
grids = sorted(glob('*shp'))

for unit in grids:
    Id = unit.split('.')[0]
    arcpy.Intersect_analysis(in_features=[unit, grid_1deg], out_feature_class='%s/Grid_%s.shp' % (out_path, Id), join_attributes="ALL")
    print('%s complete' % Id)




