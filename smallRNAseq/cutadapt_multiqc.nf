// Small nextflow pipeline to process smallRNAseq data by cutting adapters provided from adapters.fa, remove reads that are too small and remove 3 first nt's from 5'-end; QC files and run multiqc on all QC results 
// Protocol that generated smallRNAseq: Takara SMARTer smRNA-Seq Kit for Illumina, Takara Unique Dual Index Kit
//

params.my_files = "/path/*.fastq.gz" 
params.adapters = "/path/adapters.fa" 
params.outdir = "results"





// cutadapt -m 15 -u 3 -a file:$primer_fa input.fastq > output.fastq
process CUTADAPT_QC {
    publishDir "${params.outdir}/trimmed", mode: 'copy', pattern: "_cutadapt.fastq.gz"
    publishDir "${params.outdir}/log", mode: 'copy', pattern: "_fastqc.html"
    input:
    path read
    path adapters_fa
    output:
    path("*_cutadapt.fastq.gz")
    path("*_fastqc.html"), emit: log_file

    script:
    """
    echo HI THERE $read $read.SimpleName $adapters_fa
    cutadapt -m 15 -u 3 -a file:$adapters_fa $read -o ${read.SimpleName}_cutadapt.fastq.gz
    fastqc ${read.SimpleName}_cutadapt.fastq.gz

    """
}


process MULTIQC {
    publishDir "${params.outdir}/log", mode: 'move'
    input:
    path 'log_file'
    output:
    path("multiqc*")
    script:
    """
    multiqc . -m fastqc

    """
}


workflow {
  fastq_files = Channel.fromPath(params.my_files)
  adapters_fa = params.adapters
  CUTADAPT_QC(fastq_files,adapters_fa)
  ch_qc = CUTADAPT_QC.out.log_file.collect()
  MULTIQC(ch_qc)
}
