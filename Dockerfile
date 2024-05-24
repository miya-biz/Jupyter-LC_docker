FROM jupyter/scipy-notebook:latest
MAINTAINER https://github.com/NII-cloud-operation

USER root
# Install tools and fonts
RUN apt-get update && apt-get install -yq --no-install-recommends \
    git \
    vim \
    jed \
    emacs \
    unzip \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-plain-generic \
    libxrender1 \
    inkscape \
    wget \
    curl \
    fonts-ipafont-gothic fonts-ipafont-mincho \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy config files
ADD conf /tmp/
RUN mkdir -p $CONDA_DIR/etc/jupyter && \
    cp -f /tmp/jupyter_notebook_config.py \
       $CONDA_DIR/etc/jupyter/jupyter_notebook_config.py

SHELL ["/bin/bash", "-c"]

### ansible
RUN apt-get update && \
    apt-get -y install sshpass openssl ipmitool libssl-dev libffi-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    conda install --quiet --yes requests paramiko && \
    conda clean --all -f -y
#    conda install --quiet --yes requests paramiko ansible &&

### Utilities
RUN apt-get update && apt-get install -y virtinst dnsutils zip tree jq rsync iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    conda install --quiet --yes papermill && \
    pip --no-cache-dir install netaddr pyapi-gitlab runipy pysnmp pysnmp-mibs && \
    conda clean --all -f -y

### Add files
RUN mkdir -p /etc/ansible && cp /tmp/ansible.cfg /etc/ansible/ansible.cfg

#### Visualization
RUN pip --no-cache-dir install folium

### extensions for jupyter
#### jupyter_nbextensions_configurator
#### jupyter_contrib_nbextensions
#### Jupyter-LC_nblineage (NII) - https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
#### Jupyter-LC_through (NII) - https://github.com/NII-cloud-operation/Jupyter-LC_run_through
#### Jupyter-LC_wrapper (NII) - https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
#### Jupyter-multi_outputs (NII) - https://github.com/NII-cloud-operation/Jupyter-multi_outputs
#### Jupyter-LC_index (NII) - https://github.com/NII-cloud-operation/Jupyter-LC_index
ENV nblineage_release_tag=0.2.0.rc1 \
    nblineage_release_url=https://github.com/NII-cloud-operation/Jupyter-LC_nblineage/releases/download/ \
    lc_index_release_tag=0.2.0.rc3 \
    lc_index_release_url=https://github.com/NII-cloud-operation/Jupyter-LC_index/releases/download/ \
    lc_multi_outputs_release_tag=2.2.0.rc2 \
    lc_multi_outputs_release_url=https://github.com/NII-cloud-operation/Jupyter-multi_outputs/releases/download/ \
    lc_run_through_release_tag=0.2.0.rc1 \
    lc_run_through_release_url=https://github.com/NII-cloud-operation/Jupyter-LC_run_through/releases/download/ \
    diff_release_tag=0.2.0.rc1 \
    diff_release_url=https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff/releases/download/ \
    sidestickies_release_tag=0.3.0.rc4 \
    sidestickies_release_url=https://github.com/NII-cloud-operation/sidestickies/releases/download/ \
    nbsearch_release_tag=0.2.0.rc2 \
    nbsearch_release_url=https://github.com/NII-cloud-operation/nbsearch/releases/download/
RUN pip --no-cache-dir install jupyter_nbextensions_configurator && \
    pip --no-cache-dir install six bash_kernel \
    #https://github.com/NII-cloud-operation/jupyter_contrib_nbextensions/tarball/master \
    ${nblineage_release_url}${nblineage_release_tag}/nblineage-${nblineage_release_tag}.tar.gz \
    ${lc_run_through_release_url}${lc_run_through_release_tag}/lc_run_through-${lc_run_through_release_tag}.tar.gz \
    https://github.com/NII-cloud-operation/Jupyter-LC_wrapper/tarball/master \
    ${lc_multi_outputs_release_url}${lc_multi_outputs_release_tag}/lc_multi_outputs-${lc_multi_outputs_release_tag}.tar.gz \
    ${lc_index_release_url}${lc_index_release_tag}/lc_index-${lc_index_release_tag}.tar.gz \
    ${diff_release_url}${diff_release_tag}/lc_notebook_diff-${diff_release_tag}.tar.gz \
    ${sidestickies_release_url}${sidestickies_release_tag}/sidestickies-${sidestickies_release_tag}.tar.gz \
    ${nbsearch_release_url}${nbsearch_release_tag}/nbsearch-${nbsearch_release_tag}.tar.gz
    #git+https://github.com/NII-cloud-operation/nbwhisper.git

