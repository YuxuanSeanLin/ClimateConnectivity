import arcpy
from arcpy import env
import os
from glob import glob

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA'

for Id in range(1, 65):
    in_mpa = 'proj_MPA_intersect/proj_mpa_%s.shp' % Id
    in_grid = "proj_seascape_units/proj_grid_%s.shp" % Id
    # add field
    arcpy.AddField_management(in_table=in_mpa, field_name="area", field_type="DOUBLE")
    arcpy.AddField_management(in_table=in_grid, field_name="area", field_type="DOUBLE")

    # calculate geometry
    arcpy.management.CalculateGeometryAttributes(in_mpa, [["area", "AREA"]], '', "SQUARE_KILOMETERS", None, "SAME_AS_INPUT")
    arcpy.management.CalculateGeometryAttributes(in_grid, [["area", "AREA"]], '', "SQUARE_KILOMETERS", None, "SAME_AS_INPUT")

    print('%s complete' % Id)

