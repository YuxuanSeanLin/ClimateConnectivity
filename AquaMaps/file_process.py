# -*- coding: utf-8 -*-
"""
Created on Tue Jun  1 11:10:10 2021

@author: DELL
"""

import os 
from glob import glob
import pandas as pd

# 文件清点
final = []
for t in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample"):
    re = [round(int(t)/100, 1)]
    for h in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
        num = 0
        for p in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample\%s\%s" % (t, h)):
            os.chdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample\%s\%s\%s" % (t, h, p))
            files = sorted(glob("*tif"))
#            files = os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample\%s\%s\%s" % (t, h, p))
            num = num + len(files)
        re.append(num)
        print("Threshold: %s, %s, total species: %s" % (t, h, num))
    final.append(re)
    print("== threshold: %s complete ==" % t)

final = pd.DataFrame(final, columns=['threshold', 'surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic'])
final.sort_values(by = 'threshold', ascending = True).to_csv(r"G:\LinYuxuan\AquaMaps\Threshold_csv.csv", header=True, index=False)


# 文件夹创建
os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel")
for t in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample"):
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s" % t)
    for h in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
        os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s" % (t, h))
        for percent in ['25', '50', '75', '100']:
            os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s\%s" % (t, h, percent))
            for p in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample\%s\%s" % (t, h)):
                os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s\%s\%s" % (t, h, percent, p))
            

final = pd.DataFrame(final, columns=['threshold', 'surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic'])
final.sort_values(by = 'threshold', ascending = True).to_csv(r"G:\LinYuxuan\AquaMaps\Threshold_csv.csv", header=True, index=False)


# 特定文件夹清点
sum = 0
for p in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_upscale\0\surface"):
    os.chdir(r"G:\LinYuxuan\AquaMaps\Threshold_upscale\0\surface\%s" % p)
    sum = sum + len(sorted(glob("*tif")))
    
    