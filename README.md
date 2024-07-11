SmallRNAseq:
Collection of workflows for processing and analysis of small RNAseq.
Speific procedures designed for data generated the following kits: 
Takara SMARTer smRNA-Seq Kit for Illumina, Takara Unique Dual Index Kit, Illumina NovaSeq6000 S2 reagent kit v.1.5 (200 cycles)
Adjust according your own requirements.



Example run for cutadapt.nf:
nextflow run cutadapt.nf -c cutadapt.config --my_files "/raw_data/smallRNA/*.fastq.gz" --adapters "/raw_data/smallRNA/qbic_adapters.fa" --outdir "/raw_data/smallRNA/ca_output/" -with-docker savytskanatalia/cutadapt
