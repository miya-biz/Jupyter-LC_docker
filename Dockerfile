FROM solr:8 AS solr

FROM niicloudoperation/notebook:feature-lab

USER root

# for nbsearch -->
# Install OpenJDK and lsyncd
RUN apt-get update && apt-get install -yq supervisor lsyncd uuid-runtime \
    openjdk-11-jre gnupg curl tinyproxy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Solr
COPY --from=solr /opt /opt/
RUN mkdir -p /var/solr
COPY --from=solr /var/solr /var/solr
ENV SOLR_USER="jovyan" \
    SOLR_GROUP="users" \
    PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH" \
    SOLR_INCLUDE=/etc/default/solr.in.sh \
    SOLR_HOME=/var/solr/data \
    SOLR_PID_DIR=/var/solr \
    SOLR_LOGS_DIR=/var/solr/logs \
    LOG4J_PROPS=/var/solr/log4j2.xml
RUN chown jovyan:users -R /var/solr /run/tinyproxy

# MINIO
ENV MINIO_ACCESS_KEY=nbsearchak MINIO_SECRET_KEY=nbsearchsk
RUN mkdir -p /opt/minio/bin/ && \
    curl -L https://dl.min.io/server/minio/release/linux-amd64/minio > /opt/minio/bin/minio && \
    chmod +x /opt/minio/bin/minio && mkdir -p /var/minio && chown jovyan:users -R /var/minio

RUN pip install jupyter-server-proxy && \
    jupyter server extension enable --sys-prefix jupyter_server_proxy
COPY ./nbsearch /tmp/nbsearch
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/nbsearch/example/*.sh /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/*.sh && \
    cp /tmp/nbsearch/example/update-index /usr/local/bin/ && \
    chmod +x /usr/local/bin/update-index && \
    mkdir -p /opt/nbsearch/ && \
    cp -fr /tmp/nbsearch/solr /opt/nbsearch/

# Boot scripts to perform /usr/local/bin/before-notebook.d/* on JupyterHub
RUN mkdir -p /opt/nbsearch/original/bin/ && \
    mkdir -p /opt/nbsearch/bin/ && \
    mv /opt/conda/bin/jupyterhub-singleuser /opt/nbsearch/original/bin/jupyterhub-singleuser && \
    mv /opt/conda/bin/jupyter-notebook /opt/nbsearch/original/bin/jupyter-notebook && \
    mv /opt/conda/bin/jupyter-lab /opt/nbsearch/original/bin/jupyter-lab && \
    cp /tmp/nbsearch/example/jupyterhub-singleuser /opt/conda/bin/ && \
    cp /tmp/nbsearch/example/jupyter-notebook /opt/conda/bin/ && \
    cp /tmp/nbsearch/example/jupyter-lab /opt/conda/bin/ && \
    cp /tmp/nbsearch/example/run-hook.sh /opt/nbsearch/bin/ && \
    chmod +x /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/jupyter-notebook /opt/conda/bin/jupyter-lab \
        /opt/nbsearch/bin/run-hook.sh

# Configuration for Server Proxy
RUN cat /tmp/nbsearch/example/jupyter_notebook_config.py >> $CONDA_DIR/etc/jupyter/jupyter_notebook_config.py
# <-- for nbsearch

# Tools for DEMO Notebooks
RUN pip --no-cache-dir install git+https://github.com/yacchin1205/apachelog.git@feature/python3
RUN mamba install --quiet --yes awscli passlib && mamba clean --all -f -y
RUN apt-get update && apt-get install -y expect && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm /home/$NB_USER/*.ipynb

USER $NB_USER
RUN jupyter labextension enable sidestickies --level=user && \
    jupyter nbclassic-extension enable --py --user nbtags
ENV SIDESTICKIES_SCRAPBOX_PROJECT_ID sidestickies-public

# for nbsearch -->
RUN jupyter labextension enable nbsearch --level=user && \
    mkdir -p /home/$NB_USER/.nbsearch && \
    cp /tmp/nbsearch/example/config_*.py /home/$NB_USER/.nbsearch/

RUN mkdir /home/$NB_USER/.nbsearch/conf.d && \
    cp /tmp/nbsearch/example/supervisor.conf /home/$NB_USER/.nbsearch/supervisor.conf && \
    cp /tmp/nbsearch/example/update-index.lua /home/$NB_USER/.nbsearch/update-index.lua

# Create Solr schema
RUN precreate-core jupyter-notebook /opt/nbsearch/solr/jupyter-notebook/ && \
    precreate-core jupyter-cell /opt/nbsearch/solr/jupyter-cell/

RUN jupyter nbclassic-serverextension enable --py --user nbsearch && \
    jupyter nbclassic-extension enable --py --user nbsearch && \
    jupyter nbclassic-extension enable --py --user lc_notebook_diff
# <-- for nbsearch
