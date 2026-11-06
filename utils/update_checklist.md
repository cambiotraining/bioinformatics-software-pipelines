# Checklist for updating materials

## Version manifest

All pinned workflow and software versions are defined in `_variables.yml`.
Update this file when preparing a new course release.
The setup scripts, pipeline tests, and versioned material shortcodes read their versions from this manifest.

Check the latest versions of [Nextflow](https://anaconda.org/bioconda/nextflow) and [nf-core tools](https://anaconda.org/channels/bioconda/packages/nf-core/overview) before updating their manifest entries.

## Workflow versions

Check for suitable new nf-core workflow releases before updating their manifest entries.
The following command is a discovery aid only; `setup.sh` uses the revisions pinned in `_variables.yml`, rather than the latest available versions:

```bash
for wf in demo rnaseq chipseq viralrecon
do
  # grab latest version of the workflow
  version=$(nf-core pipelines list 2> /dev/null | grep " $wf " | awk -F'│' '{print $4}' | sed 's/ //g' 2> /dev/null)
  echo "$wf: $version"
done
```

## Mamba

Check the pinned Mamba packages are still appropriate for the course.
Some values intentionally demonstrate dependency conflicts, so do not update a version merely because a newer release is available.

## Participant scripts

Update the following files on dropbox to use the versions in `_variables.yml` (needs to be done manually at this stage):

- `demo/scripts/01-run_nfcore_demo.sh`
- `demo/envs/phylo.yml`
