---
title: "Advanced Nextflow configuration"
---

Understanding Nextflow config files

- Get to know the different config files from Nextflow pipelines
- Be able to modify them appropriately


### Nextflow configuration
Nextflow is a quite powerful platform to scale your analysis, it is able to take advantage of your system and parallelise processing in a controlled and scalable manner. If used with an `executor` such as [SLURM](https://slurm.schedmd.com/documentation.html) or [AWS](https://aws.amazon.com/), a nextflow pipeline can submit many processes at the same time and track the progress. However, to make full use of the workflow manager capabilities careful configuration is still needed. For instance, not always is the system able to keep up with Nextflow submission rate (specially schedulers such as SLURM). **Configuring your pipeline correctly is very important.** It will allow you to use the HPC resources properly and in a efficient manner.


**From nextflow [docs](https://www.nextflow.io/docs/latest/config.html#configuration-file):**

When a pipeline script is launched, Nextflow checks for configuration files in multiple locations (even if they are not there). Since each configuration file may contain conflicting settings, they are applied in the following order (from lowest to highest priority):

1. Parameters defined in pipeline scripts (e.g. `main.nf`)

2. The config file `$HOME/.nextflow/config`

3. The config file `nextflow.config` in the project directory

4. The config file `nextflow.config` in the launch directory

5. Config file specified using the `-c <config-file>` option

6. Parameters specified in a params file (`-params-file` option)

7. Parameters specified on the command line (`--something value`)

When more than one of these options for specifying configurations are used, they are merged, so that the settings in the first override the same settings appearing in the second, and so on. 

#### nf-core .nextflow.config explained
If using an `nf-core` pipeline you might have seen some of these files before with some settings already set up for you. These configuration files can be somehow daunting as they are long and contain lots of settings and information that you are not necessarily familiar with. Here, we explain for your reference the structure and what of this components are in case you ever needed. Let's take a look at the `nf-core/demo` `nextflow.config`. Normally it will follow this structure:

- Default parameters:
  
```conf
params {

    // Input options
    input                       = null

    // References
    genome                     = null
    igenomes_base              = 's3://ngi-igenomes/igenomes/'
    igenomes_ignore            = false
    
}

```

- Include statements:
```conf
// Load base.config by default for all pipelines
includeConfig 'conf/base.config'

// {...}

// Load igenomes.config if required
if (!params.igenomes_ignore) {
    includeConfig 'conf/igenomes.config'
} else {
    params.genomes = [:]
}

// {...}
// Load modules.config for DSL2 module specific options
includeConfig 'conf/modules.config'

```

- Profiles, these are default configurations for specific institutions:
```conf
// Load nf-core custom profiles from different Institutions
try {
    includeConfig "${params.custom_config_base}/nfcore_custom.config"
} catch (Exception e) {
    System.err.println("WARNING: Could not load nf-core/config profiles: ${params.custom_config_base}/nfcore_custom.config")
}
```

- Profiles for `executors`, debugging and/or testing. This can be activated through `--profile` option such as `nextflow run nf-core/demo -r dev --profile test,singularity`. Here we are specifying the `test` configuration and to run the processes with `singularity`.
```conf
profiles {
    debug {
        dumpHashes              = true
        process.beforeScript    = 'echo $HOSTNAME'
        cleanup                 = false
        nextflow.enable.configProcessNamesValidation = true
    }
    conda {
        conda.enabled           = true
        docker.enabled          = false
        singularity.enabled     = false
        podman.enabled          = false
        shifter.enabled         = false
        charliecloud.enabled    = false
        conda.channels          = ['conda-forge', 'bioconda', 'defaults']
        apptainer.enabled       = false
    }
// {...}
    test      { includeConfig 'conf/test.config'      } 
    test_full { includeConfig 'conf/test_full.config' }
}

// Disable process selector warnings by default. Use debug profile to enable warnings.
nextflow.enable.configProcessNamesValidation = false
```

- Defaults for containers registry (where containers are hold). NExtflow mostly uses (quay.io)[quay.io]. 
```conf
apptainer.registry   = 'quay.io'
docker.registry      = 'quay.io'
podman.registry      = 'quay.io'
singularity.registry = 'quay.io'
```

- Plugins:
```conf
// Nextflow plugins
plugins {
    id 'nf-validation@1.1.3' // Validation of pipeline parameters and creation of an input channel from a sample sheet
}
```

- Scope `env`: the `env` scope allows the definition one or more variables that will be exported into the environment where workflow tasks are executed.
```conf
env {
    PYTHONNOUSERSITE = 1
    R_PROFILE_USER   = "/.Rprofile"
    R_ENVIRON_USER   = "/.Renviron"
    JULIA_DEPOT_PATH = "/usr/local/share/julia"
}
```

- Setting up `shell` directive: the shell directive allows you to define a custom shell command for process scripts.

```conf
// Capture exit codes from upstream processes when piping
process.shell = ['/bin/bash', '-euo', 'pipefail']
```

- Tracking set up: by default you will find nextflow logs and processese execution information in `pipeline_info/`
```conf
def trace_timestamp = new java.util.Date().format( 'yyyy-MM-dd_HH-mm-ss')
timeline {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_timeline_${trace_timestamp}.html"
}
report {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_report_${trace_timestamp}.html"
}
trace {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_trace_${trace_timestamp}.txt"
}
dag {
    enabled = true
    file    = "${params.outdir}/pipeline_info/pipeline_dag_${trace_timestamp}.html"
}****
```

- A manifest, with some info about the pipeline:
```conf
manifest {
    name            = 'nf-core/demo'
    author          = """Christopher Hakkaart"""
    homePage        = 'https://github.com/nf-core/demo'
    description     = """An nf-core demo pipeline"""
    mainScript      = 'main.nf'
    nextflowVersion = '!>=23.04.0'
    version         = '1.0.0'
    doi             = ''
}
```

- Functions:
```conf
// Function to ensure that resource requirements don't go beyond
// a maximum limit
def check_max(obj, type) {
    if (type == 'memory') {
        try {
            if (obj.compareTo(params.max_memory as nextflow.util.MemoryUnit) == 1)
                return params.max_memory as nextflow.util.MemoryUnit
            else
                return obj
        } catch (all) {
            println "   ### ERROR ###   Max memory '${params.max_memory}' is not valid! Using default value: $obj"
            return obj
        }
    } else if (type == 'time') {
        try {
            if (obj.compareTo(params.max_time as nextflow.util.Duration) == 1)
                return params.max_time as nextflow.util.Duration
            else
                return obj
        } catch (all) {
            println "   ### ERROR ###   Max time '${params.max_time}' is not valid! Using default value: $obj"
            return obj
        }
    } else if (type == 'cpus') {
        try {
            return Math.min( obj, params.max_cpus as int )
        } catch (all) {
            println "   ### ERROR ###   Max cpus '${params.max_cpus}' is not valid! Using default value: $obj"
            return obj
        }
    }
}
```


## Process selectors `withLabel` and `withName`

In Nextflow, a process selector is used to dynamically choose which process to execute based on certain conditions. This feature is useful for creating flexible and adaptable workflows that can make decisions at runtime.  `withName` and `withLabel` are methods used to apply specific configurations or actions to processes based on their names or labels. These methods are particularly useful for configuring resources, execution environments, and other process-specific settings in a streamlined and scalable manner.


## withLabel

The `withLabel` selectors allows to specify a configuration to all processes annotated with a `label`. This is specified in the [`process`](https://www.nextflow.io/docs/latest/config.html#scope-process) scope. Hence, the `label` directive allows the annotation of processes with mnemonic identifier of your choice. Meaning that you can specify the desired resources for a process from the config and then invoking those parameters adding this label to your process. 

```config
process {
    withLabel: big_mem {
        cpus = 16
        memory = 64.GB
        queue = 'training-himem'
    }
}
```

And then this can be invoked into as many processes as you need as follows:

```config
process RUN_COMMAND {
    label 'big_mem'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.{vcf}"), emit: output

    script:
    """
    command <params> <output>
    """
}
```

## withName

In the same manner, the `withName` selector can configure specific processes in your pipeline by its name. For example:

```config
process{
    withName: 'MULTIQC'{
            time    = { check_max( 2.h   * task.attempt, 'time' ) }
            cpus    = { check_max( 4 * task.attempt, 'cpus' ) }
            memory  = { check_max( 16.GB * task.attempt, 'memory')}
        }
}
```

### Selector expressions

Both `withLabel` and `withName` selectors allow the use of a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) in order to apply the same configuration to all processes matching the specified pattern. For example:

```config
process{
    withName: 'MULTIQC|FASTQC'{
            time    = { check_max( 2.h   * task.attempt, 'time' ) }
            cpus    = { check_max( 4 * task.attempt, 'cpus' ) }
            memory  = { check_max( 16.GB * task.attempt, 'memory')}
        }
}
```

See more info and examples [here](https://www.nextflow.io/docs/latest/config.html#selector-expressions)

### Scope params

The [`params`](https://www.nextflow.io/docs/latest/config.html#scope-params) scope defines parameters that will be accessible in the pipeline script. Simply prefix the parameter names with the `params` scope or surround them by curly brackets, as shown below:

```config
params.custom_param = 123
params.another_param = 'string value .. '

params {
    fastqc = true
}

if params.custom_param == 123 {

    RUN_COMMAND1()

} else {

    RUN_COMMAND2()

}
```


### when
The `when` declaration in a process or configuration defines a condition that must be verified in order to execute the process. This can be any expression that evaluates a boolean value. This is very useful when running more complex workflows with different inputs and parameters.

For example:

```config
withName: 'FASTQC' {
        ext.when         = { params.fastqc == true) }

    }
```

Here, the `FASTQC` process will only run if the `param.fastqc` is set to `true` in your config file.

You can achieve this by using the `when` directive within a process to specify conditions under which the process should run.


Example:

```
process bigTask {
  label 'process_single'

  '''
  <task script>
  '''
}
```

Then, these can be configured with the cluster specs. This can be added to your `cambridge_hpc.config` as follows under the `process` directive:

```conf
  // Settings below are for CSD3 nodes detailed at
  //   https://docs.hpc.cam.ac.uk/hpc/index.html
  // Current resources (Jun 2023):
  //   icelake: 76 CPUs; 3380 MiB per cpu; 6760 MiB per cpu (himem)
  //   cclake: 56 CPUs; 3420 MiB per cpu; 6840 MiB per cpu (himem)
  // The values used below were chosen to be multiples of these resources
  // assuming a maximum of 2 retries

  // Using himem partition to ensure enough memory for single-CPU jobs
  withLabel:process_single {
      cpus   = { check_max( 1                  , 'cpus'    ) }
      memory = { check_max( 6800MB * task.attempt, 'memory'  ) }
      time   = { check_max( 4.h  * task.attempt, 'time'    ) }
      clusterOptions = '--account LEYSER-SL2-CPU --partition cclake-himem'
  }
  // 4 CPUs + 13GB RAM
  withLabel:process_low {
      cpus   = { check_max( 4     * task.attempt, 'cpus'    ) }
      memory = { check_max( 13.GB * task.attempt, 'memory'  ) }
      time   = { check_max( 4.h   * task.attempt, 'time'    ) }
      clusterOptions = '--account LEYSER-SL2-CPU --partition cclake'
  }
  // 8 CPUs + 27GB RAM
  withLabel:process_medium {
      cpus   = { check_max( 8     * task.attempt, 'cpus'    ) }
      memory = { check_max( 27.GB * task.attempt, 'memory'  ) }
      time   = { check_max( 8.h   * task.attempt, 'time'    ) }
      clusterOptions = '--account LEYSER-SL2-CPU --partition cclake'
  }
  // 12 CPUs + 40GB RAM
  withLabel:process_high {
      cpus   = { check_max( 12    * task.attempt, 'cpus'    ) }
      memory = { check_max( 40.GB * task.attempt, 'memory')}
      time   = { check_max( 8.h  * task.attempt, 'time'    ) }
      clusterOptions = '--account LEYSER-SL2-CPU --partition cclake'
  }
  // Going by chunks of 12h (2 retries should bring it to max of 36h)
  withLabel:process_long {
      time   = { check_max( 12.h  * task.attempt, 'time'    ) }
  }
  // A multiple of 3 should bring it to max resources on cclake-himem
  withLabel:process_high_memory {
      cpus   = { check_max( 18     * task.attempt, 'cpus'    ) }
      memory = { check_max( 127.GB * task.attempt, 'memory' ) }
      clusterOptions = '--account LEYSER-SL2-CPU --partition cclake-himem'
  }
  withLabel:error_ignore {
      errorStrategy = 'ignore'
  }
  withLabel:error_retry {
      errorStrategy = 'retry'
      maxRetries    = '2'
  }
```


