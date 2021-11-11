import arcpy
from arcpy import env
import os
from glob import glob

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

