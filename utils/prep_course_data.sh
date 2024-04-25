#!/bin/bash

#### ChIP-seq ####

# chipseq
wget -O chipseq_reads.zip "https://www.dropbox.com/scl/fo/z4cmuve1w1d35xua1nd9v/AKCbsPVoFv9RK4taeR4wKrQ?rlkey=dz1cqnwjf4rhktxu5nur9xg8u&st=wcf8tvmr&dl=1"
unzip chipseq_reads.zip -d chipseq

wget -O chipseq_genome.zip "https://www.dropbox.com/scl/fo/3jdyj7sivv4krsdfca2kn/AGMtbP0zvsF5RWa8uZSBL4E?rlkey=jxezn2xpyb999swrphrhpdguq&st=8mjwzjd0&dl=1"
unzip chipseq_genome.zip -d chipseq/genome/

wget -O chipseq_samplesheet.csv "https://www.dropbox.com/scl/fi/qxgovzlnbmyz211e5snw4/samplesheet.csv?rlkey=ktznsllql56ropxkk78owy6ov&st=gfxavb20&dl=1"
cat chipseq_samplesheet.csv | cut -d , -f 2,1,4,5 | sed 's/sample,fastq_1,antibody,control/name,fastq,antibody,input_control/' | sed 's|data/reads/||' | sed 's/.fastq.gz//' | tr ',' '\t' > chipseq/sample_info.tsv

rm chipseq/genome/GRCh38.109.chrom_sizes.tsv chipseq/genome/GRCh38.109.gtf.gz chipseq/genome/degs_nagarajan2017.csv


#### RNA-seq ####

# rnaseq - reads
wget -O rnaseq_reads.zip "https://www.dropbox.com/scl/fo/8c1rls797tydp05yofogq/AILyg8jk1UyN6L_7VgSAIqM?rlkey=faa0k56me69ceaev3k06fewi8&st=203t82j4&dl=1"
unzip rnaseq_reads.zip -d rnaseq

mv rnaseq/fastq rnaseq/reads
cat rnaseq/samplesheet.tsv | sed 's/SampleName/fastq/' > rnaseq/sample_info.tsv
rm rnaseq/nextflow_samplesheet.csv rnaseq/samplesheet.tsv rnaseq/samplesheet_corrected.tsv
# I've done further modifications to sample_info.tsv manually

# genome
mkdir rnaseq/genome
wget -O rnaseq/genome/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz "https://www.dropbox.com/scl/fi/4ic0mfpw5ol4l5nkrj7fb/Mus_musculus.GRCm38.dna_sm.chr14.fa.gz?rlkey=btiaaistbdyydzo8gbp1tf6vp&st=x6gw457j&dl=1"
wget -O rnaseq/genome/Mus_musculus.GRCm38.102.chr14.gtf.gz "https://www.dropbox.com/scl/fi/t15rzrf00u243lgzi4c1w/Mus_musculus.GRCm38.102.chr14.gtf.gz?rlkey=3a926xzw97o3jh80sdd5jf173&st=nnojx33j&dl=1"


#### Virus ####

# viralrecon illumina
wget -O sars_illumina.zip "https://www.dropbox.com/scl/fo/lbw1eucabhrd26ce4xf1j/h?rlkey=aelkvldj1hta8xaqnqzkydb7v&st=uwhar7jf&dl=1"
unzip sars_illumina.zip -d virus_illumina

mv virus_illumina/data/reads virus_illumina/reads
cat virus_illumina/samplesheet.csv | cut -d , -f 1,2 | sed 's/sample,fastq_1/name,fastq/' | sed 's|data/reads/||' | sed 's/_1.fastq.gz//' | tr ',' '\t' > virus_illumina/sample_info.tsv
rm -r virus_illumina/data virus_illumina/resources virus_illumina/scripts virus_illumina/samplesheet.csv virus_ont/sample_info.csv

mkdir virus_illumina/genome
wget -O virus_illumina/genome/nCoV-2019.reference.fasta "https://github.com/artic-network/artic-ncov2019/raw/master/primer_schemes/nCoV-2019/V3/nCoV-2019.reference.fasta"
wget -O virus_illumina/genome/nCoV-2019.annotation.gff.gz "https://github.com/nf-core/test-datasets/raw/viralrecon/genome/MN908947.3/GCA_009858895.3_ASM985889v3_genomic.200409.gff.gz"
wget -O virus_illumina/genome/nCoV-2019.V3.primer.bed "https://github.com/artic-network/artic-ncov2019/raw/master/primer_schemes/nCoV-2019/V3/nCoV-2019.primer.bed"


# viralrecon ONT
wget -O sars_ont.zip "https://www.dropbox.com/scl/fo/y37yqean6vamzr7yq8zey/h?rlkey=qdavkteytx8inv0qpvai11lby&st=8lcnf9w8&dl=1"
unzip sars_ont.zip -d virus_ont

mv virus_ont/data/fastq_pass virus_ont/fastq_pass
cat virus_ont/samplesheet.csv | sed 's/sample,barcode/name,ont_barcode/' | tr ',' '\t' > virus_ont/sample_info.tsv
rm -r virus_ont/data virus_ont/resources virus_ont/scripts virus_ont/samplesheet.csv virus_ont/sample_info.csv

mkdir virus_ont/genome
wget -O virus_ont/genome/nCoV-2019.reference.fasta "https://github.com/artic-network/artic-ncov2019/raw/master/primer_schemes/nCoV-2019/V3/nCoV-2019.reference.fasta"
wget -O virus_ont/genome/nCoV-2019.annotation.gff.gz "https://github.com/nf-core/test-datasets/raw/viralrecon/genome/MN908947.3/GCA_009858895.3_ASM985889v3_genomic.200409.gff.gz"
wget -O virus_ont/genome/nCoV-2019.V3.primer.bed "https://github.com/artic-network/artic-ncov2019/raw/master/primer_schemes/nCoV-2019/V3/nCoV-2019.primer.bed"


#### Bacteria ####

# not doing this as it requires several databases, which seems overkill

# # vibrio illumina
# for sra in ERR1485225 ERR1485227 ERR1485229 ERR1485231
# do
#   # prefetch
#   prefetch ${sra}

#   # validate
#   vdb-validate ${sra}

#   # convert
#   fasterq-dump --outdir  temp/ ${sra}

#   # subsample to 10% and gzip
#   cat temp/${sra}_1.fastq | seqtk sample -s 1 - 0.1 | gzip > reads/${sra}_1.downsampled.fastq.gz
#   cat temp/${sra}_2.fastq | seqtk sample -s 1 - 0.1 | gzip > reads/${sra}_2.downsampled.fastq.gz

#   rm -r ${sra} temp
# done


