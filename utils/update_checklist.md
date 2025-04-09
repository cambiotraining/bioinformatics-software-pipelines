# Checklist for updating materials

## Nextflow version

Check the latest versions of [Nextflow](https://anaconda.org/bioconda/nextflow) and [nf-core tools](https://anaconda.org/search?q=nf-core) are being installed with the `utils/setup.sh` script. 


## Workflow versions

Check the latest versions of the nf-core workflows are being used in the materials and setup scripts.
The latest version of the workflows can be checked using nf-core tools: 

```bash
for wf in demo rnaseq chipseq viralrecon
do
  # grab latest version of the workflow
  version=$(nf-core pipelines list 2> /dev/null | grep " $wf " | awk -F'│' '{print $4}' | sed 's/ //g' 2> /dev/null)
  echo "$wf: $version"
done
```

The files to update are:

- `utils/setup.sh` script to setup training machines
- `_variables.yml` containing variables used in the markdowns
- `utils/test_nfcore.sh` script to test pipelines


## Mamba

Check that the mamba software versions used in the `utils/setup.sh` script match those in the materials. 