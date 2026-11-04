#!/bin/bash

set -euxo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/version_utils.sh"

## nf-core/demo

demo_version=$(get_version demo)
rnaseq_version=$(get_version rnaseq)
chipseq_version=$(get_version chipseq)
viralrecon_version=$(get_version viralrecon)

cd demo
nextflow run -profile "singularity" -revision "$demo_version" nf-core/demo \
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
  -r "$rnaseq_version" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/rnaseq" \
  --gtf "$PWD/genome/Mus_musculus.GRCm38.102.chr14.gtf.gz" \
  --fasta "$PWD/genome/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz"  \
  --igenomes_ignore \
  --skip_alignment

## nf-core/chipseq

cd ../chipseq

echo "sample,fastq_1,fastq_2,replicate,antibody,control,control_replicate" > samplesheet.csv
tail -n +2 sample_info.tsv | awk 'BEGIN { FS="\t"; OFS="," }
{
  print $1, "reads/" $3 ".fastq.gz", "", $2, $4, $5, $6
}' >> samplesheet.csv

nextflow run nf-core/chipseq \
  -r "$chipseq_version" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/chipseq" \
  --gtf "$PWD/genome/GRCh38.109.chr21.gtf.gz" \
  --fasta "$PWD/genome/GRCh38.109.chr21.fasta.gz" \
  --blacklist "$PWD/genome/ENCFF356LFX_exclusion_lists.chr21.bed.gz" \
  --read_length 100 \
  --skip_preseq
  
  
## nf-core/viralrecon illumina

cd ../virus_illumina

echo "sample,fastq_1,fastq_2" > samplesheet.csv
tail -n +2 sample_info.tsv | awk 'BEGIN { FS="\t"; OFS="," }
{
  print $1, "reads/" $2 "_1.fastq.gz", "reads/" $2 "_2.fastq.gz"
}' >> samplesheet.csv

nextflow run nf-core/viralrecon \
  -r "$viralrecon_version" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --outdir "results/viralrecon" \
  --platform "illumina" \
  --protocol "amplicon" \
  --gff "$PWD/genome/nCoV-2019.annotation.gff.gz" \
  --fasta "$PWD/genome/nCoV-2019.reference.fasta" \
  --primer_bed "$PWD/genome/nCoV-2019.V3.primer.bed" \
  --skip_assembly --skip_freyja \
  --skip_pangolin --skip_nextclade
  

## nf-core/viralrecon ont

cd ../virus_ont

echo "sample,barcode" > samplesheet.csv
tail -n +2 sample_info.tsv | sed 's/\t/,/' >> samplesheet.csv

nextflow run nf-core/viralrecon \
  -r "$viralrecon_version" \
  -profile "singularity" \
  --input "samplesheet.csv" \
  --fastq_dir "fastq_pass/" \
  --outdir "results/viralrecon" \
  --platform "nanopore" \
  --protocol "amplicon" \
  --genome "MN908947.3" \
  --primer_set "artic" \
  --primer_set_version "3" \
  --artic_minion_model "r941_prom_sup_g5014" \
  --skip_assembly --skip_freyja \
  --skip_pangolin --skip_nextclade
