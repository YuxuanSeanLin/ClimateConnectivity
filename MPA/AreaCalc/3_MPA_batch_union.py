import arcpy
from arcpy import env

out_path = r"D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_union_units"
env.workspace = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\MPA_units'

for Id in range(1, 65):
    mpa1 = 'MPA1/MPA1_%s.shp' % Id
    mpa2 = 'MPA2/MPA2_%s.shp' % Id
    mpa3 = 'MPA3/MPA3_%s.shp' % Id
    arcpy.Union_analysis(in_features=[mpa1, mpa2, mpa3], out_feature_class='%s/MPA_u_%s.shp' % (out_path, Id), join_attributes="ALL")
    print('%s complete' % Id)




