---
pagetitle: "Software & Pipelines"
---

# Container Virtualisation

::: callout-tip
#### Learning objectives

- Describe how software containerisation helps in managing complex software environments. 
- Use online repositories to find existing images for commonly used software in bioinformatics.
- Use Singularity to run commands within a container. 
- Configure Singularity to work on different filesystems.

:::

## Overview

Software containerisation is a way to package software and its dependencies in a single file. 
A software container can be thought of as a small virtual machine, with everything needed to run that software stored inside that file. 
Software containers are self-contained, meaning that they are isolated from the host system. 
This ensures reproducibility, addressing the issue of incompatible dependencies between tools (similarly to Mamba environments). 
They can run on a local computer or on a high-performance computing cluster, producing the same result.
The same analysis can be run on different systems ensuring consistency and reproducibility.

For these reasons, software containerisation solutions, such as [_Docker_](https://www.docker.com/) and [_Singularity_](https://docs.sylabs.io/guides/latest/user-guide/), are widely used in bioinformatics.
While these two container software solutions share many similarities, we will focus our attention on _Singularity_, as it is more widely used in HPC cluster systems (but it can also be used on a regular computer). 
However, it's worth keeping in mind that images created with Docker can be compatible with Singularity and _vice versa_.

:::{.callout-note collapse=true}
#### Docker vs singularity

There are some key differences between Docker containers and Singularity containers. 
The most important being the necessary *permission level* of the containers. 
Docker containers run as root (admin) by default, which means that they have full access to the host system. 
While this can be advantageous in some cases, it can also pose security risks, particularly in multi-user environments. 
Singularity, on the other hand, runs containers as non-root users by default, which can improve security and prevent unauthorized access to the host system. 
Singularity is specifically designed for use in HPC environments and can run on a wide variety of platforms and systems without root access.

**TL;TR:**

- Docker is well-suited for building and distributing software across different platforms and operating systems.
- Singularity is specifically designed for use in HPC environments and can provide improved security and performance in those settings.
:::

:::{.callout-note collapse=true}
#### Have heard about Apptainer?

Singularity as we knew it is in fact no longer actively maintained and is deprecated - what happened to it?
It was essentially split into two parallel projects: 

- [**Apptainer**](https://apptainer.org/): this is a rebranding of the original Singularity, which is supported by the Linux Foundation since 2021 ([announcement](https://apptainer.org/news/community-announcement-20211130/)). The Linux foundation is a non-profit that provides a neutral, trusted hub for developers and organizations to code, manage, and scale open technology projects and ecosystems. As such, Apptainer is and will remain free and open source (FOSS) software. Apptainer is still functionally the same as the original Singularity, so you should be able to use Singularity images with Apptainer. 
- [**SingularityCE**](https://docs.sylabs.io/guides/latest/user-guide/): this is a fork of the original Singularity, which is developed and maintained by the commercial company Sylabs. 

There are some [differences between Apptainer and SingularityCE](https://github.com/sylabs/singularity/discussions/2948), but in practice they work very similarly to each other. 
:::

:::{.callout-note}
#### How do I install Singularity?

Usually, Singularity is used on a HPC environment and in that case we recommend that you use the version installed by your system administrators. 

If you want a local installation, you can install Singularity using Mamba: 

```bash
mamba create -n singularity conda-forge::singularity==3.8.7
```

You may want to change the command above to use the lastest version [available here](https://anaconda.org/conda-forge/singularity). 

Alternatively, we show how to perform a system-level installation in our [setup page](../setup.md#singularity).
:::


## Singularity images

Containers are constructed from `images` - these are executable files that generate the container. 
To help understand this, consider `images` like a sheet of music and `containers` as the actual music you hear. 
The sheet music is portable and can be performed on various instruments, yet the melody remains consistent regardless of where it's played.

Although you can build your own Singularity images, for many popular software there are already pre-built images available from public repositories. 
Some popular ones are: 

- [BioContainers](https://biocontainers.pro/): a community project that provides a search page for bioinformatic software images stored on several repositories. This is our recommendation as the first page to look at, as it includes results from several repositories (Quay.io, DockerHub, Galaxy).
- [Galaxy Project](https://galaxyproject.org/): an open-source platform for bioinformatic data analysis. They provide many pre-built images on their [galaxy depot](depot.galaxyproject.org).
- [DockerHub](https://hub.docker.com/search): a generic repository of Docker images, which can also be used with Singularity.
- [Quay.io](https://quay.io/): a generic repository of images maintained by Red Hat.
- [Sylabs](https://cloud.sylabs.io/): a generic repository maintained by the Singularity developers.

For example, let's consider the [SeqKit program](https://bioinf.shenwei.me/seqkit/), which is a toolkit for manipulating FASTA/Q files. 
If we search on those websites, we will see this software is available on all of them. 
In this case, the version on Sylabs ([here](https://cloud.sylabs.io/library/bhargava-morampalli/containers/seqkit)) is older than the one listed on BioContainers ([here](https://biocontainers.pro/tools/seqkit)). 

Looking at that BioContainers page, we can see the link to the image, which is pulled from depot.galaxyproject.org. 
To pull the image, we can do the following:

```bash
# create a directory for our singularity images
mkdir images

# download the image
singularity pull images/seqkit-2.8.2.sif https://depot.galaxyproject.org/singularity/seqkit:2.8.2--h9ee0642_1
```

Here, we are saving the image file as `seqkit-2.8.2.sif` (`.sif` is the standard extension for singularity images). 
Once we have this image available, we are ready to run the software, which will see in practice with the exercise below. 

:::{.callout-tip}
#### Using Docker images with Singularity

It's worth noting that Docker images are also compatible with Singularity.
For example, on that same Biocontainers `seqkit` page, we are given a link to use with the `docker pull` command. 
But we can use that same link to build a Singularity image using the `docker://` prefix in our link, like so: 

```bash
singularity pull images/seqkit-2.8.2.sif docker://quay.io/biocontainers/seqkit:2.8.2--h9ee0642_1
```

These are effectively the same image, just pulled from two different servers. 
The image on depot.galaxy.org is already pre-built, so we're effectively only downloading a file to our computer. 
On the other hand the image from Quay.io is the "recipe" to build the image, which the Singularity command takes care of building for us. 
:::

## Executing commands

To execute a command inside the image container, we can use the `singularity run` command. 
For example, let's run the command `seqkit --help` to look at the help documentation of the SeqKit software:

```bash
singularity run images/seqkit-2.8.2.sif seqkit --help
```

And this should print the help of the program. 
Note that SeqKit is not installed on your system, rather the command is avaible inside the container, as it was pre-installed in its image file. 


## Filesystem binding

One important thing to note is that, by default, not your entire filesystem is visible to the container. 
You have your home directory mounted on the image by default, but nothing else. 

If you want to operate on files that are on a different file partition, you need to _bind_ them to the container.
This is done using the `--bind` option, which requires a **full path** to the directory you want to make available on the image. 

For example, say a user called `robin` was working on a directory called `/scratch/robin/awesomeproject`. 
Because this directory is not in the default home (`/home/robin`), it will not be available on the container by default. 
The user could make it available as the default directory by running: 

```bash
singularity run --bind /scratch/robin/awesomeproject images/seqkit-2.8.2.sif seqkit --help
```

See more information about this in the [Singularity documentation](https://docs.sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html).

:::callout-note
#### Singularity on HPC systems

Typically, Singularity is pre-installed on HPC servers by the system administrators, and **we recommend that you use the version installed by your system admins**. 
This is because they will have often already set specific bindings to the filesystem, meaning you don't need to do this yourself. 
:::


## Exercises

:::{.callout-exercise}

To illustrate the use of Singularity, we will use the `seqkit` software to extract some basic statistics from the sequencing files in the `demo/reads` directory. 
If you haven't done so already, first download the image with the commands [shown above](#singularity-images). 

We can test if our image is working by running the `seqkit --help` command in our container: 

```bash
singularity run images/seqkit-2.8.2.sif seqkit --help
```

- Run `seqkit stats reads/*.fastq.gz` using the singularity image we downloaded earlier.


:::{.callout-answer}
The Singularity command is: 

```bash
singularity run images/seqkit-2.8.2.sif seqkit stats reads/*.fastq.gz
```

If we run this, it produces an output like this: 

```
file                                     format  type   num_seqs      sum_len  min_len  avg_len  max_len
reads/SRR7657872_1.downsampled.fastq.gz  FASTQ   DNA   1,465,993  219,898,950      150      150      150
reads/SRR7657872_2.downsampled.fastq.gz  FASTQ   DNA   1,465,993  219,898,950      150      150      150
reads/SRR7657874_1.downsampled.fastq.gz  FASTQ   DNA   1,379,595  206,939,250      150      150      150
reads/SRR7657874_2.downsampled.fastq.gz  FASTQ   DNA   1,379,595  206,939,250      150      150      150
reads/SRR7657876_1.downsampled.fastq.gz  FASTQ   DNA   1,555,049  233,257,350      150      150      150
reads/SRR7657876_2.downsampled.fastq.gz  FASTQ   DNA   1,555,049  233,257,350      150      150      150
reads/SRR7657877_1.downsampled.fastq.gz  FASTQ   DNA   1,663,432  249,514,800      150      150      150
reads/SRR7657877_2.downsampled.fastq.gz  FASTQ   DNA   1,663,432  249,514,800      150      150      150
```

:::
:::


## Summary

::: callout-tip
#### Key points

- Software containerisation solutions such as Docker and Singularity achieve isolation and consistency in running software. This is because they encapsulate applications with their dependencies in a file (known as an image), ensuring consistent performance across different environments.
- The computer science and bioinformatics community has built many images for commonly used software, including the [galaxy depot](https://depot.galaxyproject.org/singularity/), [Sylabs](https://cloud.sylabs.io/) and [dockerhub](https://hub.docker.com/search).
- To download an image from the online repositories we can use the command `singularity pull <URL TO IMAGE>`
- To run a command using an existing image, we use the command: `singularity run <PATH TO IMAGE> <YOUR COMMAND>`
- We can mount specific directories in our filesystem to the Singularity container using the `--bind` option with a _full path_ to the directory we want to make available.
:::
