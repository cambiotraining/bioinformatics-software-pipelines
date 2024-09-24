---
pagetitle: "Software & Pipelines"
---

# Nextflow on HPC

::: callout-tip
#### Learning objectives

- Configure a Nextflow pipeline to run on an HPC cluster using a custom configuration file that matches the available resources and job scheduling policies.
- Execute a Nextflow pipeline on a HPC and monitor job submissions using SLURM.
- Use terminal multiplexers like `screen` or `tmux` to manage long-running Nextflow processes on an HPC.
- Apply HPC best practices, including resource allocation and ethical job submission strategies, to optimise workflow performance.
:::


## Nextflow HPC configuration

To run our workflows on an HPC, it is advisable to **specify a configuration file** tailored to your system. 
This file should include:

- The job scheduler used to manage jobs (e.g. SLURM, LSF, PBS, HTCondor, etc.).
- Job submission details, such as your billing account (if applicable), the partition or queue to submit jobs to, and other relevant information.
- Resource specifications like maximum RAM and CPUs available on the partitions/queues.
- Settings that control job submission, including the number of concurrent jobs, submission rate, and how often Nextflow checks job statuses.

As [briefly mentioned in the previous chapter](03-nfcore.md#configuration-profile), a config file is a set of attributes used by Nextflow when running a pipeline. 
By default, Nextflow will look for configuration files in predefined locations (see [advanced configuration](05-advanced_config.md)), but you can also specify a config file using the `-c` option.

Below is an example of a configuration file for an HPC that uses SLURM as the job scheduler. 
This example is based on the Cambridge University HPC, specifically the "cascade lake" nodes ([docs](https://docs.hpc.cam.ac.uk/hpc/user-guide/cclake.html)). 

```groovy
// See more info on process scope here: https://www.nextflow.io/docs/latest/config.html#scope-process
process {
    // Our job scheduling system or executor
    // many executors supported (cloud and HPC): https://www.nextflow.io/docs/latest/executor.html
    executor = 'slurm'
    
    // the queue or partition we want to use
    queue = 'cclake'
}

// Limit nextflow submissions rates to a reasonable level to be kind to other users
// See all options here: https://www.nextflow.io/docs/latest/config.html#scope-executor
executor {
    account             = 'YOUR-BILLING-ACCOUNT'
    perCpuMemAllocation = '3410MB'
    queueSize           = '200'
    pollInterval        = '3 min'
    queueStatInterval   = '5 min'
    submitRateLimit     = '50sec'
    exitReadTimeout     = '5 min'
}

// For nf-core pipelines, specify MAX parameters to avoid going over the limits
// these values should match the resources in the chosen queue/partition
params {
    max_memory = '192.GB'
    max_cpus = '56'
    max_time = '12.h'
}

// Options when using the singularity profile
singularity {
    enabled = true
    // useful if you are unsure about filesystem binding
    autoMounts = true
    // Allow extra time to pull out a container in case the servers are slow
    pullTimeout = '1 h'  
    // Specify a cache dir to re-use images that have already been downloaded
    cacheDir = 'PATH/TO/nextflow-singularity-cache'
}
```

Here is an explanation of this configuration: 

- The `process` directive defines:
  - The `executor`, which in this example is SLURM (the job scheduler). By default, this option would be "local", meaning commands run on the current computer.
  - The `queue`, which corresponds to the SLURM `--partition` option, determining the type of node your jobs will run on.

- The `executor` directive further configures the job scheduler:
  - `account` is the billing account (if relevant), equivalent to `-A` option in SLURM.
  - `perCpuMemAllocation` submits jobs using `--mem-per-cpu`, relevant for the Cambridge HPC. This is optional and may vary by institution. 
  - `queueSize` limits the number of simultaneous jobs in the queue. HPC admins may impose limits, so adjust this accordingly. Even with high limits, it's advisable to limit simultaneous jobs to reduce the load on the job scheduler.
  - `pollInterval`, `queueStatInterval`, `submitRateLimit` and `exitReadTimeout`  are settings that manage how often Nextflow checks job statuses and interacts with the scheduler. These settings help ensure that you use the scheduler efficiently and ethically. Rapid job submissions and frequent queue checks can overload the scheduler and might trigger warnings from HPC admins.

- The `params` directive is for pipeline-specific options. Here, we set generic options for all nf-core pipelines:
  - `max_memory`, `max_cpus` and `max_time`, which depend on your specific HPC setup and account.

- The `singularity` directive configures Singularity for running pipelines in an isolated software environment. This can be set up using the [singularity scope](https://www.nextflow.io/docs/latest/config.html#scope-singularity). 
  - `autoMounts = true` automatically mounts the filesystem, which is helpful if you're unfamiliar with [filesystem bindings](https://apptainer.org/user-docs/master/bind_paths_and_mounts.html). On most HPC systems, admins handle this, so you may not need to worry about it.
  - `cacheDir` ensures that previously downloaded images aren't downloaded again. This is beneficial if you run the same pipeline multiple times or different pipelines that use the same software images. We recommend setting up a cache directory in a location accessible from the compute nodes.

**Proper executor configuration is crucial for running your jobs efficiently on the HPC**, so make sure you spend some time configuring it correctly.


## Running Nextflow on a HPC

When working on an HPC cluster, you typically interact with two types of nodes:

- The **head or login node**, used for low-resource tasks such as navigating the filesystem, moving files, editing scripts, and submitting jobs to the scheduler.
- The **compute nodes**, where computationally intensive tasks are executed, typically managed by the job scheduler.

You might wonder if it’s acceptable to run your Nextflow command directly on the HPC head/login node. 
Generally, this is perfectly fine because Nextflow itself doesn’t consume a lot of resources. 
The main Nextflow process handles interactions with the job scheduler (e.g. SLURM), checks job statuses in the queue, submits new jobs as needed, and logs progress information. 
Essentially, it automates the process of submitting and tracking jobs, so it isn’t computationally demanding.

However, it’s important to **ensure that your Nextflow process continues to run even if you log out of the HPC** (which you’ll likely want to do, as workflows can take hours or even days to complete!). 
There are two primary ways to achieve this: running Nextflow as a background process or using a persistent terminal with a terminal multiplexer.

### Nextflow as a background process

The `nextflow` command has the `-bg` option, which allows you to run the process in the background. 
If you want to check on the progress of your Nextflow run, you can review the `.nextflow.log` file, which logs the workflow’s progress in a text format.


### Persistent terminal

If you prefer interactive output on the terminal, we recommend using a **terminal multiplexer**.
A terminal multiplexer lets you open "virtual terminals" that continue running in the background, allowing processes to persist even if you close your window or disconnect from the HPC.

Two popular and widely available terminal multiplexers are [`screen`](https://linuxize.com/post/how-to-use-linux-screen/) and [`tmux`](https://github.com/tmux/tmux/wiki). 
Both work similarly, and we’ll briefly demonstrate their usage below.

The first step is to start a session:

- For `screen`: `screen -S demo` (note the uppercase `-S`)
- For `tmux`: `tmux -s demo`

This opens a session, which essentially looks like your regular terminal. 
However, you can **detach** from this session, leaving it running in the background and come back to it later. 

As an illustrative example, let's run the following command, which counts to 600 every second:

```bash
for i in {1..600}; do echo $i; sleep 1; done
```

This command will run for 10 minutes. 
Imagine this was your Nextflow process, printing pipeline progress on the screen.

If you want to log out of the HPC and leave this task running, you can detach the session, returning to the main terminal:

- For `screen`: press <kbd>Ctrl + A</kbd> then <kbd>D</kbd>
- For `tmux`: press <kbd>Ctrl + B</kbd> then <kbd>D</kbd>

Finally, log out from the HPC (e.g. using the `exit` command). 
Before logging out, it’s a good idea to **note the node you’re on**. 
One way to do this is with the `hostname` command.

Suppose your login node was called `login-09`. 
You can log back into this specific node as follows:

```bash
ssh username@login-09.train.bio
```

Once back in your terminal, you can list any running sessions:

- `screen -ls`
- `tmux ls`

You should see your `demo` session listed. 
To **reattach** to your session:

- `screen -r demo`
- `tmux attach -t demo`

You’ll find your command still running in the background!


## Exercises

:::{.callout-exercise}
#### Nextflow HPC config

We have a training HPC available with the following characteristics:

- **Job scheduler**: SLURM
- **Main queue/partition**: `normal`
- **Queue limits**: 8 CPUs and 20GB of RAM
- **Job duration**: maximum 24 hours
- **High-performance directory**: `/data/participant`, shared by both the login and compute nodes

First, **login to the HPC** with the command: `ssh participant@trainhpc`

In the directory `/data/participant/demo` you will find the files needed to run the `nf-core/demo` workflow, as demonstrated in the [previous chapter](03-nfcore.md#demo-nf-core-pipeline). 
Now, you will run this workflow on the HPC using SLURM as the executor for your analysis steps.

Here's what you need to do: 

- **Create a directory to cache the Singularity images** used by Nextflow. Consider whether this cache directory should be created in `/home/participant` or in `/data/participant`.
- **Create a configuration file** for running the pipeline, ensuring it includes the necessary settings for SLURM and respects the resource limits mentioned above.
- **Start a `screen` or `tmux` session** (your choice) to keep a persistent terminal running.
- **Edit the script `scripts/run_nfcore_demo.sh`** (e.g. using `nano`), adding the path to your configuration file to the Nextflow command with the `-c` option. 
- **Launch the script** using `bash scripts/run_nfcore_demo.sh`.
- **Detach the `screen`/`tmux` session** to return to your main terminal.
- **Check the queue** with the `squeue` SLURM command to see if Nextflow has started submitting jobs.

:::{.callout-answer}

1. **Login to the HPC** as instructed: 

    ```bash
    ssh participant@trainhpc
    ```

2. **Create the cache directory**. Since the working directory `/data` is high-performance and shared by both the login and compute nodes, it is the best location for the cache directory: 

    ```bash
    mkdir /data/participant/singularity-cache
    ```
    
3. **Create a configuration file** in the `/data/participant/demo` directory, which we call `trainhpc.config`:

    ```groovy
    process {
        executor = 'slurm'
        queue = 'normal'
    }

    executor {
        queueSize = '100'
        pollInterval = '2 min'
        queueStatInterval = '5 min'
        submitRateLimit = '50 sec'
        exitReadTimeout = '5 min'
    }

    params {
        max_memory = '20.GB'
        max_cpus = 8
        max_time = '24.h'
    }

    singularity {
        enabled = true
        cacheDir = '/data/singularity-cache'
    }
    ```

4. **Start a persistent terminal** with either `tmux -s demo` or `screen -S demo`.

5. **Edit the Nextflow script to include the configuration file** using the `-c` option: 

    ```bash
    nextflow run nf-core/demo \
      -profile "singularity" -revision "1.0.0" \
      -c "trainhpc.config" \
      --input "samplesheet.csv" \
      --outdir "results/qc" \
      --fasta "genome/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz"
    ```

6. Detach the `screen`/`tmux` session using: 
   - For `screen`: press <kbd>Ctrl + A</kbd> then <kbd>D</kbd>
   - For `tmux`: press <kbd>Ctrl + B</kbd> then <kbd>D</kbd>

7. Finally, use the squeue command to **verify that Nextflow has started submitting jobs** to the SLURM queue:

    ```bash
    squeue -u participant
    ```

You should see your jobs listed in the queue, confirming that the workflow is running.
You can check back on the progress of the workflow by re-attaching to your session with: 

- `screen -r demo`
- `tmux attach -t demo`

:::
:::

<!-- 
Eventually create an exercise in the advanced configuration section

:::{.callout-exercise}
- Add `errorStrategy` to avoid specific error
- [Optional/Advanced] Add a new label to an existing process using `withName`
- [Optional/Advanced] Make a process run only `when` a condition is met
::: 
-->


## Summary

::: callout-tip
#### Key points

- Nextflow pipelines can be configured to run on a HPC using a custom `config` file. This file should include:
  - Which job scheduler is in use (e.g. `slurm`, `lsf`, etc.).
  - The queue/partition name that you want to run the jobs in.
  - CPU and memory resource limits for that queue.
  - Job submission settings to keep the load on the scheduler low.
- To execute the workflow using the custom configuration file, use the `-c your.config` option with the `nextflow` command.
- The `nextflow` process can be run on the login node, however it is recommended to use a terminal multiplexer (`screen` or `tmux`) to have persistent terminal that can be retrieved after logout. 
:::