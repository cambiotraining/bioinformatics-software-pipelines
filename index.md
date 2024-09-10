---
title: "Managing Bioinformatics Software and Pipelines"
date: today
number-sections: false
---

## Overview 

Setting up a computer for running bioinformatic analysis can be a challenging process. 
Most bioinformatic applications involve the use of many different software packages, which are often part of long data processing pipelines. 
These materials cover how you can overcome these challenges by using '''package managers''' and '''workflow management software'''.
You will learn about common tools to install software, with a particular focus on the popular `conda`/`mamba` package manager. 
We also cover how you can use pre-existing software containers (_Singularity_), which are a way to further abstract software requirements by bundling them into virtual environments. 
Finally, you will learn how to use automated pipelines to streamline your bioinformatic analysis. 
We focus on the _Nextflow_ software, introducing you to its core pipelines and how you can configure it to run at scale on HPC clusters.

::: {.callout-tip}
### Learning Objectives

- Recognise the utility of package managers in bioinformatics.
- Use package managers to create and maintain complex software environments.
- Describe how containerisation solutions can be used to solve the problem of software dependencies.
- Install, configure and run automated analysis pipelines developed and maintained by the bioinformatics community.
:::


### Target Audience

This course is aimed at researchers who are just starting to run bioinformatics analysis on their own. 
It may be particularly useful if you attended previous training on specific applications (e.g. RNA-seq, ChIP-seq, variant calling, etc.), but are struggling on how to setup and start your analysis. 
It is also useful if you are using a HPC cluster and would like to learn how to manage software and automate and parallelise your analysis using available pipelines. 

Note that the focus of this course is to introduce these tools from a _hands-on and practical user perspective_, not as a developer. 
Therefore, we will not teach you how to write your own pipelines, or create your own software containers or installation recipes. 

We will also not cover the details of any specific type of bioinformatic analysis. 
The idea of this course is to introduce the computational tools to get your work done, not to teach how those tools work. 


### Prerequisites

- **Unix command line (required)**: you should be comfortable using the command line to navigate your filesystem and understand the basic structure of a command.
- NGS data analysis (desirable): if you are familiar with the basic analysis of a specific type of NGS data (e.g. RNA-seq, ChIP-seq, WGS), it will help you to engage with some of the examples used in the course. 
  However, you can attend this course even if you haven't done any of those analysis before. 


<!-- Training Developer note: comment the following section out if you did not assign levels to your exercises -->
### Exercises

Exercises in these materials are labelled according to their level of difficulty:

| Level | Description |
| ----: | :---------- |
| {{< fa solid star >}} {{< fa regular star >}} {{< fa regular star >}} | Exercises in level 1 are simpler and designed to get you familiar with the concepts and syntax covered in the course. |
| {{< fa solid star >}} {{< fa solid star >}} {{< fa regular star >}} | Exercises in level 2 combine different concepts together and apply it to a given task. |
| {{< fa solid star >}} {{< fa solid star >}} {{< fa solid star >}} | Exercises in level 3 require going beyond the concepts and syntax introduced to solve new problems. |


## Citation & Authors

Please cite these materials if:

- You adapted or used any of them in your own teaching.
- These materials were useful for your research work. For example, you can cite us in the methods section of your paper: "We carried our analyses based on the recommendations in _YourReferenceHere_".

<!-- 
This is generated automatically from the CITATION.cff file. 
If you think you should be added as an author, please get in touch with us.
-->

{{< citation CITATION.cff >}}


<!-- 
## Acknowledgements

- List any other sources of materials that were used.
- Or other people that may have advised during the material development (but are not authors).
-->