
# docker build -t datasci .

# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#run-jupyterlab
# docker run -it -e JUPYTER_ENABLE_LAB=yes -p 8888:8888 --net=dockernet  -v "$PWD":/home/jovyan datasci start.sh jupyter lab --LabApp.token=''

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#core-stacks
# https://raw.githubusercontent.com/jupyter/docker-stacks/master/datascience-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/datascience-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Ben <ben.is.located@gmail.com>"

# based on
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

USER root

#RUN conda update conda
RUN conda config --add channels auto && \
    conda config --add channels conda-forge
#    conda config --add channels jlmenut && \ # weasyprint
#    conda config --add channels qinves && \ # pycallgraph
#    conda config --add channels trung && \

RUN conda install --quiet --yes \
# https://anaconda.org/conda-forge/bash_kernel
  'bash_kernel' \
  'dicttoxml' \
 'pandas' \
#https://github.com/quandyfactory/dicttoxml
 'xmltodict' \
#https://anaconda.org/conda-forge/xmltodict
#    'dict2xml' \
# 'google-api-python-client' \
#https://anaconda.org/conda-forge/google-api-python-client
# 'oauth2client' \
#https://anaconda.org/conda-forge/oauth2client
 'httplib2' \
#https://github.com/httplib2/httplib2
# 'lxml' \
#https://github.com/lxml/lxml
 'missingno' \
#https://github.com/ResidentMario/missingno
# 'python-pdfkit' \
#https://anaconda.org/conda-forge/python-pdfkit
# 'pydot' \
#https://anaconda.org/anaconda/pydot
# 'selenium' \
#https://anaconda.org/conda-forge/selenium
#    'json2xml' \
#https://anaconda.org/auto/json2xml
# 'tzlocal' \
#https://anaconda.org/conda-forge/tzlocal
# 'wkhtmltopdf' \
#https://anaconda.org/bioconda/wkhtmltopdf
# 'xhtml2pdf' \
#https://anaconda.org/SasView/xhtml2pdf
# 'xlsxwriter' \
#https://anaconda.org/anaconda/xlsxwriter
# 'pypdf2' \
#http://mstamy2.github.io/PyPDF2/
 'faker' \
#https://faker.readthedocs.io/en/master/
 'graphviz' \
 'python-graphviz' \
 'pygraphviz' \
 'pydot' \
 'line_profiler' \
#https://anaconda.org/anaconda/line_profiler
# 'py2neo' \
 'python-docx' \
 'python-pptx' && \
# 'tika' && \
# https://anaconda.org/conda-forge/tika
# 'openpyxl' && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# JupyterLab extensions requires nodejs; see https://jupyterlab.readthedocs.io/en/stable/user/extensions.html
RUN conda install -c conda-forge nodejs

# https://github.com/jupyterlab/jupyterlab-toc
RUN jupyter labextension install @jupyterlab/toc
# https://github.com/vidartf/jupyterlab_discovery
#    jupyter serverextension enable jupyterlab_discovery

#    'weasyprint' \
#https://anaconda.org/jlmenut/weasyprint


#    'pycallgraph' \
#UnsatisfiableError: The following specifications were found to be in conflict: jupyterlab=0.34.12 and  pycallgraph
#https://anaconda.org/qinves/pycallgraph



USER $NB_UID
