#! /bin/bash

# Update package list
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade

# Install dependencies (General)
sudo apt-get -y install git gfortran libatlas-dev libatlas-base-dev libfreetype6-dev

# Install dependencies (Python 2)
sudo apt-get -y install python-pip
sudo pip install -U pip
sudo apt-get -y install python-numpy python-scipy python-matplotlib
sudo pip install pyrho[full]

# Install dependencies (Python 3)
sudo apt-get -y install python3-pip
sudo pip3 install -U pip
sudo apt-get -y install python3-numpy python3-scipy python3-matplotlib
sudo pip3 install pyrho[full]

sudo apt-get autoremove

# Jupyter Hub (Requires Python >= 3.3)
# https://github.com/jupyter/jupyterhub
sudo apt-get -y install npm nodejs-legacy
sudo npm install -g configurable-http-proxy
sudo pip3 install jupyterhub
# To run notebook servers locally
pip3 install --upgrade notebook

# Install Python Kernels
sudo ipython2 kernelspec install-self
# This should be jupyter kernelspec

# Changes to jupyterhub_config.py
jupyterhub --generate-config
# c.Spawner.env_keep = ['PATH', 'PYTHONPATH', 'CONDA_ROOT', 'CONDA_DEFAULT_ENV', 'VIRTUAL_ENV', 'LANG', 'LC_ALL', 'NRN_NMODL_PATH']
# https://github.com/jupyterhub/jupyterhub/issues/330
echo "c.Spawner.env_keep.append('NRN_NMODL_PATH')" >> jupyterhub_config.py
echo "c.Spawner.notebook_dir = '~/notebooks'" >> jupyterhub_config.py