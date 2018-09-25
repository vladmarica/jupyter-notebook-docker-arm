# jupyter-notebook-docker-arm
Dockerfile for running Jupyter Notebook on an ARM device, especially on a Raspberry Pi.

Jupyter Notebook runs on Python 3, but a IPython 2 kernel is also included.

Example usage:
```
docker run -d -p 8888:8888 -v /home/user/documents/jupyter:/root/notebooks --name notebook \
  jupyter-notebook:latest jupyter notebook \
  --NotebookApp.open_browser=False \
  --NotebookApp.ip="0.0.0.0" \
  --NotebookApp.notebook_dir=/root/notebooks \
  --NotebookApp.base_url=/jupyter/
```
