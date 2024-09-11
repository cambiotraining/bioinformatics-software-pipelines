---
pagetitle: "Software & Pipelines"
---

# Package Managers

:::{.callout-tip}
#### Learning objectives

- Describe the role of a package manager and list examples of package managers for different applications.
- Recognise the challenges in managing complex software environments and the role of the Conda/Mamba package manager in solving these.
- Create and use reproducible software environments using Mamba. 
- Recognise some of limitations of Mamba as a package manager and how to avoid common pitfalls. 

:::

## What is a package manager?

Most operating systems have **package managers** available, which allow the user to manage (install, remove, upgrade) their software easily. 
The package manager takes care of automatically downloading and installing the software we want, as well as any dependencies it requires.

![Diagram illustrating how package managers work. [Image from _It's FOSS_](https://itsfoss.com/package-manager/), licensed under [CC BY-SA 4.0](https://itsfoss.com/copyright/)](https://itsfoss.com/content/images/wordpress/2020/10/linux-package-manager-explanation.png)

There are many package managers available, some are specific to a given type of operating system, or specific to a programming language, while others are more generic.
Each of these package managers will use their own repositories, meaning they have access to different sets of software (although there is often some overlap). 
Some examples include: 

- `apt` is the default _Linux_ package manager for Debian-derived distributions, such as the popular Ubuntu. It comes pre-installed and can be used to install system-level applications.
- `homebrew` is a popular package manager for macOS, although it also works on Linux.
- `conda`/`mamba` is a package manager very popular in bioinformatics and data science communities, due to the repositories which give access to software used in these fields. It will be the main focus of this section.

Some programming languages also come with their own package managers.
For example: 

- The statistical software **R** has two main library repositories: [CRAN](https://cran.r-project.org/web/packages/) and [Bioconductor](https://bioconductor.org/). These are installed from within the R console using the commands `install.packages()` and `BiocManager::install()`, respectively. 
- The programming laguage **Python** has a package manager called `pip`, which has access to the Python Package Index (PyPI) repository.

In many cases package managers can also install software directly from code repositories such as GitHub, adding further flexibility to how we manage our scientific software. 


## Conda/Mamba

A popular package manager in data science, scientific computing and bioinformatics is **Mamba**, which is a successor to another package manager called Conda.

Conda was originally developed by [Anaconda](https://anaconda.org/) as a way to simplify the creation, distribution, and management of software environments containing different packages and dependencies. 
It is known for its cross-platform compatibility and relative ease of use (compared to compiling software and having the user manually install all software dependencies). 
Mamba is a more recent and high-performance alternative to Conda. 
While it maintains compatibility with Conda's package and environment management capabilities, Mamba is designed for **faster dependency resolution and installation**, making it a better choice nowadays. 
Therefore, the rest of this section focuses on Mamba specifically.

One of the strengths of using Mamba to manage your software is that you can have different versions of your software installed alongside each other, organised in **environments**. 
Organising software packages into environments is extremely useful, as it allows to have a _reproducible_ set of software versions that you can use and reuse in your projects. 

For example, imagine you are working on two projects with different software requirements:

- Project A: requires Python 3.7, NumPy 1.15, and scikit-learn 0.20.
- Project B: requires Python 3.12, the latest version of NumPy, and TensorFlow 2.0.

If you don't use environments, you would need to install and maintain these packages globally on your system. 
This can lead to several issues:

- **Version conflicts:** different projects may require different versions of the same library. For example, Project A might not be compatible with the latest NumPy, while Project B needs it.
- **Dependency chaos:** as your projects grow, you might install numerous packages, and they could interfere with each other, causing unexpected errors or instability.
- **Difficulty collaborating:** sharing your code with colleagues or collaborators becomes complex because they may have different versions of packages installed, leading to compatibility issues.

![Illustration of Conda/Mamba environments. Each environment is isolated from the others (effectively in its own folder), so different versions of the packages can be installed for distinct projects or parts of a long analysis pipeline.](images/conda_environments.png)

**Mamba allows you to create self-contained software environments for each project**, addressing these issues:

- **Isolation:** you can create a separate environment for each project. This ensures that the dependencies for one project don't affect another.
- **Software versions:** you can specify the exact versions of libraries and packages required for each project within its environment. This eliminates version conflicts and ensures reproducibility.
- **Ease of collaboration:** sharing your code and environment file makes it easy for collaborators to replicate your environment and run your project without worrying about conflicts.
- **Simplified maintenance:** if you need to update a library for one project, it won't impact others. You can manage environments separately, making maintenance more straightforward.

Another advantage of using Mamba is that the **software is installed locally** (by default in your home directory), without the need for admin (`sudo`) permissions. 

### Installing software with Mamba

You can search for available packages from the [anaconda.org](https://anaconda.org/) website. 
Packages are organised into "channels", which represent communities that develop and maintain the installation "recipes" for each software. 
The most popular channels for bioinformatics and data analysis are "**bioconda**" and "**conda-forge**". 

There are three main commands to use with Mamba:

- `mamba create -n ENVIRONMENT-NAME`: this command creates a new software environment, which can be named as you want. Usually people name their environments to either match the name of the main package they are installing there (e.g. an environment called `pangolin` if it's to install the _Pangolin_ software). Or, if you are installing several packages in the same environment, then you can name it as a topic (e.g. an environment called `rnaseq` if it contains several packages for RNA-seq data analysis).
- `mamba install -n ENVIRONMENT-NAME  NAME-OF-PACKAGE`: this command installs the desired package in the specified environment. 
- `mamba activate ENVIRONMENT-NAME`: this command "activates" the environment, which means the software installed there becomes available from the terminal. 

Let's see a concrete example. 
If we wanted to install packages for phylogenetic analysis, we could do: 


```bash
# create an environment named "phylo"
mamba create -n phylo

# install some software in that environment
mamba install -n phylo iqtree==2.3.3 mafft==7.525
```

If we run the command: 

```bash
mamba env list
```

We will get a list of environments we created, and "phylo" should be listed there. 
If we want to use the software we installed in that environment, then we can activate it: 

```bash
mamba activate phylo
```

And usually this changes your terminal to have the word `(phylo)` at the start of your prompt instead of `(base)`. 


### Environment files

Although we can create and manage environments as shown above, it may sometimes be useful to specify an environment in a file. 
This is particularly useful if you want to document how your environment was created and if you want to recreate it somewhere else. 

Environments can be defined using a specification file in [YAML format](https://en.wikipedia.org/wiki/YAML) (a simple text format often used for configuration files). 
For example, our phylogenetics environment above could be specified as follows:

```yml
name: phylo
channels:
  - conda-forge
  - bioconda
dependencies:
  - iqtree==2.3.3
  - mafft==7.525
```

We have included this example in the file `demo/envs/phylo.yml`.
To create the environment from the file, we can use the command: 

```bash
mamba env create -f envs/phylo.yml
```

If you later decide to update the environment, either by adding a new software or by updating the software versions, you can run the command: 

```bash
mamba env update -f envs/phylo.yml
```

You can practice this in an exercise below.


## Disadvantages and pitfalls

### Dependency conflicts {.unnumbered .unlisted}

One thing to be very careful about is how Conda/Mamba manages the dependency graph of packages to install. 
If you don't specify the version of the software you want, in theory Mamba will pick the latest version available on the channel. 
However, this is conditional on the other packages that are installed alongside it, as some versions may be incompatible with each other, it may downgrade some packages without you realising. 

<!-- TODO: convert this to an exercise instead -->

Take this example, where we create a new environment called `metagen` for a metagenomics project. 
We initiate the environment with only two packages: GTDB-tk (taxonomic classification of genomes) and Bowtie2 (generic short-read aligner): 

```bash
mamba create -n metagen bowtie2 gtdbtk
```

At the time of writing, the [latest version of GTDB-tk on anaconda.org](https://anaconda.org/bioconda/metaphlan) is 2.4.0, however as we run this command we can see that Mamba is installing version 1.7.0 - that's a whole major versions older!

Let's be more explicit and specify we want the latest versions available for both packages (at the time of writing): 

```bash
mamba create -n metagen bowtie2==2.5.4 gtdbtk==2.4.0
```

By running this command, we get an error message informing us that Mamba could not find a fully compatible environment for all these three software versions: 

```
Could not solve for environment specs
The following packages are incompatible
├─ bowtie2 2.5.4  is installable and it requires
│  ├─ tbb >=2021.12.0 , which requires
│  │  └─ libhwloc [>=2.10.0,<2.10.1.0a0 |>=2.11.0,<2.11.1.0a0 |>=2.11.1,<2.11.2.0a0 ], which requires
│  │     └─ libxml2 [>=2.12.6,<3.0a0 |>=2.12.7,<3.0a0 ] with the potential options
│  │        ├─ libxml2 [2.12.6|2.12.7] would require
│  │        │  └─ icu >=73.2,<74.0a0 , which can be installed;
│  │        ├─ libxml2 [2.12.6|2.12.7] would require
│  │        │  ├─ icu >=73.2,<74.0a0 , which can be installed;
│  │        │  └─ libzlib [>=1.3.1,<1.4.0a0 |>=1.3.1,<2.0a0 ] with the potential options
│  │        │     ├─ libzlib 1.3.1 would require
│  │        │     │  └─ zlib 1.3.1 *_1, which can be installed;
│  │        │     └─ libzlib 1.3.1 would require
│  │        │        └─ zlib 1.3.1 *_0, which can be installed;
│  │        ├─ libxml2 2.12.7 would require
│  │        │  ├─ icu >=75.1,<76.0a0 , which can be installed;
│  │        │  └─ libzlib >=1.3.1,<2.0a0 , which can be installed (as previously explained);
│  │        └─ libxml2 2.13.1 would require
│  │           └─ icu >=73.1,<74.0a0 , which can be installed;
│  └─ zstd >=1.5.6,<1.6.0a0 , which can be installed;
└─ gtdbtk 2.4.0  is uninstallable because it requires
   └─ fastani 1.32.* , which requires
      ├─ boost >=1.70.0,<1.70.1.0a0 , which requires
      │  └─ boost-cpp 1.70.0.*  but there are no viable options
      │     ├─ boost-cpp 1.70.0 would require
      │     │  └─ zstd >=1.4.4,<1.5.0.0a0 , which conflicts with any installable versions previously reported;
      │     ├─ boost-cpp 1.70.0 would require
      │     │  └─ icu >=64.2,<65.0a0 , which conflicts with any installable versions previously reported;
      │     └─ boost-cpp 1.70.0 would require
      │        └─ icu >=58.2,<59.0a0 , which conflicts with any installable versions previously reported;
      └─ zlib >=1.2.11,<1.3.0a0 , which conflicts with any installable versions previously reported.
```

How could we solve this problem? 
One possibility is to **install each software in a separate environment**. 
The disadvantage is that you will need to run several `mamba activate` commands at every step of your analysis. 

Another possibility is to **find a compatible combination of package versions** that is sufficient for your needs.
For example, let's say that GTDB-tk was the most critical software for which we needed to run the latest version. 
We could find what is the latest version of Bowtie2 compatible with it, by forcing the GTDB-tk version, but not the other one: 

```bash
mamba create -n metagen bowtie2 gtdbtk==2.4.0
```

Running this command, we can see that we would get `bowtie2==2.5.1`. 
So, Bowtie2 would be a slightly older version than currently available, but not a major difference. 
If we were happy with this choice, then we could proceed. 
For reproducibility, we could save all this information in a YAML file specifying our environment: 

```yaml
name: metagen
channels:
  - conda-forge
  - bioconda
dependencies:
  - bowtie==2.5.1
  - gtdbtk==2.4.0
```


### Package availability {.unnumbered .unlisted}

Some packages not available: 

- [Cell Ranger](https://www.10xgenomics.com/support/software/cell-ranger/latest) is a very popular software for processing single-cell RNA-seq data from the 10x genomics platform. However, the software is not open source and therefore not available through the bioconda channel. 
- Software that is not used by a wide-enough community, and thus has no available installation recipe. For example [AliView](https://ormbunkar.se/aliview/) (to visualise multiple sequence alignments) or [APAtrap](https://sourceforge.net/p/apatrap/wiki/User%20Manual/) (differential usage of alternative polyadenylation sites from RNA-seq).


### Disk space {.unnumbered .unlisted}

Environments can take a lot of disk space in your system. 
This is software-dependent, but in some cases can become quite substantial (several GB of files). 
Therefore, it's good practice to: 

- 


::: {.callout-note}
#### Mixing package managers

There might be times when some packages/libraries are not available in a package manager. For example, it can be common to use conda/mamba but find a python library that is only available through `pip`. Unfortunately, this may cause issues in your environment as pip may change your conda-installed packages, which might break the conda environment. There are a few steps one can follow to avoid this pitfalls:

1. Start from a new and clean environment. If the new environment breaks you can safely remove it and start over. You can create a new environment from pre-existing ones if necessary. We will see more of this later.
2. Install `pip` in your conda environment. This is important as the pip you have in your base environment is different from your new environment (will avoid conflicts).
3. Install any conda packages your need to get the environment ready and leave the pip install for last. Avoid switching between package managers. Start with one and finish with the other one so reversing or fixing conflicts is easier.

You can find a (checklist)[https://www.anaconda.com/blog/using-pip-in-a-conda-environment] in the anaconda webpage for good practice.
:::


## Exercises

:::{.callout-exercise}
#### Creating a new Mamba environment

Go to the `demo` directory, where you will find some FASTQ files in the `reads` folder. 
The objective in this exercise is to setup a software environment to run a standard quality control software on these sequencing reads. 

- Use a text editor to create a Conda/Mamba environment file called `envs/qc.yml`. This file should specify: 
  - Environment name: `qc`
  - Channels: `conda-forge`, `bioconda`
  - Packages: FastQC v0.12.1 and MultiQC v1.21 (check available packages at [anaconda.org](https://anaconda.org/)).
- Using `mamba` build the environment from your created file.
- Activate your new environment and run the QC script provided: `bash scripts/01-qc.sh` (you can look inside the script to see what it is doing).
- Check if you obtained the final output file in `results/qc/multiqc_report.html`.

:::{.callout-answer}

We can see how to specify an environment file manually on the [Conda documentation page](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#create-env-file-manually).
Following those instructions, we have created the following file and saved it as `envs/qc.yml`: 

```yml
name: qc
channels:
  - conda-forge
  - bioconda
dependencies:
  - fastqc==0.12.1
  - multiqc==1.21
```

We then created our environment with the command: 

```bash
mamba env create -f envs/qc.yml
```

We then activate our environment:

```bash
mamba activate qc
```

And finally ran the script provided: 

```bash
bash scripts/01-qc.sh
```

We can see the script ran successfully by looking at the output directory `results`.

:::
:::


:::{.callout-exercise}
#### Update a Mamba environment

Going back to the `envs/phylo.yml` environment (in the `demo` folder), update the environment to include a software to for dating phylogenetic trees called TreeTime.

- Go to [anaconda.org](https://anaconda.org/) to see what is the latest version available and from which channel.
- Update the YAML environment file to include it.
- Update the environment.
- Check if the software was installed successfully by running `treetime --version`.

::: callout-answer

We can see the software is available from https://anaconda.org/bioconda/treetime, provided from the bioconda channel.
The latest version at the time of writing is 0.11.3, so it is the one we demonstrate below. 

Using a text editor of our choice, we update our YAML file: 

```yml
name: phylo
channels:
  - conda-forge
  - bioconda
dependencies:
  - iqtree==2.3.3
  - mafft==7.525
  - treetime==0.11.3
```

After saving the changes, we update our environment: 

```bash
mamba env update -f envs/phylo.yml
```

Once the update runs successfully, we activate the environment first with `mamba activate phylo` and then test our software: 

```bash
treetime --version
```

```
treetime 0.11.3
```

The command runs successfully, with the expected version printed, indicating it is successfully installed. 

:::
:::


<!-- 
:::{.callout-exercise}

TODO: example of environment with conflicts?

::: 
-->


## Summary

::: callout-tip
#### Key points

- A package manager automates the process of installing, upgrading, configuring, and managing software packages, including their dependencies.
- Examples of package managers are `pip` (Python), `apt` (Debian/Ubuntu) and `conda`/`mamba` (generic).
- Dependency conflicts, which often arise in complex bioinformatic workflows, can be resolved by managing software in isolated environments. 
- Conda/Mamba simplify these tasks by managing dependencies, creating isolated environments, and ensuring reproducible setups across different systems.
- Key Mamba commands include:
  - `mamba create --name ENVIRONMENT-NAME` to create a new environment.
  - `mamba install -n ENVIRONMENT-NAME  NAME-OF-PACKAGE` to install a package inside that environment.
  - `mamba activate ENVIRONMENT-NAME` to make the software from that environment available.
  - `mamba env create -f ENVIRONMENT-YAML-SPECIFICATION` to create an environment from a YAML file (recommended for reproducibility).
  - `mamba env update -f ENVIRONMENT-YAML-SPECIFICATION` to update an environment from a YAML file (recommended for reproducibility).
- Recognise some of limitations of Mamba as a package manager and how to avoid common pitfalls. 
- There are some disadvantages/limitations of Mamba as a package manager: 
  - Dependencies aren't always respected.
  - Software versions are sometimes downgraded without explicit warning.
  - It can be slow at resolving very complex environments. 
:::