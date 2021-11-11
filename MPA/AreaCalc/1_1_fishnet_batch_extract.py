import arcpy
from arcpy import env
import os
from glob import glob

# set work dictionary
wd = ''



## ================================
## ================================
# batch-processing by every 30-degree

## create fishnets by ArcMap
grid_30deg = '%s/Grid_30deg.shp' % wd
grid_1deg =  '%s/Grid_1deg.shp' % wd

## export units by attributes
out_path = "%s/Fishnet_units" % wd   # folder to restore exported 30-degree units
query = """"Id">0"""
with arcpy.da.SearchCursor(shp, ["SHAPE@",'Id'],query) as cursor:
    for row in cursor:
        out_name=str(row[1])+'.shp'
        print(out_name)
        arcpy.FeatureClassToFeatureClass_conversion(row[0],out_path,out_name)

## extract 1-degree fishnet with 30-degree units
out_path = '%s/Seascape_units' % wd    # folder to restore extracted 1-degree units
env.workspace = '%s/Seascape_units' % wd
os.chdir("%s/Fishnet_units" % wd)
grids = sorted(glob('*shp'))
for unit in grids:
    Id = unit.split('.')[0]
    arcpy.Intersect_analysis(in_features=[unit, grid_1deg], out_feature_class='%s/Grid_%s.shp' % (out_path, Id), join_attributes="ALL")
    print('%s complete' % Id)
    
    

## ================================
## ================================
# batch-extract MPA

input_mpa = 'MPA.shp'   # MPA boundaries should be first dissoved (ArcMap)
out_path = "%s/MPA_units" % wd   # folder to restore extracted MPAs
env.workspace = "%s/Fishnet_units" % wd
os.chdir("%s/Fishnet_units" % wd)
grids = sorted(glob('*shp'))
for input_grid in grids:
    Id = input_grid.split('.')[0]
    try:
        arcpy.Intersect_analysis(in_features=[input_grid, input_mpa], out_feature_class='%s/MPA_%s.shp' % (out_path, Id), join_attributes="ALL")
        print('%s complete' % Id)
    except:
        pass
   



