# Jupyter Notebook server running in a Docker container on ARM. Includes both Python 2 and 3 kernels, and a dark theme.
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
RUN apt-get update && apt-get upgrade && apt-get install -y python-dev \
	python-pip \
	python3-dev \
	python3-pip \
	ca-certificates \
	libncurses5-dev \
	curl

RUN mkdir /home/$NB_UID && fix-permissions /root && fix-permissions /home/$NB_UID
RUN pip3 install --upgrade pip
RUN pip2 install --upgrade pip
RUN pip3 install readline jupyter

# Fix Python3 kernel since IPykernel 5.0.0 has dependency issues.
RUN pip3 install "ipykernel==4.10.0" --force-reinstall 

# Install the IPython 2 kernel
RUN pip2 install ipykernel && python2 -m ipykernel install

# Install Jupyter dark theme
RUN mkdir -p /home/$NB_UID/.jupyter/custom \
	&& curl https://raw.githubusercontent.com/Quintinity/jupyter-dark-theme/master/custom.css > /home/$NB_UID/.jupyter/custom/custom.css \
	&& curl https://raw.githubusercontent.com/Quintinity/jupyter-dark-theme/master/logo.png > /home/$NB_UID/.jupyter/custom/logo.png

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /root/tini

VOLUME /root/notebooks
RUN chmod +x /root/tini && fix-permissions /root && fix-permissions /home/$NB_UID

ENTRYPOINT ["/root/tini", "--"]

EXPOSE 8888

CMD ["jupyter", "notebook"]

USER $NB_UID

