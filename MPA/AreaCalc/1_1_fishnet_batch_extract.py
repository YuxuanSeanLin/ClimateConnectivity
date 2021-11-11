import arcpy
from arcpy import env
import os
from glob import glob


# env.workspace = "C:/Users/Administrator/Desktop/test/"
shp = r'D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\process\Grid_30deg.shp'
out_path = r"D:\Users\Yuxuan Lin\Documents\LocalFiles\XMU\Connectivity\MPA\Fishnet_units"
query = """"Id">0"""

with arcpy.da.SearchCursor(shp, ["SHAPE@",'Id'],query) as cursor:
#SHAPE@指代单个要素，RANK是一个字段，query是条件
    for row in cursor:
        out_name=str(row[1])+'.shp'#输出文件名
        print(out_name)
        arcpy.FeatureClassToFeatureClass_conversion(row[0],out_path,out_name)

