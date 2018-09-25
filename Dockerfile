# Jupyter Notebook server running in a Docker container on ARM. Includes both Python 2 and 3 kernels.
#
# Author: Vlad Marica
# Date 09/15/2019

FROM arm32v7/debian:stretch-slim

# Set the variables
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root

USER root

ENV NB_UID appuser
ENV NB_GID appuser

RUN groupadd -g 999 $NB_GID && \
    useradd -r -u 999 -g $NB_GID $NB_UID

ADD fix-permissions /usr/local/bin/fix-permissions

# Install both Python 2 and 3
RUN apt-get update && apt-get upgrade && apt-get install -y python-dev python-pip python3-dev python3-pip

RUN apt-get install -y ca-certificates libncurses5-dev

RUN mkdir /home/$NB_UID && fix-permissions /root && fix-permissions /home/$NB_UID
RUN pip3 install --upgrade pip
RUN pip2 install --upgrade pip
RUN pip3 install readline jupyter

# Install Python 2 kernel
RUN pip2 install ipykernel
RUN python2 -m ipykernel install

# Configure jupyter
RUN mkdir notebook

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /root/tini

VOLUME /root/notebooks
RUN chmod +x /root/tini && fix-permissions /root && fix-permissions /home/appuser

ENTRYPOINT ["/root/tini", "--"]

EXPOSE 8888

CMD ["jupyter", "notebook"]

USER $NB_UID

