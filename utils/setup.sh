#!/bin/bash

# This script sets the software environment for the course.
# The directories to be sync'ed across training machines are:
# ~/.nextflow-singularity-cache/
# ~/.singularity
# ~/.nextflow

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/version_utils.sh"

iqtree_version=$(get_version iqtree)
mafft_version=$(get_version mafft)
treetime_version=$(get_version treetime)
multiqc_version=$(get_version multiqc)
gtdbtk_version=$(get_version gtdbtk)
fastqc_version=$(get_version fastqc)
scipy_version=$(get_version scipy)
numpy_version=$(get_version numpy)
matplotlib_version=$(get_version matplotlib)
nextflow_version=$(get_version nextflow)
nf_core_version=$(get_version nf-core)

# create an environment to cache some packages used in the course
mamba create -y -n btf \
  "iqtree==$iqtree_version" \
  "mafft==$mafft_version" \
  "treetime==$treetime_version" \
  "multiqc==$multiqc_version" \
  "gtdbtk==$gtdbtk_version" \
  "fastqc==$fastqc_version"
mamba create -y -n scipy \
  "scipy==$scipy_version" \
  "numpy==$numpy_version" \
  "matplotlib==$matplotlib_version"

# create nextflow environment
mamba create -y -n nextflow \
  "bioconda::nextflow==$nextflow_version" \
  "bioconda::nf-core==$nf_core_version"

# nextflow config
mkdir -p $HOME/.nextflow
cat <<EOF >> "$HOME/.nextflow/config"
process {
  resourceLimits = [
    cpus: 8,
    memory: 20.GB,
    time: 12.h
  ]
}
singularity {
  pullTimeout = '4 h'
  cacheDir = '${HOME}/.nextflow-singularity-cache/'
}
EOF

# cache nextflow images
export NXF_SINGULARITY_CACHEDIR="$HOME/.nextflow-singularity-cache"
export NXF_SYNTAX_PARSER=v1

# cache singularity images and pull workflows
for wf in demo rnaseq chipseq viralrecon
do
  version=$(get_version "$wf")

  # download images
  mamba run -n nextflow nf-core pipelines download "$wf" \
    --revision "$version" \
    --outdir "/tmp/$wf" \
    --force \
    --compress none \
    --download-configuration yes \
    --container-system singularity \
    --container-cache-utilisation amend

  # remove temporary dir
  rm -r "/tmp/$wf"

  # pull the workflow to its standard directory
  mamba run -n nextflow nextflow pull -r "$version" "nf-core/$wf"
done

# Export nextflow env variables
cat <<EOF >> $HOME/.bashrc
export NXF_SINGULARITY_CACHEDIR='${HOME}/.nextflow-singularity-cache'
export NXF_SYNTAX_PARSER=v1
EOF

# Test script
# mamba run -n nextflow bash "$script_dir/test_setup.sh"