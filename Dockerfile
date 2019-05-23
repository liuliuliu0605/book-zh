FROM ubuntu:16.04

# install python and conda
RUN sed -i s/archive.ubuntu.com/mirrors.163.com/g /etc/apt/sources.list
RUN apt-get update && apt-get install -y python3 git wget bzip2 build-essential texlive-full librsvg2-bin
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     bash Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH /root/miniconda3/bin:$PATH

# install venv enviroment for coding
RUN mkdir /root/.pip
COPY pip.conf /root/.pip/
COPY environment.yml /
RUN conda env create -f environment.yml

# source activate need bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# setup notedown for running code
RUN source activate venv && \
    pip install https://github.com/mli/notedown/tarball/master && \
    mkdir notebook && \
    jupyter notebook --allow-root --generate-config && \
    echo "c.NotebookApp.contents_manager_class = 'notedown.NotedownContentsManager'" >>~/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

# copy notebooks
RUN  mkdir /book-zh
COPY / /book-zh/


# install fonts
RUN cd /book-zh/build/fonts && \
    unzip SourceHanSansSC.zip && \
    unzip SourceHanSerifSC_EL-M.zip && \
    unzip SourceHanSerifSC_SB-H.zip && \
    unzip source-serif-pro -d source-serif-pro && \
    unzip source-sans-pro -d source-sans-pro && \
    unzip source-code-pro -d source-code-pro && \
    mkdir -p /usr/share/fonts/opentype && \
    mv SourceHanSansSC SourceHanSerifSC_EL-M SourceHanSerifSC_SB-H /usr/share/fonts/opentype/ && \
    mv source-serif-pro source-sans-pro source-code-pro /usr/share/fonts/opentype/ && \
    fc-cache -f -v

# conda env for make pdf/html
RUN conda env update -f /book-zh/build/env.yml

# for chinese supports
ENV LANG C.UTF-8

CMD source activate venv && cd /book-zh && \
    jupyter notebook --ip=0.0.0.0 --allow-root
