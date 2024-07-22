---
pagetitle: "Software & Pipelines"
---

# Nextflow on HPC

::: callout-tip
#### Learning objectives

TODO

How to configure Nextflow to run on a HPC.

- Config file - e.g. setting SLURM options to use
- Use `tmux`/`screen` to get a persistent terminal on a remote server
- If running many samples consider using `sintr` - many samples might overload the memory and get the nextflow run killed.
:::



## How to specify configuration in Nextflow

To run on a HPC, we can specify a `config` specific to our system. A `config file` is a set of configuration attributes for the pipeline execution. Nextflow by default will check for config file in default locations [link to advance-config?] but these can also be specified by using `-c` option in the command line. 

It is possible to have more than one `config` file and they can be all specified using `-c` though this will be merged and, so that the settings in the first override the same settings appearing in the second, and so on.


## What do you need to configure as a basic nextflow user?
Understanding the `config` file of a nextflow pipeline can be slightly daunting at first, specially if you start with a nf-core configuration, those can be complex and have many parameters that normally users won't need to modify. In general, you can get away with just modifying the necessary parameters using `-c your_config_profile.config` when launching your pipeline. We will show you in the next example.

Let's say you want to run `nf-core/rnaseq`. Several questions may arise:

- How do I specify my input data?
- Where do I write my SLURM details such as my account and partition I want to use?
- If I am analysing a non conventional organism, how do I change default resource files such as `genome`

First things first, [check out the docs](https://nf-co.re/rnaseq/3.14.0/docs/usage/), there is a lot of useful info in there that can guide you for the first time you use the pipeline. Here you will find answers to those questions but also went through that is previous sections so hopefully we have all inputs located now.

Now that you are ready, it is time to think how we can use our resources smartly. There are just a few settings that you need to modify as a cluster user. Let's create a `cambridge_hpc.config`, we will need the following:

- Add `executor`, in this case `slurm`
- Specify cluster options to add your account and the partition you desire to use
- Add params specific for the system such as `max_memory`, `max_cpus` and `max_time`, this might be dependant on your account.
- Executor configuration (extremely important to use `slurm` efficiently). We need to limit the submission rate and queue polls to avoid nextflow calling slurm continuously in very short periods of time as **this will overload our scheduler**.
- [Singularity](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) configuration. The best way to run your processes safely in the cluster is using singularity, this can be configured using the [singularity scope](https://www.nextflow.io/docs/latest/config.html#scope-singularity).

We will go through an example in the next section.

:::{.callout-note collapse=true}

# Have heard about Apptainer?

[Singularity](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) as we knew it is no longer actively maintained and is deprecated. What happened to it?

Singularity project moved a few years back to the [Linux Foundation](https://www.linuxfoundation.org/) (a non-profit that provides a neutral, trusted hub for developers and organizations to code, manage, and scale open technology projects and ecosystems) rebranding to **Apptainer**. It is still functionally the same as Singularity. Apptainer/Singularity is a free and open-source container platform that allows you to create and run applications in isolated environments (also called “containers”) in a simple, portable, fast, and secure manner. Containers ensure software components are encapsulated for portability and reproducibility, making them perfect to use is a safely in any shared system. Read the announcement [here](https://apptainer.org/news/community-announcement-20211130/).

What about Sylabs? This is the company that used to run Singularity. The also moved on to **SingularityCE**, which  is the Sylabs-maintained branch of singularity while Apptainer is the branch supported by the Linux Foundation. Both SingularityCE and Apptainer are derivatives of the original Singularity software in some way.

:::

### Cambridge HPC configuration

To work at the Cambridge University HPC we created the following configuration file:

```conf
// See more info on process scope [here](https://www.nextflow.io/docs/latest/config.html#scope-process)
process {
    executor = 'slurm' // This is our job scheduling system or executor

    // options to feed to slurm: this should be written as given to [sbatch](https://slurm.schedmd.com/sbatch.html) command
    clusterOptions = '--account LEYSER-SL2-CPU --partition training' 
}

// Specify MAX parameters to avoid going over the limits and getting an error.
params {
    max_memory = '327.GB' // for cclake-himem
    max_cpus = '56'       // for cclake nodes
    max_time = '36.h'     // for SL2 service level
}

// Limit nextflow submissions rates to a reasonable level to be kind to other users
// See all options [here](https://www.nextflow.io/docs/latest/config.html#scope-executor)
executor {
    queueSize         = '2000'
    pollInterval      = '3 min'
    queueStatInterval = '5 min'
    submitRateLimit   = '50sec'
    exitReadTimeout   = '5 min'
}
\\ More info on singularity options [here](https://www.nextflow.io/docs/latest/config.html#scope-singularity)

singularity {
    enabled = true  // We are forcing singularity to be enabled
    autoMounts = true  // Extremely useful if you are unsure about [binding](https://apptainer.org/user-docs/master/bind_paths_and_mounts.html)
    pullTimeout = '1 h'  // Allow extra time to pull out a container
    cacheDir = '$HOME/rds/hpc-work/nextflow-singularity-cache'  // Specify a cache dir to avoid downloading same containers to different directories.
}
```


## Where to run your Nextflow pipeline

You might wondering if it is kay to run your nextflow pipeline in the HPC headnode. Normally, it is absolutely fine as nextflow won't be taking too many resources. However, you do need to *keep your nextflow run open in your terminal*. There are several ways to achieve this:

Option 1:

You can run your nextflow pipeline using the `-bg` option, which will run your nextflow pipeline in the background of your terminal. If you need to look at the output of the nextflow run you can take a look at your `.nextflow.log`

Option2:

If you don't want to miss any output from your run we recommend using a *terminal ultiplexer* such as [`screen`](https://linuxize.com/post/how-to-use-linux-screen/) or [`tmux`](https://github.com/tmux/tmux/wiki). Both work the same way, except that `screen` is normally installed by default in the linux machine, therefore we recommend you start there. What these tools allow is to open a session within your terminal that it is virtually the same as your actual terminal with the exception that it will be kept open in the background. This allows processes to continue to run even if you close your window or get disconnected from the HPC.

Example:

```bash
screen -s mysession
# a screen session caller 'mysession' will be opened
echo 'hello this is a test'
# close your window.
```

After you close your terminal, open a new one. Make sure you are logged in in the same head node and run:

```bash
screen -ls
# you will see mysession still running
screen -r mysession
# you re-attached to your session and keep working where you left it!
```


## Exercises

:::{.callout-exercise}

- Create a configuration file for our "HPC" using the sapphire partition.

- Singularity cache in custom directory.
- Re-run the pipeline and see if it is submitting jobs to the scheduler as expected.
  - Extra: run it from a `screen` session
- Add `errorStrategy` to avoid specific error
- [Optional/Advanced] Add a new label to an existing process using `withName`
- [Optional/Advanced] Make a process run only `when` a condition is met

:::


## Summary

::: callout-tip
#### Key points

- WfMS define, automate and monitor the execution of a series of tasks in a specific order. They improve efficiency, reduce errors, can be easily scaled (from a local computer to a HPC cluster) and increase reproducibility.
- Popular WfMS in bioinformatics include Nextflow and Snakemake. Both of these projects have associated community-maintained workflows, with excellent documentation for their use: [nf-core](https://nf-co.re/) and the [snakemake workflow catalog](https://snakemake.github.io/snakemake-workflow-catalog/).
- TODO: finish key points
:::