RUN jupyter labextension install ${nblineage_release_url}${nblineage_release_tag}/nblineage-${nblineage_release_tag}.tgz && \
    jupyter labextension enable nblineage && \
    #jupyter contrib nbextension install --sys-prefix && \
    #jupyter server extension enable --py nblineage --sys-prefix && \
    jupyter nblineage quick-setup --sys-prefix && \
    jupyter labextension install ${lc_run_through_release_url}${lc_run_through_release_tag}/lc_run_through-${lc_run_through_release_tag}.tgz && \
    jupyter labextension enable lc_run_through && \
    jupyter nbclassic-extension install --py lc_run_through --sys-prefix && \
    jupyter nbclassic-extension enable --py lc_run_through --sys-prefix && \
    jupyter labextension install ${lc_multi_outputs_release_url}${lc_multi_outputs_release_tag}/lc_multi_outputs-${lc_multi_outputs_release_tag}.tgz && \
    jupyter labextension enable lc_multi_outputs && \
    jupyter nbclassic-extension install --py lc_multi_outputs --sys-prefix && \
    jupyter nbclassic-extension enable --py lc_multi_outputs --sys-prefix && \
    jupyter labextension install ${lc_index_release_url}${lc_index_release_tag}/lc_index-${lc_index_release_tag}.tgz && \
    jupyter labextension enable lc_index && \
    jupyter nbclassic-extension install --py lc_index --sys-prefix && \
    jupyter nbclassic-extension enable --py lc_index --sys-prefix && \
    jupyter nbclassic-extension install --py lc_wrapper --sys-prefix && \
    jupyter nbclassic-extension enable --py lc_wrapper --sys-prefix && \
    jupyter nbclassic-extension install --py lc_notebook_diff --sys-prefix && \
    jupyter nbclassic-extension enable --py lc_notebook_diff --sys-prefix && \
    jupyter labextension install ${diff_release_url}${diff_release_tag}/lc_notebook_diff-${diff_release_tag}.tgz && \
    jupyter labextension enable lc_notebook_diff && \
    jupyter labextension install ${sidestickies_release_url}${sidestickies_release_tag}/sidestickies-${sidestickies_release_tag}.tgz && \
    jupyter labextension disable sidestickies && \
    jupyter nbclassic-extension install --py nbtags --sys-prefix && \
    jupyter nbclassic-serverextension enable --py nbtags --sys-prefix && \
    jupyter labextension install ${nbsearch_release_url}${nbsearch_release_tag}/nbsearch-${nbsearch_release_tag}.tgz && \
    jupyter nbclassic-extension install --py nbsearch --sys-prefix && \
    jupyter nbclassic-serverextension enable --py nbsearch --sys-prefix && \
    jupyter labextension disable nbsearch && \
    # jupyter nbclassic-extension install --py nbwhisper --sys-prefix && \
    # jupyter nbclassic-serverextension enable --py nbwhisper --sys-prefix && \
    jupyter nbclassic-extension install --py jupyter_nbextensions_configurator --sys-prefix && \
    jupyter nbclassic-extension enable --py jupyter_nbextensions_configurator --sys-prefix && \
    jupyter nbclassic-serverextension enable --py jupyter_nbextensions_configurator --sys-prefix && \
    # jupyter nbclassic-extension enable contrib_nbextensions_help_item/main --sys-prefix && \
    jupyter nbclassic-extension enable collapsible_headings/main --sys-prefix && \
    jupyter nbclassic-extension enable toc2/main --sys-prefix && \
    # jlpm cache clean && \
    # npm cache clean --force && \
    fix-permissions /home/$NB_USER

    # To enable the nbsearch or sidestickies, you need to run the following command in the notebook.
    # jupyter labextension enable nbtags
    # jupyter labextension enable nbsearch

