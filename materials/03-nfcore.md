---
pagetitle: "Software & Pipelines"
---

# Automated Workflows

::: callout-tip
#### Learning objectives

- Describe how workflow management systems (WfMS) work and their advantages in complex analysis pipelines.
- List some of the most popular WfMS used in the field of bioinformatics.
- Recognise the main configuration aspects needed to run a Nextflow pipeline: configuration profiles, cache, resumability, samplesheets.
- Apply a standard Nextflow pipelines developed by the nf-core community to a set of sequencing data.
:::

## Overview

Bioinformatic analyses always involve multiple steps where data is gathered, cleaned and integrated to give a final set of processed files of interest to the user. 
These sequences of steps are called a **workflow** or **pipeline**. 
As analyses become more complex, pipelines may include the use of many different software tools, each requiring a specific set of inputs and options to be defined. 
Furthermore, as we want to chain multiple tools together, the inputs of one tool may be the output of another, which can become challenging to manage. 

Although it is possible to code such workflows using _shell_ scripts, these often don't scale well across different users and compute setups. 
To overcome these limitations, dedicated [_workflow/pipeline management software_](https://en.wikipedia.org/wiki/Bioinformatics_workflow_management_system) packages have been developed to help standardise pipelines and make it easier for the user to process their data. 
These dedicated packages are designed to streamline and automate the process of coordinating complex sequences of tasks and data processing (for instance an RNA-seq analysis).
In this way, researchers can focus on their scientific questions instead of the nitty-gritty of data processing.

![A) Workflow illustration, showing ready-for-running tasks highlighted in green, indicating all necessary input files are available. The initial red task produces a temporary file, potentially removable once the blue tasks complete. Workflow management systems ensure tasks are run in an optimal and automated manner. For example, in B) there is suboptimal scheduling of tasks, as only one blue task is scheduled the temporary file cannot be removed. Conversely, in C) we have optimal scheduling, since the three blue tasks are scheduled first enabling deletion of the temporary file after their completion. Diagram taken from [Mölder et al. 2021](https://doi.org/10.12688/f1000research.29032.2).](https://f1000research.s3.amazonaws.com/manuscripts/56004/3c3b99f9-b002-4f62-b11c-18cca6cf9ed4_figure4.gif)

Here are some of the key advantages of using a standardised workflow for our analysis:

- **Fewer errors** - because the workflow automates the process of managing input/output files, there are less chances for errors or bugs in the code to occur.
- **Consistency and reproducibility** - analysis ran by different people should result in the same output, regardless of their computational setup.
- **Software installation** - all software dependencies are automatically installed for the user using solutions such as Conda, _Docker_ and _Singularity_ (more about these in a later section of the course).
- **Scalability** - workflows can run on a local desktop or scale up to run on _high performance compute clusters_.
- **Checkpoint and resume** - if a workflow fails in one of the tasks, it can be resumed at a later time.


## Nextflow and Snakemake

Two of the most popular _workflow software_ packages are [_Snakemake_](https://snakemake.readthedocs.io/en/stable/) and [_Nextflow_](https://www.nextflow.io/). 
We will not cover how to develop workflows with these packages, but rather **how to use existing workflows developed by the community**.[^1]
Both Snakemake and Nextflow offer similar functionality and can work on different computer systems, from personal laptops to large cloud-based platforms, making them very versatile.
One of the main noticeable difference to those developing pipelines with these tools is that Snakemake syntax is based on [Python](https://www.python.org/), whereas Nextflow is based on [groovy](https://groovy-lang.org/).
The choice between one of the other is really down to individual preference. 

<!-- footnote -->
[^1]: To learn how to build your own pipelines, there are many tutorials available on [training.nextflow.io](https://training.nextflow.io/), including [how to build a simple RNA-Seq workflow](https://training.nextflow.io/basic_training/rnaseq_pipeline/). _Snakemake_ also provides an [excellent tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html) covering both basic and advanced features to build custom pipelines.

Another important aspect of these projects are the workflows and modules provided by the community: 

- [nf-core](https://nf-co.re/): a community project where scientists contribute ready-to-use, high-quality analysis pipelines. This means you don’t have to start from scratch if someone else has already created a workflow for a similar analysis. It’s all about making data analysis more accessible, standardized, and reproducible across the globe​​​​.
- [Snakemake workflow catalog](https://snakemake.github.io/snakemake-workflow-catalog/): a searcheable catalog of workflows developed by the community, with instructions and details on how to use them. Although there is some standardisation of these pipelines, they are not as well curated as the ones from nf-core. 

These materials will focus on Nextflow, due to the standarised and ready-to-use pipelines available through nf-core.


## Nextflow command line interface:

Nextflow has an array of subcommands for the command line interface to manage and execute pipelines. To see all options you can simply run `nextflow -h` and a list of available top-level options will appear in your terminal'. here we highlight the three we will be using:

- `nextflow run [options] [pipeline]`: will execute a nextflow pipeline
- `nextflow log`: will print the execution history and log information of a pipeline
- `nextflow clean`: will clen up **cache** and **work** directories. 

The command `nextflow run` has some useful options: 

- `-profile`: defines which configuration profile(s) to use.
- `-resume`: restarts the pipeline where it last stopped (using cached results).
- `-work-dir`: defines the directory where intermediate result files (cache) are stored.

We detail each of these below. 


## Configuration profile

There are several ways to **configure how our Nextflow workflow runs**. 
All nf-core workflows come with some default profiles that we can choose from:

- `singularity` uses _Singularity_ images for software management. This is the recommended (including on HPC systems).
- `docker` uses _Docker_ images for software management. 
- `mamba` uses Mamba for software management. This is not recommended as it is known to be slow and buggy. 

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
We can then use this profile by running our pipeline with the options `-profile singularity -c nextflow.config`. 
You can also specify more than one configuration file in your command as `-c myconfig1 -c myconfig2`.


## Cache directory

When a Nextflow pipeline runs it creates (by default) a `work` directory when you execute the pipeline for the first time. 
The `work` directory stores a variety of intermediate files used during the pipeline run, called a **cache**. 
The storage of these intermediate files is very important, as it allows the pipeline to resume from a previous state, in case it ran with errors and failed half-way through (more on this below).

Each task from the pipeline (e.g. a bash command can be considered a task) will have a unique directory name within `work`. 
When a task is created, Nextflow stages the task input files, script, and other helper files into the task directory. 
The task writes any output files to this directory during its execution, and Nextflow uses these output files for downstream tasks and/or publishing. 
Publishing is when the output of a task is being saved to the output directory specified by the user. 

The `-work-dir` option can be used to change the name of the cache directory from the default `work`. 
This default directory name is fine (and most people just use that), but you may sometimes want to define a different one.
For example, if you coincidentally already have a directory called "work" in your project, or if you want to use a separate storage partition to save the intermediate files.

Regardless, it is important to remember that your final results are not stored in the work directory. 
They are saved to the output directory you define when you run the pipeline. 
Therefore, after successfully finishing your pipeline you can safely **remove the work directory**. 
This is important to save disk space and you should make sure to do it regularly. 


## Checkpoint-and-resume

Because Nextflow is keeping track of all the intermediate files it generates, it can re-run the pipeline from a previous step, if it failed half-way through. 
This is an extremely useful feature of workflow management systems and it can save a lot of compute time, in case a pipeline failed. 

All you have to do is use the option `-resume` when launching the pipeline and it will always resume where it left off. 
Note that, if you remove the work cache directory detailed above, then the pipeline will have to start from the beginning, as it doesn't have any intermediate files saved to resume from. 

More information about this feature can be found in the [Nextflow documentation](https://www.nextflow.io/docs/latest/cache-and-resume.html).


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


## Demo nf-core pipeline

TODO: add description

![](https://raw.githubusercontent.com/nf-core/demo/dev//docs/images/nf-core-demo-subway.png)

```bash
nextflow run -profile "singularity" -revision "dev" nf-core/demo \
  --input "samplesheet.csv" \
  --outdir "results/qc" \
  --fasta "resources/genome/something.fa.gz"
```

In this case we used the following options: 

- `-profile singularity` indicates we want to use Singularity to manage the software. Nextflow will automatically download containers for each step of the pipeline. 
- `-revision dev` means we are running the development version of the pipeline. It's a good idea to define the specific version of the pipeline you run, so you can reproduce the results in the future, in case the pipeline changes. This demo pipeline only has a development version, but usually versions are numbered (some examples will be shown in the exercises).
- `--input` is the samplesheet CSV for this pipeline. 
- `--outdir` is the name of the output directory for our results. 
- `--fasta` is the reference genome to be used by the pipeline.


## Exercises

:::{.callout-exercise}

- Create samplesheet
- Run pipeline using a default profile

:::

## Summary

::: callout-tip
#### Key points

- WfMS define, automate and monitor the execution of a series of tasks in a specific order. They improve efficiency, reduce errors, can be easily scaled (from a local computer to a HPC cluster) and increase reproducibility.
- Popular WfMS in bioinformatics include Nextflow and Snakemake. Both of these projects have associated community-maintained workflows, with excellent documentation for their use: [nf-core](https://nf-co.re/) and the [snakemake workflow catalog](https://snakemake.github.io/snakemake-workflow-catalog/).
- TODO: finish key points
:::