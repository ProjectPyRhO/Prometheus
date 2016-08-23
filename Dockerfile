FROM jupyter/minimal-notebook
# Alternative: debian
# Based on the Jupyter scipy-notebook
# https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook

MAINTAINER Project PyRhO <projectpyrho@gmail.com>

USER root

# libav-tools for matplotlib anim
# NEURON dependencies start at autotools-dev
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    libav-tools \
                    git \
                    gcc \
                    g++ \
                    gfortran \
                    libatlas-dev \
                    libatlas-base-dev \
                    libfreetype6-dev \
                    autotools-dev \
                    autoconf \
                    automake \
                    libtool \
                    bison \
                    flex \
                    xfonts-100dpi \
                    libncurses5-dev \
                    libxext-dev \
                    libreadline-dev \
                    libopenmpi-dev \
                    openmpi-bin \
                    openmpi-doc \
                    openmpi-common \
                    liblapack-dev \
                    libblas-dev \
                    libxft-dev \
                    mercurial \
                    mercurial-common && \
  apt-get clean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/*
# Official Debian and Ubuntu images automatically run apt-get clean

### Change locale to en_GB
# https://github.com/jupyter/docker-stacks/blob/master/minimal-notebook/Dockerfile

RUN echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB.UTF-8

USER $NB_USER

RUN conda config --add channels brian-team
# TODO: Update ipywidgets to 5.1*
# conda install -c conda-forge lmfit=0.9.5
# Install Python 3 packages
RUN conda install --quiet --yes \
    'ipywidgets=4.1*' \
    'pandas=0.18*' \
    'numexpr=2.5*' \
    'matplotlib=1.5*' \
    'scipy=0.17*' \
    #'lmfit=0.9*' \
    'seaborn=0.7*' \
    'sympy=1.0*' \
    'cython=0.24*' \
    'bokeh=0.11*' \
    'h5py=2.6*' \
    'nose=1.3*' \
    'brian2' \
    'brian2tools' \
    && conda clean -tipsy

# Install Python 2 packages
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'ipython=4.2*' \
    'ipywidgets=4.1*' \
    'pandas=0.18*' \
    'numexpr=2.5*' \
    'matplotlib=1.5*' \
    'scipy=0.17*' \
    #'lmfit=0.9*' \
    'seaborn=0.7*' \
    'sympy=1.0*' \
    'cython=0.24*' \
    'bokeh=0.11*' \
    'h5py=2.6*' \
    'nose=1.3*' \
    'brian2' \
    'brian2tools' \
    'pyzmq' \
    && conda clean -tipsy

USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install

### NEURON installation
#USER root
# Setup NEURON
#RUN echo $HOME
#/home/$NB_USER/
#COPY install_neuron.sh /home/$NB_USER/
#COPY install_neuron.sh /usr/local/bin/
#RUN sudo install_neuron.sh /usr/local/bin/NEURON
#CMD ["install_neuron.sh", "/home/$NB_USER/NEURON"]
#RUN chown -R $NB_USER:users /home/$NB_USER
#RUN ls -al
#RUN /home/$NB_USER/install_neuron.sh
#RUN sudo /home/$NB_USER/install_neuron.sh
#CMD ["/home/jovyan/install_neuron.sh"]
#USER jovyan

#USER root

ENV NDIR /opt/neuron
ENV NRNPY python3
ENV ARCH x86_64

RUN mkdir $NDIR

ENV VNRN 7.4
ENV VIV 19
RUN cd /root; wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/nrn-$VNRN.tar.gz
RUN cd /root; wget -q http://www.neuron.yale.edu/ftp/neuron/versions/v$VNRN/iv-$VIV.tar.gz
RUN mv /root/nrn-$VNRN.tar.gz /root/iv-$VIV.tar.gz $NDIR/
RUN cd $NDIR; tar xzf iv-$VIV.tar.gz; rm iv-$VIV.tar.gz; mv iv-$VIV iv
RUN cd $NDIR; tar xzf nrn-$VNRN.tar.gz; rm nrn-$VNRN.tar.gz; mv nrn-$VNRN nrn

#RUN cd $NDIR; hg clone http://www.neuron.yale.edu/hg/neuron/nrn
#RUN cd $NDIR; hg clone http://www.neuron.yale.edu/hg/neuron/iv

RUN cd $NDIR/iv; ./build.sh; ./configure --prefix=`pwd` --with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ && make && make install

#RUN cd $NDIR/nrn; sh src/nrnmpi/mkdynam.sh; ./build.sh;
RUN cd $NDIR/nrn; ./build.sh;
RUN cd $NDIR/nrn; 2to3 -w src/oc/mk_hocusr_h.py; sed -i '1i from __future__ import print_function' src/oc/mk_hocusr_h.py
RUN cd $NDIR/nrn; sed -i.bak -e "s/print sys.api_version,/from __future__ import print_function; print(sys.api_version)/" configure
# --with-music=/usr/local
RUN cd $NDIR/nrn; ./configure --prefix=`pwd` --with-iv=$NDIR/iv --with-nrnpython=$NRNPY --with-paranrn=dynamic \
--with-x --x-includes=/usr/include/ --x-libraries=/usr/lib/ --with-mpi && make && make install
RUN echo 'export PATH=$PATH:$NDIR/iv/$ARCH/bin:$NDIR/nrn/$ARCH/bin' >> /etc/bash.bashrc
#RUN echo 'PYTHONPATH=$PYTHONPATH:$NDIR/nrn/lib/python'
RUN echo 'export NRN_NMODL_PATH=$NDIR' >> /etc/bash.bashrc
RUN cd $NDIR/nrn/src/nrnpython; python setup.py install
RUN chmod o+w $NDIR

USER $NB_USER

### Install PyRhO
ENV VPYRHO 0.9.4
# For upgrading: -U --ignore-installed --no-deps
#ADD squash.sh . # Use to invalidate the cache
## Install for Python 3
#RUN pip install pyrho[full]==$VPYRHO
RUN pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
#RUN pip install brian2tools
## Install for Python 2
#RUN $CONDA_DIR/envs/python2/bin/pip install pyrho[full]==$VPYRHO
RUN $CONDA_DIR/envs/python2/bin/pip install git+https://github.com/ProjectPyRhO/PyRhO.git#egg=PyRhO[full]
#RUN $CONDA_DIR/envs/python2/bin/pip install brian2tools
# Alternative to installing for Python 2
#RUN source activate python2
#RUN pip install --ignore-installed --no-deps pyrho[full]
#RUN source deactivate

#RUN source /etc/bash.bashrc
ENV NRN_NMODL_PATH $NDIR
RUN python -c "from pyrho import *; setupNEURON()"

USER root

### Copy demonstration notebook and config files to home directory
COPY Prometheus_demo.ipynb /home/$NB_USER/work/
#COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/work
RUN chown -R $NB_USER:users $NDIR

#USER $NB_USER
#RUN find . -name '*.ipynb' -exec jupyter trust {} \;

RUN find /home/$NB_USER/work -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \; && \
    chown -R $NB_USER:users /home/$NB_USER && \
    sudo -u $NB_USER env "PATH=$PATH" find /home/$NB_USER/work -name '*.ipynb' -exec jupyter trust {} \;

# Finally, add the site specific try.projectpyrho.org configuration.

#USER root
COPY resources/templates/ /srv/templates/
RUN chmod a+rX /srv/templates

# Append tmpnb specific options to the base config
COPY resources/jupyter_notebook_config.partial.py /tmp/
RUN cat /tmp/jupyter_notebook_config.partial.py >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    rm /tmp/jupyter_notebook_config.partial.py

USER $NB_USER