### kernels
RUN chmod +x /tmp/wrapper-kernels/prepare-icons.sh && \
    /tmp/wrapper-kernels/prepare-icons.sh && \
    python -m bash_kernel.install --sys-prefix && \
    jupyter kernelspec install /tmp/kernels/python3-wrapper --sys-prefix && \
    jupyter kernelspec install /tmp/kernels/bash-wrapper --sys-prefix && \
    jupyter wrapper-kernelspec install /tmp/wrapper-kernels/python3 --sys-prefix && \
    jupyter wrapper-kernelspec install /tmp/wrapper-kernels/bash --sys-prefix && \
    fix-permissions /home/$NB_USER

### nbconfig
RUN mkdir -p $CONDA_DIR/etc/jupyter/nbconfig/notebook.d && \
    cp /tmp/nbextension-config.json $CONDA_DIR/etc/jupyter/nbconfig/notebook.d/nbextension-config.json

### notebooks dir
ADD sample-notebooks /home/$NB_USER
RUN fix-permissions /home/$NB_USER

### Bash Strict Mode
RUN cp /tmp/bash_env /etc/bash_env

### Theme for jupyter
RUN CUSTOM_DIR=$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')/nbclassic/static/custom && \
    cat /tmp/custom.css >> $CUSTOM_DIR/custom.css && \
    cp /tmp/logo.png $CUSTOM_DIR/logo.png && \
    mkdir -p $CUSTOM_DIR/codemirror/addon/merge/ && \
    curl -fL https://raw.githubusercontent.com/cytoscape/cytoscape.js/master/dist/cytoscape.min.js > $CUSTOM_DIR/cytoscape.min.js && \
    curl -fL https://raw.githubusercontent.com/iVis-at-Bilkent/cytoscape.js-view-utilities/master/cytoscape-view-utilities.js > $CUSTOM_DIR/cytoscape-view-utilities.js && \
    curl -fL https://raw.githubusercontent.com/NII-cloud-operation/Jupyter-LC_notebook_diff/master/html/jupyter-notebook-diff.js > $CUSTOM_DIR/jupyter-notebook-diff.js && \
    curl -fL https://raw.githubusercontent.com/NII-cloud-operation/Jupyter-LC_notebook_diff/master/html/jupyter-notebook-diff.css > $CUSTOM_DIR/jupyter-notebook-diff.css && \
    curl -fL https://cdnjs.cloudflare.com/ajax/libs/diff_match_patch/20121119/diff_match_patch.js > $CUSTOM_DIR/diff_match_patch.js && \
    curl -fL https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.35.0/addon/merge/merge.js > $CUSTOM_DIR/codemirror/addon/merge/merge.js && \
    curl -fL https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.35.0/addon/merge/merge.min.css > $CUSTOM_DIR/merge.min.css

### Custom get_ipython().system() to control error propagation of shell commands
RUN mkdir -p $CONDA_DIR/etc/ipython/startup/ && \
    cp /tmp/ipython_config.py $CONDA_DIR/etc/ipython/ && \
    cp /tmp/10-custom-get_ipython_system.py $CONDA_DIR/etc/ipython/startup/

### Add run-hooks
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/ssh-agent.sh /usr/local/bin/before-notebook.d/

### Install lsyncd for nbsearch
RUN apt-get update && apt-get install -yq lsyncd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/nbsearch \
    && cp /tmp/nbsearch/launch.sh /usr/local/bin/before-notebook.d/nbsearch-launch.sh \
    && cp /tmp/nbsearch/update-index* /opt/nbsearch/ \
    && chmod +x /usr/local/bin/before-notebook.d/nbsearch-launch.sh /opt/nbsearch/update-index

# Make classic notebook the default
#ENV DOCKER_STACKS_JUPYTER_CMD=nbclassic

USER $NB_USER
