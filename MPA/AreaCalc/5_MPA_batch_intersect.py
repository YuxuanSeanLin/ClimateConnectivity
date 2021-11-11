import arcpy
from arcpy import env
import os
from glob import glob

out_path = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_intersect'
env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA'

for Id in range(1, 65):
    in_mpa = 'MPA_union_units_dissolved/MPA_ud_%s.shp' % Id
    in_grid = 'Seascape_units/Grid_%s.shp' % Id
    arcpy.Intersect_analysis(in_features=[in_mpa, in_grid], out_feature_class='%s/MPA_intersect_%s.shp' % (out_path, Id), join_attributes="ALL")
    print('%s complete' % Id)


