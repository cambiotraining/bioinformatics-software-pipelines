#!/bin/bash

set -euxo pipefail

## nf-core/demo

cd demo
nextflow run -profile "singularity" -revision "1.0.1" nf-core/demo \
  --input "samplesheet.csv" \
  --outdir "results/qc" \
  --fasta "genome/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz"


## nf-core/rnaseq

cd ../rnaseq

echo "sample,fastq_1,fastq_2,strandedness" > samplesheet.csv
tail -n +2 sample_info.tsv | awk 'BEGIN { FS="\t"; OFS="," }
{
  print $5, "reads/" $1 "_1.downsampled.fastq.gz", "reads/" $1 "_2.downsampled.fastq.gz", "auto"
}' >> samplesheet.csv

nextflow run nf-core/rnaseq \
  -r "3.18.0" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/rnaseq" \
  --gtf "$PWD/genome/Mus_musculus.GRCm38.102.chr14.gtf.gz" \
  --fasta "$PWD/genome/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz"  \
  --igenomes_ignore


## nf-core/chipseq

cd ../chipseq

echo "sample,fastq_1,fastq_2,replicate,antibody,control,control_replicate" > samplesheet.csv
tail -n +2 sample_info.tsv | awk 'BEGIN { FS="\t"; OFS="," }
{
  print $1, "reads/" $3 ".fastq.gz", "", $2, $4, $5, $6
}' >> samplesheet.csv

nextflow run nf-core/chipseq \
  -r "2.1.0" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/chipseq" \
  --gtf "$PWD/genome/GRCh38.109.chr21.gtf.gz" \
  --fasta "$PWD/genome/GRCh38.109.chr21.fasta.gz" \
  --blacklist "$PWD/genome/ENCFF356LFX_exclusion_lists.chr21.bed.gz" \
  --read_length 100
  
  
## nf-core/viralrecon illumina

cd ../virus_illumina

echo "sample,fastq_1,fastq_2" > samplesheet.csv
tail -n +2 sample_info.tsv | awk 'BEGIN { FS="\t"; OFS="," }
{
  print $1, "reads/" $2 "_1.fastq.gz", "reads/" $2 "_2.fastq.gz"
}' >> samplesheet.csv

nextflow run nf-core/viralrecon \
  -r "2.6.0" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/viralrecon" \
  --platform "illumina" \
  --protocol "amplicon" \
  --gtf "$PWD/genome/nCoV-2019.annotation.gff.gz" \
  --fasta "$PWD/genome/nCoV-2019.reference.fasta" \
  --primer_bed "$PWD/genome/nCoV-2019.V3.primer.bed" \
  --skip_assembly --skip_asciigenome \
  --skip_pangolin --skip_nextclade
  

## nf-core/viralrecon ont

cd ../virus_ont

echo "sample,barcode" > samplesheet.csv
tail -n +2 sample_info.tsv | sed 's/\t/,/' >> samplesheet.csv

nextflow run nf-core/viralrecon \
  -r "2.6.0" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --fastq_dir "fastq_pass/" \
  --outdir "results/viralrecon" \
  --platform "nanopore" \
  --protocol "amplicon" \
  --genome "MN908947.3" \
  --primer_set "artic" \
  --primer_set_version "3" \
  --artic_minion_medaka_model "r941_min_fast_g303" \
  --artic_minion_caller "medaka" \
  --skip_assembly --skip_asciigenome \
  --skip_pangolin --skip_nextclade