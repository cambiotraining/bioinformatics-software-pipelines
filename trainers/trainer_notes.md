# Trainer notes

## Introduction - Reproducible and scalable bioinformatics

- (30 min) Slide presentation
- Speaker notes in the slides


## Package managers

- (30 min) Slides
- (20 min) Exercise
- (10 min) Exercise solution/wrap-up
  - To save time, the lead trainer can prepare everything to quickly demonstrate the solution to the exercises while the participants are doing the exercise. 
    - Write the YAML file for exercise 1 and 2
    - Have the terminal ready (zoomed-in). 
  - For the wrap-up open exercise 1 YAML file in a text editor and show them how to use the `mamba env create` command.
  - Also demonstrate updating the environment (exercise 2).
  - Finally, run `mamba create -n ml tensorflow==2.17.0 pytorch==1.5.0` to demonstrate conflict error.

**Notes:**

- Be careful not to "improvise" too much in this session and demonstrate how to install different packages (or versions) not mentioned in the materials. This can lead to crashes if participants try to follow along and conda servers get overloaded. The packages and versions mentioned in the materials are already cached on the training machines, so they will install quickly.
- The online materials include a section on "Mixing package managers". We do not cover this in the live course, but if someone asks about this, you can point them to this section of the materials.


## Container Virtualisation

- (20 min) Slides
  - In slide 56 it can be nice to live demonstrate how to use Biocontainers and make session interactive by asking participants for a favourite software of their choice. However, the Biocontainers server sometimes hangs when live-demonstrating. Therefore: 
    - Before presenting, open the Biocontainers page for [seqkit](https://biocontainers.pro/tools/seqkit) and [bowtie2](https://biocontainers.pro/tools/bowtie2), so it's pre-loaded for the presentation.
    - Then show how people can find the command for singularity pull as well as other bits of information (e.g. how to install with conda). 
    - If Biocontainers is collaborating on the day, you can ask the audience to name some bioinformatics software. 
- (15 min) Exercise
- (10 min) Exercise solution/wrap-up
  - You can live demo the solution quickly as it shouldn't take too long.
  - Also clarify any recurrent questions that might have emerged during the exercise.


## Workflows

- (50 min) Slides + live demo
  - On slide titled "Hands-on time" switch to do a live demonstration `nf-core/demo` (speaker notes mention this in the relevant slide).
  - Live demo should take no more than ~5-10 minutes. Ask room to put green sticky notes to indicate they managed to start the pipeline.
  - The pipeline takes ~5 minutes to run. While it's running, continue with the slide about troubleshooting and introduce the exercise. 
- (50 min) Exercise time
  - Be clear to the participants that in exercise 2 they do not need to wait for the pipeline to finish (some take hours). The purpose is that they get the pipeline **running** successfully. Once most participants have it running, you can move on. 
  - While participants do the exercise, the lead trainer should get the viralrecon-ont workflow running on their terminal (takes ~20 min to complete). 
    This is so you have things done when it comes to wrap-up the exercise session.
- (10 min) Go through exercise solution and clarify issues that may have been brought up during exercise.
  - In the samplesheet exercise, we give them different ways to create the samplesheet, but you don't need to demonstrate each of these. 
  - Assuming you completed the viralrecon-ont pipeline, you can show the terminal with all steps successfully complete, and open the multiqc report as an example. 


## Workflows on HPC

- (30 min) Slides and demo `tmux`
  - Do a quick live demo of `tmux` by copying the "for loop" counter in the materials to illustrate the persistence of the terminal when you detach it. 
- (20-30 min) Exercise
  - While participants do the exercise, the lead trainer can create the config file and edit the nextflow script ahead of time to make the wrap-up quicker.
  - See how the pace of the room is, finish and wrap-up sooner if room seems tired, otherwise give them the full 30 minutes.
- (10 min) Wrap-up the exercise
  - Show how you mande the config, how you changed the script to use the config file.
  - Do all this within a `tmux` session, demonstrate detaching the session, run `squeue` to see jobs running, logout of the HPC and re-login to demonstrate that the session is still running in the background. 
- (5 min) go through the rest of the slides.

## Course wrap-up

- (15 min) Slides ("Reproducible and scalable bioinformatics") 
- Take final questions from the room. 
- Ask participants to fill in the feedback survey and point them to extra resources (for University highlight the drop-in clinic and Slack workspace).
