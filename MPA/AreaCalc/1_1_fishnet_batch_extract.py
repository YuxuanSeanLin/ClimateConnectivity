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
# batch-extract MPAs
# extract MPA areas that lie within [30-degree] units

env.workspace = "%s/Fishnet_units" % wd
input_mpa = 'MPA.shp'   # MPA boundaries should be first dissoved (ArcMap)
out_path = "%s/MPA_units" % wd   # folder to restore extracted MPAs

os.chdir("%s/Fishnet_units" % wd)
grids = sorted(glob('*shp'))
for input_grid in grids:
    Id = input_grid.split('.')[0]
    try:
        arcpy.Intersect_analysis(in_features=[input_grid, input_mpa], out_feature_class='%s/MPA_%s.shp' % (out_path, Id), join_attributes="ALL")
        print('%s complete' % Id)
    except:
        pass
   


## ================================
## ================================
# batch-dissolve MPAs
# dissolve all boundaries at each units

env.workspace = "%s/MPA_units" % wd 
for Id in range(1, 65):
    in_mpa = 'MPA_%s.shp' % Id
    outpath = "%s/MPA_dissolved/MPA_d_%s.shp" % (wd, Id)   # folder to restore dissolved MPAs
    
    # dissolve features with same attributes 
    arcpy.AddField_management(in_table=in_mpa, field_name="did", field_type="DOUBLE")   
    arcpy.CalculateField_management(in_table=in_mpa, field="did", expression="1")
    arcpy.Dissolve_management(in_features=in_mpa, out_feature_class=outpath, dissolve_field="did")
    print('%s complete' % Id)
    
    
    
## ================================
## ================================
# batch-extract MPAs
# extract MPA areas that lie within [1-degree] units
# to minimize calculation by separating into 30-degree units first

out_path = '%s/MPA_intersect' % wd   # folder to restore intersected MPAs (1-deg)
for Id in range(1, 65):
    in_mpa = '%s/MPA_dissolved/MPA_d_%s.shp' % (wd, Id)    # dissolved MPAs units (each 30-deg units)
    in_grid = '%s/Seascape_units/Grid_%s.shp' % (wd, Id)    # 1-degree fishnet
    arcpy.Intersect_analysis(in_features=[in_mpa, in_grid], out_feature_class='%s/MPA_intersect_%s.shp' % (out_path, Id), join_attributes="ALL")
    print('%s complete' % Id)
    
    
    
## ================================
## ================================
# project MPAs
# convert GCS to PGS
# Mollweide equal-area projection: zonal statistics 

    
out_mpa = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\proj_MPA_intersect'
out_grid = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\proj_seascape_units'

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA'

for Id in range(1, 65):
    in_mpa = 'MPA_intersect/MPA_intersect_%s.shp' % Id
    in_grid = 'Seascape_units/Grid_%s.shp' % Id
    # MPA projection
    arcpy.Project_management(in_dataset=in_mpa, out_dataset="%s/proj_mpa_%s.shp" % (out_mpa, Id), 
    out_coor_system="PROJCS['WGS_1984_Mollweide',GEOGCS['GCS_WGS_1984',DATUM['D_unknown',SPHEROID['WGS84',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Mollweide'],PARAMETER['False_Easting',0.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',0.0],UNIT['Meter',1.0]]")

    # grid projection
    arcpy.Project_management(in_dataset=in_grid, out_dataset="%s/proj_grid_%s.shp" % (out_grid, Id), 
    out_coor_system="PROJCS['WGS_1984_Mollweide',GEOGCS['GCS_WGS_1984',DATUM['D_unknown',SPHEROID['WGS84',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Mollweide'],PARAMETER['False_Easting',0.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',0.0],UNIT['Meter',1.0]]")

    print('%s complete' % Id)
