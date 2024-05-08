---
pagetitle: "Bioinfo Pro"
---

# Automated Workflows

General introduction to Workflow Management systems (Nextflow, Snakemake, others?) and then specifically focus on nf-core pipelines. 

- what are workflows management systems and why would I want to use them? [~DONE to be reviewed]
- what are some of the main documented workflows available? [Snakemake and nextflow? I don't know others maybe more info on snakemake required]
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

## Nextflow and Snakemake
[Workflow management solutions](https://en.wikipedia.org/wiki/Workflow_management_system), such as [Nextflow](https://en.wikipedia.org/wiki/Nextflow), are designed to streamline and automate the process of coordinating complex sequences of tasks and data processing (for instance an RNA-seq analysis). Nextflow helps automate the process of analyzing large datasets, so researchers can focus on their scientific questions instead of the nitty-gritty of data processing. Nextflow works on different computer systems, from personal laptops to large cloud-based platforms, making it very versatile. Another relevant aspect is [nf-core](https://nf-co.re/), a community project linked to Nextflow, where scientists contribute ready-to-use, high-quality analysis pipelines. This means you don’t have to start from scratch if someone else has already created a workflow for a similar analysis. It’s all about making data analysis more accessible, standardized, and reproducible across the globe​​​​.

Alternatively to Nextflow, we also have [Snakemake](https://snakemake.readthedocs.io/en/stable/). Snakemake is another workflow management system to create reproducible and scalable research. The main difference with Nextflow is that Snakemake syntax is based on [Python](https://www.python.org/) language and Nextflow is based on [groovy](https://groovy-lang.org/) language. the choice between one of the other is really depending on the user, some people prefer Snakemake because they are familiar with Python and some other people prefer Nextflow because of its active community. In this course we will focus on Nextflow due to the well-standarised and ready-to-use pipeline available through nf-core.


### Nextflow community: nf-core

`nf-core` is a community effort to collect and maintain curated nextflow pipelines. These pipelines follow certain standards and best practices to facilitate its use in a wider community. They also provide templates and tools for developers to validate and ensure standards, these nf-core companion tool is called [`nf-tools`](https://nf-co.re/tools).


### Why Use a Standardised Workflow? {.unlisted .unnumbered}

These are some of the key advantages of using a standardised workflow for our analysis:

- **Fewer errors** - because the workflow automates the process of managing input/output files, there are less chances for errors or bugs in the code to occur.
- **Consistency and reproducibility** - analysis ran by different people should result in the same output, regardless of their computational setup.
- **Software installation** - all software dependencies are automatically installed for the user using solutions such as Conda, _Docker_ and _Singularity_ (more about these in a later section of the course).
- **Scalability** - workflows can run on a local desktop or scale up to run on _high performance compute clusters_.
- **Checkpoint and resume** - if a workflow fails in one of the tasks, it can be resumed at a later time.


## Nextflow installation
Begin by installing Nextflow ([https://www.nextflow.io/](https://www.nextflow.io/)). Ensure Java 11 or higher is installed on your system, then use the command `curl -fsSL get.nextflow.io | bash` to install Nextflow. Note: `curl` command is designed for unix-like operating systems (linux and macOS). To install Nextflow on windows please follow the steps from nextflow documentation [here](https://www.nextflow.io/blog/2021/setup-nextflow-on-windows.html) or use a unix-like terminal in your Windows.

You can familiarize yourself with Nextflow further through tutorials and documentation available at training.nextflow.io, including a practical introduction to [simple RNA-Seq workflow](https://training.nextflow.io/basic_training/rnaseq_pipeline/).

## Nextflow structure

### Work and cache
When a Nextflow pipeline runs it follows a specific structure. Within the folder you are working a `work` directory will be created when you execute the pipeline for the first time. The `work` directory stores a variety of files used during the pipeline run. Each task from the pipeline (e.g. a bash command can be considered a task) will have a unique directory name within `work`. When a task is created, Nextflow stages the task input files, script, and other helper files into the task directory. The task writes any output files to this directory during its execution, and Nextflow uses these output files for downstream tasks and/or publishing. Publishing is when the output of a task is being 'published' to the specified output directory. 

The reason for this structure is explained by understanding the `cache`. One of the core features of Nextflow is the ability to cache task executions and re-use them in subsequent runs to minimize duplicate work. Resumability is useful both for recovering from errors and for iteratively developing a pipeline. It is similar to checkpointing, a common practice used by HPC applications.

You can enable resumability in Nextflow with the `-resume` flag when launching a pipeline with `nextflow run`. All task executions are automatically saved to the task cache in the `work` directory. 

More information about this in the [Nextflow docs](https://www.nextflow.io/docs/latest/cache-and-resume.html)


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

### Configuration profile

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
We can then use this profile by running our pipeline with the options `-profile singularity -c my_config`. You can also specify more than one profile in your command as `nextflow run -profile singularity -c myconfig1 -c myconfig2`.


## Cache directory

The `-work-dir` option can be used to define where Nextflow stores intermediate files as it runs the pipeline. 
The storage of these intermediate files allows the pipeline to resume the pipeline from a previous state, in case it ran with errors and failed half-way through. 

The default directory is called `work` as mentioned before and you will see it being created in the directory where you run the pipeline from, if you run it with default options. 
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

[Note from Raquel: Sorry this bit might be redundant now because of what I added above. Do you mind revising?]


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
