import arcpy
from arcpy import env
import os
from glob import glob

out_mpa = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\proj_MPA_intersect'
out_grid = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\proj_seascape_units'

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA'

for Id in range(1, 65):
    in_mpa = 'proj_MPA_intersect/proj_mpa_%s.shp' % Id
    in_grid = 'proj_seascape_units/proj_grid_%s.shp' % Id

    # join field
    arcpy.JoinField_management(in_data=in_grid, in_field="num", join_table=in_mpa, join_field="num", fields="area")

    # add field
    arcpy.AddField_management(in_table=in_grid, field_name="ratio", field_type="DOUBLE")

    # calculate ratio
    arcpy.CalculateField_management(in_table=in_grid, field="ratio", expression="!area_1! / !area!", expression_type="PYTHON_9.3")

    print('%s complete' % Id)

