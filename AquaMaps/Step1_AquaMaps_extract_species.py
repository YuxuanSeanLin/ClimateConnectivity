'''
    处理AquaMaps Species occurrence probability并保存
'''

import csv
import os
from pandas import DataFrame
from glob import glob
import time



os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif")
for t in range(0, 110, 10):
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s" % t)
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s\surface" % t)
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s\mesopelagic" % t)
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s\bathypelagic" % t)
    os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s\abyssopelagic" % t)



for t in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif"):
    for h in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
        for p in os.listdir(r"G:\LinYuxuan\AquaMaps\Native_range"):
            os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_tif\%s\%s\%s" % (t, h, p))





start = time.time()

folder = os.listdir(r"G:\LinYuxuan\AquaMaps\Native_range")
overall = 0

for name in folder:
    overall += 1

    # 创建对应文件夹
    for t in range(0, 110, 10):
        os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold\%s\surface\%s" % (t, name))
        os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold\%s\mesopelagic\%s" % (t, name))
        os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold\%s\bathypelagic\%s" % (t, name))
        os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold\%s\abyssopelagic\%s" % (t, name))

    os.chdir(r"G:\LinYuxuan\AquaMaps\Native_range\%s" % name)
    file = sorted(glob('*.csv'))

    print('\n######\n' + name + ' Start...')
    
    for i in file:
        depth = []  # 读取深度数据
        newRows = []  # 生成坐标表
        maxd = 0
        mind = 0
        csvFileObj = open(r"G:\LinYuxuan\AquaMaps\Native_range\%s\%s" % (name, i), encoding='utf-8-sig', errors='ignore')
        readerObj = csv.reader(csvFileObj)  # 遍历csv

        for row in readerObj:
            if readerObj.line_num in range(1, 15):  # 跳过前14行
                continue
            depth.append(row)  # 转成DataFrame更容易处理   # 或通过： ar = np.array(depth) # print(ar[:, 5]) 将列表转成数组
            test = DataFrame(depth)
            mind = test.iat[0, 2]  # 提取最小深度    
            maxd = test.iat[0, 5]  # 提取最大深度    
            if readerObj.line_num == 15:
                break
        try:
            for row in readerObj:
                if readerObj.line_num in range(1, 33):  # 跳过前32行
                    continue
                if not row:  # 空行时停止
                    break
                newRows.append(row)
    
            # 对概率进行判断，保存原始数据
            df = DataFrame(newRows,
                           columns=['Genus', 'Species', 'Latitude', 'Longitude', 'C-Square', 'probability'])
            df['occurrence'] = '0'  # 创建概率判断字段
            df['probability'] = df['probability'].astype('float')  # 字符型无法直接与浮点型比大小，需要进行数据类型转换
            
            for t in range(0, 110, 10):
                threshold = t/100
                df_raw = df.drop(['Genus', 'Species', 'C-Square'], axis=1)
                
                if threshold != 1:
                    df_raw.loc[(df.probability > threshold), 'occurrence'] = 1
                else:
                    df_raw.loc[(df.probability == threshold), 'occurrence'] = 1
                
                # surface
                if int(mind) < 200:
                    path_raw = r"G:\LinYuxuan\AquaMaps\Threshold\%s\surface\%s\%s" % (t, name, i)
                    df_raw.to_csv(path_raw, sep=',', index=False, header=True)
        
                # meso
                if int(maxd) >= 200:
                    path_raw = r"G:\LinYuxuan\AquaMaps\Threshold\%s\mesopelagic\%s\%s" % (t, name, i)
                    df_raw.to_csv(path_raw, sep=',', index=False, header=True)
        
                # bathy
                if int(maxd) >= 1000:
                    path_raw = r"G:\LinYuxuan\AquaMaps\Threshold\%s\bathypelagic\%s\%s" % (t, name, i)
                    df_raw.to_csv(path_raw, sep=',', index=False, header=True)
        
                # abysso
                if int(maxd) >= 4000:
                    path_raw = r"G:\LinYuxuan\AquaMaps\Threshold\%s\abyssopelagic\%s\%s" % (t, name, i)
                    df_raw.to_csv(path_raw, sep=',', index=False, header=True)
        
        except:
            print("%s: %s --- error" % (name, i))
                    
                    
    
    print('\n######\n' + name + ' Finish...')        
                

# 计算运行时间
end = time.time()
minute = (end - start)//60
second = (end - start) % 60

print('\n======================\n' + 'Total number of Phylum: %s' % overall +
      '\nCompleted\n' +
      'The function run time is : %d minutes %d seconds in total' % (minute, second))






##
newRows = []
csvFileObj = open(r"D:\Abyssorchomene_nodimanus.csv", encoding='utf-8-sig', errors='ignore')
readerObj = csv.reader(csvFileObj)

for row in readerObj:
    if readerObj.line_num in range(1, 33):  # 跳过前32行
        continue
    if not row:  # 空行时停止
        break
    newRows.append(row)

# 对概率进行判断，保存原始数据
df = DataFrame(newRows,
               columns=['Genus', 'Species', 'Latitude', 'Longitude', 'C-Square', 'probability'])
df['occurrence'] = '0'  # 创建概率判断字段
df['probability'] = df['probability'].astype('float')  # 字符型无法直接与浮点型比大小，需要进行数据类型转换
df_raw = df.drop(['Genus', 'Species', 'C-Square'], axis=1)
df_raw.loc[(df.probability >= 0.5), 'occurrence'] = 1

path_raw = r"D:\Data\Heterostigma_singulare.csv"
df_raw.to_csv(path_raw, sep=',', index=False, header=True)





