# Don't upgrade nfcore/base, it creates "Kernel too old" error for singularity (because of the debian image)
FROM nfcore/base:1.7 
LABEL author="isabelsilverman" description="Docker image containing all requirements for the dolphinnext/rnaseq pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

RUN mkdir -p /export /data
ENV PATH /opt/conda/envs/isabelsilverman-rnaseqtutorial-1.0/bin:$PATH
