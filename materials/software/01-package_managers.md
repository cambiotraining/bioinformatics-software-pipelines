---
title: "Package Managers"
---

This section could cover common package managers: 

- Pip for Python packages
- CRAN and Bioconductor for R packages
- `apt` for Ubuntu-based distributions
- Conda/Mamba as a more general solution

Most of the time should be spent on _Conda_, but good to introduce the others as common package managers people might encounter. 

----

Most operating systems have **package managers** available, which allow the user to manage (install, remove, upgrade) their software easily. 
The package manager takes care of automatically downloading and installing the software we want, as well as any dependencies it requires.

![Diagram illustrating how package managers work. [Image source](https://itsfoss.com/package-manager/).](https://itsfoss.com/content/images/wordpress/2020/10/linux-package-manager-explanation.png)

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


### _Conda_/_Mamba_ Package Manager

A popular package manager in data science, scientific computing and bioinformatics is **_Mamba_**, which is a successor to another package manager called _Conda_.

_Conda_ was originally developed by [Anaconda](https://anaconda.org/) as a way to simplify the creation, distribution, and management of software environments containing different packages and dependencies. 
It is known for its cross-platform compatibility and relative ease of use (compared to compiling software and having the user manually install all software dependencies). 
_Mamba_ is a more recent and high-performance alternative to _Conda_. 
While it maintains compatibility with _Conda_'s package and environment management capabilities, _Mamba_ is designed for **faster dependency resolution and installation**, making it a better choice nowadays. 
Therefore, the rest of this section focuses on _Mamba_ specifically.

One of the strengths of using _Mamba_ to manage your software is that you can have different versions of your software installed alongside each other, organised in **environments**. 
Organising software packages into environments is extremely useful, as it allows to have a _reproducible_ set of software versions that you can use and reuse in your projects. 

For example, imagine you are working on two projects with different software requirements:

- Project A: requires Python 3.7, NumPy 1.15, and scikit-learn 0.20.
- Project B: requires Python 3.12, the latest version of NumPy, and TensorFlow 2.0.

If you don't use environments, you would need to install and maintain these packages globally on your system. 
This can lead to several issues:

- **Version conflicts:** different projects may require different versions of the same library. For example, Project A might not be compatible with the latest NumPy, while Project B needs it.
- **Dependency chaos:** as your projects grow, you might install numerous packages, and they could interfere with each other, causing unexpected errors or instability.
- **Difficulty collaborating:** sharing your code with colleagues or collaborators becomes complex because they may have different versions of packages installed, leading to compatibility issues.

![Illustration of _Conda_/_Mamba_ environments. Each environment is isolated from the others (effectively in its own folder), so different versions of the packages can be installed for distinct projects or parts of a long analysis pipeline.](images/conda_environments.svg)

**Environments allow you to create isolated, self-contained environments for each project**, addressing these issues:

- Isolation: you can create a separate environment for each project. This ensures that the dependencies for one project don't affect another.
- Software versions: you can specify the exact versions of libraries and packages required for each project within its environment. This eliminates version conflicts and ensures reproducibility.
- Ease of collaboration: sharing your code and environment file makes it easy for collaborators to replicate your environment and run your project without worrying about conflicts.
- Simplified maintenance: if you need to update a library for one project, it won't impact others. You can manage environments separately, making maintenance more straightforward.

Another advantage of using _Mamba_ is that the **software is installed locally** (by default in your home directory), without the need for admin (`sudo`) permissions. 

You can search for available packages from the [anaconda.org](https://anaconda.org/) website. 
Packages are organised into "channels", which represent communities that develop and maintain the installation "recipes" for each software. 
The most popular channels for bioinformatics and data analysis are "_bioconda_" and "_conda-forge_". 

There are three main commands to use with _Mamba_:

- `mamba create -n ENVIRONMENT-NAME`: this command creates a new software environment, which can be named as you want. Usually people name their environments to either match the name of the main package they are installating there (e.g. an environment called `pangolin` if it's to install the _Pangolin_ software). Or, if you are installing several packages in the same environment, then you can name it as a topic (e.g. an environment called `rnaseq` if it contains several packages for RNA-seq data analysis).
- `mamba install -n ENVIRONMENT-NAME  NAME-OF-PACKAGE`: this command installs the desired package in the specified environment. 
- `mamba activate ENVIRONMENT-NAME`: this command "activates" the environment, which means the software installed there becomes available from the terminal. 

Let's see a concrete example. 
If we wanted to install packages for phylogenetic analysis, we could do: 


```bash
# create an environment named "phylo"
mamba create -n phylo
 
# install some software in that environment
mamba install -n phylo  iqtree mafft
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

And usually this changes your terminal to have the word `(phylo)` at the start of your prompt. 


## Environment Files

TODO: Add explanation about `environment.yml` files. 



## Exercises

:::{.callout-exercise}

- Using a text editor, create an environment file called `envs/qc.yml`. This file should specify: 
  - Environment name: `qc`
  - Channels: `defaults`, `conda-forge`, `bioconda`
  - Packages: FastQC and MultiQC (the latest versions available from [anaconda.org](https://anaconda.org/)).
- Using `mamba` build the environment from your created file.
- Activate your new environment and run the QC script provided: `bash scripts/01-qc.sh` (you can look inside the script to see what it is doing).
- Check if you obtained the output files in `results/`.

:::


:::{.callout-exercise}

TODO: example of environment with conflicts

:::


:::{.callout-exercise}

TODO: example of pip-installable package (if we can find example of something not available through conda)

:::