# Tutorials
## Climate Data Operator (shell-Linux)
```shell
sudo apt-get update -y
sudo apt-get install libnetcdf-dev libnetcdff-dev 
sudo apt-get install -y netcdf-bin
sudo apt-get install -y cdo
```


## xarray (Python-Win)
```python
# install packages
# install using pip or conda
conda install -c conda-forge/label/cf202003 rioxarray
conda install xarray
conda install -c oggm salem
conda install -c conda-forge/label/cf202003 rasterio

# optional mirrors
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge 
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/

```



