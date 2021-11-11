import arcpy
from arcpy import env
import os
from glob import glob

env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_union_units'

for Id in range(1, 65):
    in_mpa = 'MPA_u_%s.shp' % Id
    outpath = r"D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_union_units_dissolved\MPA_ud_%s.shp" % Id
    arcpy.AddField_management(in_table=in_mpa, field_name="did", field_type="DOUBLE")
    arcpy.CalculateField_management(in_table=in_mpa, field="did", expression="1")
    arcpy.Dissolve_management(in_features=in_mpa, out_feature_class=outpath, dissolve_field="did")
    print('%s complete' % Id)

