// only bwa mapping

params.fastq = "/some/path/*.fastq.gz"
params.bwa_idx = "data/genome.fa.{,amb,ann,bwt,pac,sa}"
params.outdir = "results"


process BWA_MAP {

    input:
    tuple val(sample_id), path(fastq)
    path bwa_idx

    output:
    tuple path("*.sai"), path("*.fastq.gz"), emit: sai_ch


    script:
    def idxbase = bwa_idx[0].baseName
    """
    bwa aln -t 3 -n 0.06 -o 3 -l 8 "${idxbase}" "${fastq}" > "${sample_id}.sai"

    """
}

// ${fq.baseName}
// tuple val(sample_id), path("${sample_id}_unmapped.bam"), emit: bam_un_long
process SAI2SAM {

    publishDir "${params.outdir}/mapped", mode: 'move', pattern: "*.sam"

    input:
    tuple path(sai), path(fastq)
    path bwa_idx

    output:
    path("*.sam")

    script:
    def idxbase = bwa_idx[0].baseName
    """
    bwa samse "${sai}" "${fastq}" "${idxbase}" -f "${sai.SimpleName}.sam"


    """
}


workflow {

    fastq_data = channel.fromPath(params.fastq).map { file -> tuple(file.SimpleName, file)}
    bwa_idx = file(params.bwa_idx)
    BWA_MAP(fastq_data, bwa_idx)
    ch_sai = BWA_MAP.out.sai_ch
    SAI2SAM(ch_sai,bwa_idx)

}
