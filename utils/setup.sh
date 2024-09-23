#!/bin/bash

# create an environment to cache some packages used in the course
mamba create -n btf iqtree==2.3.3 mafft==7.525 treetime==0.11.3 multiqc==1.21 gtdbtk==2.4.0

# create nextflow environment
mamba create -n nextflow bioconda::nextflow==24.04.4 bioconda::nf-core==2.14.1


# nextflow config
mkdir -p /home/participant/.nextflow 
echo "\
params { \
  max_memory = '20.GB' \
  max_cpus = '8' \
  max_time = '12.h' \
} \
singularity { \
  singularity.enabled = true \
  conda.enabled = false \
  docker.enabled = false \
  pullTimeout = '4 h' \
  cacheDir = '/home/participant/.nextflow-singularity-cache/' \
}" >> /home/participant/.nextflow/config


# cache nextflow images
mamba activate nextflow

export NXF_SINGULARITY_CACHEDIR="$HOME/.temp-nextflow-singularity-cache"

# cache singularity images and pull workflows
for wf in demo rnaseq chipseq viralrecon sarek
do
  # grab latest version of the workflow
  version=$(nf-core list | grep " $wf " | awk -F'│' '{print $4}' | sed 's/ //g' 2> /dev/null)

  # download images
  nf-core download $wf \
    --revision $version \
    --outdir /tmp/$wf \
    --force \
    --compress none \
    --download-configuration \
    --container-system singularity \
    --container-cache-utilisation amend
  
  # remove temporary dir
  rm -r /tmp/$wf 
  
  # pull the workflow to its standard directory
  nextflow pull -r $version nf-core/$wf
done