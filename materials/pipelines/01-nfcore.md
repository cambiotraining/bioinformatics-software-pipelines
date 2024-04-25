---
pagetitle: "Bioinfo Pro"
---

# Automated Workflows

General introduction to Workflow Management systems (Nextflow, Snakemake, others?) and then specifically focus on nf-core pipelines. 

- what are workflows management systems and why would I want to use them?
- what are some of the main documented workflows available?
- how to use nf-core pipelines?
- how to configure nextflow to use software package managers?

## Overview

Bioinformatic analyses always involve multiple steps where data is gathered, cleaned and integrated to give a final set of processed files of interest to the user. 
These sequences of steps are called a **workflow** or **pipeline**. 
As analyses become more complex, pipelines may include the use of many different software tools, each requiring a specific set of inputs and options to be defined. 
Furthermore, as we want to chain multiple tools together, the inputs of one tool may be the output of another, which can become challenging to manage. 

Although it is possible to code such workflows using _shell_ scripts, these often don't scale well across different users and compute setups. 
To overcome these limitations, dedicated [_workflow/pipeline management software_](https://en.wikipedia.org/wiki/Workflow_management_system) packages have been developed to help standardise pipelines and make it easier for the user to process their data. 

Two of the most popular _workflow software_ packages are [_Snakemake_](https://snakemake.readthedocs.io/en/stable/) and [_Nextflow_](https://www.nextflow.io/). 
We will not cover how to develop workflows with these packages, but rather how to use existing workflows developed by the community.

### Why Use a Standardised Workflow? {.unlisted .unnumbered}

These are some of the key advantages of using a standardised workflow for our analysis:

- **Fewer errors** - because the workflow automates the process of managing input/output files, there are less chances for errors or bugs in the code to occur.
- **Consistency and reproducibility** - analysis ran by different people should result in the same output, regardless of their computational setup.
- **Software installation** - all software dependencies are automatically installed for the user using solutions such as _Conda_, _Docker_ and _Singularity_ (more about these in a later section of the course).
- **Scalability** - workflows can run on a local desktop or scale up to run on _high performance compute clusters_.
- **Checkpoint and resume** - if a workflow fails in one of the tasks, it can be resumed at a later time.


## Common options

The command `nextflow run` has some useful options: 

- `-profile`: defines which configuration profile(s) to use.
- `-resume`: restarts the pipeline where it last stopped (using cached results).
- `-work-dir`: defines the directory where intermediate result files (cache) are stored.

We detail each of these below. 

### Configuration profile

There are several ways to **configure how our Nextflow workflow runs**. 
All nf-core workflows come with some default profiles that we can choose from:

- `singularity` uses _Singularity_ images for software management. This is the recommended (including on HPC systems).
- `docker` uses _Docker_ images for software management. 
- `mamba` uses _Mamba_ for software management. This is not recommended as it is known to be slow and buggy. 

More details about these in the [nf-core documentation](https://nf-co.re/docs/usage/configuration). 

To use one of these profiles we use the option `-profile` followed by the name of the configuration profile we wish to use. 
For example, `-profile singularity` will use _Singularity_ to manage and run the software. 

Sometimes you may want to use custom profiles or the pipeline you are using is not from the nf-core community. 
In that case, you can define your own profile. 
The easiest may be to look at one of the [nf-core configuration files](https://github.com/nf-core/rnaseq/blob/3.14.0/nextflow.config) and set your own based on that. 
For example, to set a profile for _Singularity_, we create a file with the following: 

```conf
profiles {
  singularity {
    singularity.enabled    = true
  }
}
```

Let's say we saved this file as `nextflow.config`.
We can then use this profile by running our pipeline with the options `-profile singularity -c my_config`.


## Cache directory

The `-work-dir` option can be used to define where Nextflow stores intermediate files as it runs the pipeline. 
The storage of these intermediate files allows the pipeline to resume the pipeline from a previous state, in case it ran with errors and failed half-way through. 

The default directory is called `work` and you will see it being created in the directory where you run the pipelne from, if you run it with default options. 
This default directory is fine, but you may sometimes want to define a different directory.
For example, if you coincidentally already have a directory called "work" in your project, or if you want to use a separate storage partition to save the intermediate files.

Regardless, it is important to remember that your final results are not stored in the work directory. 
They are saved to the output directory of your pipeline. 
Therefore, after successfully finishing your pipeline you can safely **remove the work directory**. 
This is important to save disk space and you should make sure to do it regularly. 


## Checkpoint-and-resume

Because Nextflow is keeping track of all the intermediate files it generates, it can re-run the pipeline from a previous step, if it failed half-way through. 
This is an extremely useful feature of workflow management systems and it can save a lot of compute time, in case a pipeline failed (for whichever reason). 

All you have to do is use the option `-resume` when launching the pipeline and it will always resume where it left off. 
Note that, if you remove the work cache directory (as detailed above), then the pipeline will have to start from the beginning, as it doesn't have any intermediate files saved to resume from. 


## Samplesheet

Most nf-core pipelines use a CSV file as their main input file. 
These CSV file is often referred to as the "sampleshet", as it contains information about each sample to be processed. 

Although there is no universal format for this CSV file, most pipelines accept at least 3 columns: 

- `sample`: a name for the sample, which can be anything of our choice.
- `fastq_1`: the path to the respective read 1 FASTQ file.
- `fastq_2`: the path to the respective read 2 FASTQ file. This value is optional and, if missing it is assumed the sample is from single-end sequencing. 

These are only the most basic columns, however many other columns are often accepted, depending on the specific pipeline being used. 
The details for the input CSV samplesheet are usually given in the "Usage" tab of the documentation. 

As FASTQ files are often named using very long identifiers, it's a good idea to use some command line tricks to save typing and avoid typos. 
For example, we can create a first version of our file by listing all read 1 files and saving it into a file: 

```bash
ls reads/*_R1.fq.gz > samplesheet.csv
```

This will give us a good start to create the samplesheet. 
We can then open this file in a spreadsheet software such as _Excel_ and create the remaining columns. 
We can copy-paste the file paths and use the "find and replace" feature to replace "R1" with "R2". 
This way we save a lot of time of typing but also reduce the risk of having typos in our file paths. 




## Exercises

:::{.callout-exercise}

- Create samplesheet
- Run pipeline using a default profile

:::
