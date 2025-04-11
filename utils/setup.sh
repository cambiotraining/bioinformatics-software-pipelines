#!/bin/bash

# This script sets the software environment for the course.
# The directories to be sync'ed across training machines are:
# ~/.nextflow-singularity-cache/
# ~/.singularity
# ~/.nextflow

# create an environment to cache some packages used in the course
mamba create -n btf iqtree==2.3.3 mafft==7.525 treetime==0.11.3 multiqc==1.21 gtdbtk==2.4.0 fastqc==0.12.1
mamba create -y -n scipy scipy==1.12.0 numpy==1.26.4 matplotlib==3.8.3

# create nextflow environment
mamba create -n nextflow bioconda::nextflow==24.04.4 bioconda::nf-core==3.2.0


# nextflow config
mkdir -p /home/participant/.nextflow 
cat <<EOF >> /home/participant/.nextflow/config
process {
  resourceLimits = [
    cpus: 8,
    memory: 20.GB,
    time: 12.h
  ]
}
singularity { 
  singularity.enabled = true 
  conda.enabled = false 
  docker.enabled = false 
  pullTimeout = '4 h' 
  cacheDir = '/home/participant/.nextflow-singularity-cache/' 
}
EOF

# cache nextflow images
mamba activate nextflow

export NXF_SINGULARITY_CACHEDIR="$HOME/.nextflow-singularity-cache"

# cache singularity images and pull workflows
for wf in demo rnaseq chipseq viralrecon
do
  # grab latest version of the workflow
  version=$(nf-core pipelines list 2> /dev/null | grep " $wf " | awk -F'│' '{print $4}' | sed 's/ //g' 2> /dev/null)
  echo "$wf: $version"

  # download images
  nf-core pipelines download $wf \
    --revision $version \
    --outdir /tmp/$wf \
    --force \
    --compress none \
    --download-configuration yes \
    --container-system singularity \
    --container-cache-utilisation amend
  
  # remove temporary dir
  rm -r /tmp/$wf 
  
  # pull the workflow to its standard directory
  nextflow pull -r $version nf-core/$wf
done