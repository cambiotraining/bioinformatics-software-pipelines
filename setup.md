# Data & Setup {.unnumbered}

<!--
Note for Training Developers:
We provide instructions for commonly-used software as commented sections below.
Uncomment the sections relevant for your materials, and add additional instructions where needed (e.g. specific packages used).
Note that we use tabsets to provide instructions for all three major operating systems.
-->

::: {.callout-tip level=2}
## Workshop Attendees

If you are attending one of our workshops, we will provide a training environment with all of the required software and data.
If you want to setup your own computer to run the analysis demonstrated on this course, you can follow the instructions below.
:::

## Data

You can download the data used in these materials as a zip file from dropbox.

<!-- Note for Training Developers: add the link to 'href' -->
<a href="https://www.dropbox.com/scl/fo/hof2gmftr8iq1744jkwnd/AOE_vgyKxphI63OAA5dCzqM?rlkey=k929x9ipitvuexrf72u7hbth9&st=muryirlr&dl=0" target="_blank"> <button class="btn"><i class="fab fa-dropbox"></i> Download</button> </a>

Alternatively, using the command line (from within a directory of your choice, e.g. `~/Desktop`):

```bash
wget -O biopipelines.zip "https://www.dropbox.com/scl/fo/hof2gmftr8iq1744jkwnd/AOE_vgyKxphI63OAA5dCzqM?rlkey=k929x9ipitvuexrf72u7hbth9&st=muryirlr&dl=1"
unzip biopipelines.zip -d biopipelines_course
rm biopipelines.zip
```

## Setup

### Conda

We recommend using the *Conda* package manager to install your software.
In particular, the newest implementation called *Mamba*.

To install *Mamba*, run the following commands from the terminal:

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p $HOME/miniforge3
rm Miniforge3-$(uname)-$(uname -m).sh
$HOME/miniforge3/bin/mamba shell init
```

Restart your terminal (or open a new one).
Then run the following commands:

```bash
conda config --add channels nodefaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda config --set remote_read_timeout_secs 1000
```

### Nextflow

We recommend that you install *Nextflow* within a conda environment.
You can do that with the following command:

```bash
mamba create -n nextflow -y nextflow
```

Due to some [recent syntax updates](https://docs.seqera.io/nextflow/strict-syntax/) in the Nextflow language, we recommend running the following command, to ensure compatibility with workflows that still use the older syntax:

```bash
echo "export NXF_SYNTAX_PARSER=v1" >> ~/.bashrc
```

When you want to use *Nextflow* make sure to activate this software environment by running `mamba activate nextflow`.

### Singularity

::: {.callout-note}
#### Note for HPC users

If you are using a HPC, you won't need to install Singularity, as the HPC admins should have already done this for you.
:::

We recommend that you install *Singularity* and use the `-profile singularity` option when running *Nextflow* pipelines.
On Ubuntu/WSL2, you can install *Singularity* using the following commands:

```bash
sudo apt install -y libfuse2t64 runc fuse2fs uidmap
wget -O singularity.deb https://github.com/sylabs/singularity/releases/download/v4.6.0/singularity-ce_4.6.0-$(lsb_release -cs)_amd64.deb
sudo dpkg -i singularity.deb
rm singularity.deb
```

If you have a different Linux distribution, you can find more detailed instructions on the [*Singularity* documentation page](https://docs.sylabs.io/guides/3.0/user-guide/installation.html#install-on-linux).
