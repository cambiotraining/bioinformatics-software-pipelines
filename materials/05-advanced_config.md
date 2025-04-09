---
pagetitle: "Software & Pipelines"
---

# Advanced Nextflow configuration

:::{.callout-tip}
#### Learning objectives

- List the different configuration files used by Nextflow pipelines and their hierarchy.
- Identify some of the configuration options available to customise how pipelines run.
- Customise the resources for specific tasks in the pipeline. 
- Define custom parameters to increase the flexibility of the pipeline usage.
:::


## Nextflow configuration

Nextflow is a powerful platform designed to scale your analyses by taking full advantage of your system's resources, allowing for controlled and scalable parallel processing. 
However, to take full advantage of these capabilities, pipeline configuration is often needed. 
You've already seen an example of this in the [previous chapter](04-nextflow_hpc.md) covering the configuration on a HPC cluster that uses SLURM as a job scheduler. 

In this section we cover further configuration options that can be used to run your Nextflow pipelines. 
According to the [documentation](https://www.nextflow.io/docs/latest/config.html#configuration-file), when a pipeline is launched, Nextflow searches for configuration files in several locations. 
Even if some of these files are not present, Nextflow still checks for them. 
Since these configuration files may contain conflicting settings, they are applied in the following order, from lowest to highest priority:

1. Parameters defined within the pipeline scripts (e.g. `main.nf`).
2. The configuration file located at `$HOME/.nextflow/config`.
3. The `nextflow.config` file in the project directory.
4. The `nextflow.config` file in the directory where the workflow is launched from.
5. One or more configuration files specified using the `-c <config-file>` option.
6. Parameters specified in a file using the `-params-file` option.
7. Parameters specified directly on the command line (`--something value`).

When multiple configuration options are used, they are merged, so that the settings in the first override the same settings appearing in the second, and so on. 


## Configuration of nf-core pipelines

All nf-core pipelines have a default configuration file called `nextflow.config`, which can be found on their respective GitHub repositories. 
Looking at these files can feel quite daunting, but they are informative of the default settings that the pipelines runs with and give an indication of how you can change the behaviour of the pipeline to match your needs. 

As an example, consider the [`nextflow.config` file for `nf-core/demo`](https://github.com/nf-core/demo/blob/1.0.0/nextflow.config) (open this file in a separate tab to compare with our notes). 

The nextflow.config file generally follows a structured format, with several key components:

- **Default parameters** (`params{}` scope): defines the default values for various parameters that the pipeline uses, such as input data, reference genomes, etc.
  - You may notice that several of these parameters match those [specified in the documentation](https://nf-co.re/demo//{{< var version.demo >}}/parameters/), and in fact they refer to the same thing. For example `--input`, `--genome` and `--outdir`. 

- **Include statements** (`includeConfig`): import other configuration files, which may set additional parameters or override defaults. For example:
  - `includeConfig 'conf/base.config'` imports the respective file [found in the repository](https://github.com/nf-core/demo/blob/1.0.0/conf/base.config). This "base" configuration file sets a more dynamic resource allocation, depending on the computational demands of each task (more on this later).
  - `includeConfig 'conf/igenomes.config'` imports [the igenomes configuration](https://github.com/nf-core/demo/blob/1.0.0/conf/igenomes.config), where you can see the genome keywords available and the source of the respective files. (Remember, these are often outdated, so we recommend that you download your own genomes from an up-to-date source.)

- **Profiles**: pre-configured settings tailored for specific use cases, such as running on different computing environments or enabling debugging features. 
  - You've already seen `-profile singularity` to manage software using Singularity containers. 
  - All nf-core pipelines also have `-profile test`, which runs the pipeline through a test dataset. This can be useful if you want to check that everything is installed correct.
  - More than one profile can be used, for example `nextflow run nf-core/demo -profile test,singularity`.

- **Container registry** settings: specifies where container images are downloaded from. The most common registry used is Red Hat's [quay.io](https://quay.io/).

- **Plugins** (`plugins{}` scope): plugins can be used to extend Nextflow's functionality. This section defines which plugins are enabled in the pipeline.
  - For example, the `nf-validation` plugin can be used to validate the input from the user, such as pipeline parameters and sample sheets.

- **Environment variables** (`env{}` scope): define environment variables that will be exported to the environment where the workflow tasks are executed. For example, the defaults for R, Python and Julia in the `nf-core/demo` are shown below, but these can be used in your own configuration file.

    ```groovy
    PYTHONNOUSERSITE = 1
    R_PROFILE_USER   = "/.Rprofile"
    R_ENVIRON_USER   = "/.Renviron"
    JULIA_DEPOT_PATH = "/usr/local/share/julia"
    ```

- **Shell directive** (`process.shell`): define a custom shell command for process scripts.
  - The default setting is to use `/bin/bash` with options like `-euo` and `pipefail`, which captures exit codes when piping commands. 
  - Advanced users may choose to change the shell or its behaviour.

- **Tracking and logging**: log files include information about task execution, resource usage and errors. These are by default output to the directory `pipeline_info`. 
  - These log files and reports are specified under the `timeline{}`, `report{}`, `trace{}` and `dag{}` scopes. 

- **Manifest** (`manifest{}` scope): metadata about the pipeline, including its name, author, description, main script, and version.

- **Custom functions**: custom functions can be included in the configuration to perform specific tasks, such as ensuring that resource requests do not exceed predefined limits.
  - These functions allow for a lot of flexibility to how pipelines run, in particular in managing the memory, time, and CPU resources, adjusting them based on the pipeline's parameters and the system's capabilities.
  - Functions are defined using the `def` directive. 

:::{.callout-note}
#### Groovy language

Groovy is a scripting language that is closely integrated with Java (on which Nextflow depends).
The configuration files and pipeline scripts in Nextflow are written in Groovy, allowing users to define their own custom parameters, logic, and functions.
:::


## Process selectors

In Nextflow, process selectors such as `withLabel` and `withName` are used to dynamically configure processes based on certain conditions, making workflows more flexible and adaptable. 
This feature allows you to apply specific configurations or actions to processes based on their names or labels.


### `withLabel`

When developers write pipelines they can assign a _label_ to each process of the pipeline. 
This is useful to indicate processes that share certain characteristics, such as being memory-intensive or CPU-intensive. 

For nf-core pipelines, developers use the following standard labels: 

| **Label Name**          | **CPUs** | **Memory** | **Time** |
|-------------------------|----------|------------|----------|
| `process_single`        | 1        | 6GB        | 4h       |
| `process_low`           | 2        | 12GB       | 4h       |
| `process_medium`        | 6        | 36GB       | 8h       |
| `process_high`          | 12       | 72GB       | 16h      |
| `process_long`          | -        | -          | 20h      |
| `process_high_memory`   | -        | 200GB      | -        |

The `withLabel` selector allows you to apply a configuration to all processes that are annotated with a particular label. 
This is specified in the `process` scope, allowing you to easily invoke desired configurations by adding the label to your process.

On a HPC in particular, we may want to use different queues/partitions depending on whether a task requires high memory or not. 
As an example, for the [Cascade Lake nodes at Cambridge](https://docs.hpc.cam.ac.uk/hpc/user-guide/cclake.html) you could set this configuration:

```groovy
process {
    executor = 'slurm'
    queue = 'cclake'
    
    withLabel: process_high_memory {
        queue = 'cclake-himem'
    }
}
```

The above configuration would use the `cclake` partition for all processes, except those labelled `process_high_memory`, which would be submitted to the `cclake-himem` partition instead. 


### `withName`

In the same manner, the `withName` selector can configure specific processes in your pipeline by its name. 
For example:

```groovy
process{
    withName: 'MULTIQC'{
            time    = { check_max( 2.h   * task.attempt, 'time' ) }
            cpus    = { check_max( 4 * task.attempt, 'cpus' ) }
            memory  = { check_max( 16.GB * task.attempt, 'memory')}
        }
    withLabel:error_retry {
        errorStrategy = 'retry'
        maxRetries    = 3
    }
}
```

Here, we target the MultiQC step of a workflow specifically and define the resources to be used by that task. 
In this example, we calculate a value dynamically, such that if the task fails (e.g. due to an out-of-memory error), it will be resubmitted but this time multiplying the initial values by 2 (2nd task attempt) and then 3 (3rd attempt) and so on. 

The maximum number of times a task is retried is defined in the `withLabel:error_retry {}` directive, also included in the configuration. 


### Selector expressions

Both `withLabel` and `withName` selectors allow the use of a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) in order to apply the same configuration to all processes matching the specified pattern. For example:

```groovy
process{
    withName: 'MULTIQC|FASTQC'{
            time    = { check_max( 2.h   * task.attempt, 'time' ) }
            cpus    = { check_max( 4 * task.attempt, 'cpus' ) }
            memory  = { check_max( 16.GB * task.attempt, 'memory')}
        }
}
```

In this case the configuration would apply to processes called "MULTIQC" **or** "FASTQC".
See more info and examples in the [Nextflow selector expressions documentation](https://www.nextflow.io/docs/latest/config.html#selector-expressions).


## Custom parameters

The [`params`](https://www.nextflow.io/docs/latest/config.html#scope-params) scope defines parameters that will be accessible in the pipeline script as `--name-of-your-parameter`. 
To achieve this you can prefix the parameter names with `params` or surround them by curly brackets. 

For example, let's say you wanted to define two options:

- Select the queue/partition name that jobs get submitted to on your HPC.
- Select the number of times Nextflow should retry to run a task in case of failure (e.g. due to low resources). 

```groovy
// define custom parameters
params {
  partition = 'cclake' // we use "cclake" as a default value
  n_retries = 2        // we use 2 as a default value
}

// define options to run the processes
process{
    executor = 'slurm'
    queue = params.partition // our custom parameter
    
    withLabel:error_retry {
        errorStrategy = 'retry'
        maxRetries    = params.n_retries // our custom parameter
    }
}
```

Note that instead of the `params {}` scope, we could have also defined the parameters like this: 

```groovy
params.partition = 'cclake'
params.n_retries = 2
```

Either way, having this as a configuration file, would now allow you to run the pipeline with these two options
For example: 

```bash
nextflow -c your_custom.config -profile singularity nf-core/demo \
  --partition 'icelake' \
  --n_retries 3 \
  ...etc...
```


## Institutional configuration

The nf-core community has developed a set of institutional configuration files, which can be used using the `-profile` option. 
These are listed at [nf-co.re/configs](https://nf-co.re/configs/) and include documentation of how to set up Nextflow on each specific institution. 

For example, at Cambridge University, you could run your pipelines with the option `-profile singularity,cambridge` to use the default Cambridge configuration. 


<!-- 
Hugo: I have commented this out, as it seems more like pipeline development than something the regular user might do.

### when

The `when` declaration in a process or configuration defines a condition that must be verified in order to execute the process. This can be any expression that evaluates a boolean value. This is very useful when running more complex workflows with different inputs and parameters.

For example:

```groovy
withName: 'FASTQC' {
        ext.when         = { params.fastqc == true) }

    }
```

Here, the `FASTQC` process will only run if the `param.fastqc` is set to `true` in your config file. 
-->


## Summary

::: callout-tip
#### Key points

- Nextflow configuration files define the behaviour of the pipeline run. Nextflow always looks for default files in specific locations ([documentation](https://www.nextflow.io/docs/latest/config.html#configuration-file)), and the user may also define other configuration files and use them with the `-c` option. 
- Pipelines can be extensively customised: parameters can be defined, resource allocation can be customised to the environment or task at hand, and environment variables defined. 
- The `withLabel` and `withName` directives can be used to tailor resource usage for specific tasks or groups of tasks, such as high-memory or CPU-heavy tasks. This could be used, for example, to submit different kinds of tasks to different queues/partitions on a HPC. 
- Users can define new parameters to the pipeline, which may be useful to adjust the behaviour of the pipeline in different environments, such as a HPC.
:::