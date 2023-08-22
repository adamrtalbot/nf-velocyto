process SAMTOOLS_SORT {

    conda     "bioconda::samtools=1.17"
    container "quay.io/biocontainers/samtools:1.17--h00cdaf9_0"

    cpus   2
    memory 2

    publishDir "${params.outdir}/samtools"

    input:
        tuple val(meta), path(bam)

    output:
        tuple val(meta), path("*.bam"), path("*.bai"), emit: bam

    script:
    def args = task.ext.args ?: ''
    def output = "cellsorted_${bam.baseName}.bam"
    """
    samtools \\
        sort -t CB -O BAM \\
        -@ $task.cpus \\
        -o ${output} \\
        -T ${bam.simpleName} \\
        $bam \\
    && samtools index -@ $task.cpus ${output}
    """
}

process VELOCYTO_RUN {

    conda     "bioconda::velocyto.py:0.17.17"
    container 'quay.io/biocontainers/velocyto.py:0.17.17--py38h24c8ff8_6'

    cpus 1 
    memory 2

    publishDir "${params.outdir}/velocyto"

    input:
        tuple val(meta) , path(bam), path(index)
        tuple val(meta2), path(gtf)
    output:
        path "**${bam.simpleName}*"

    script:
    """
    velocyto run \\
        -e ${bam.simpleName} \\
        -o . \\
        -@ ${task.cpus} \\
        --samtools-memory ${task.memory.mega.intValue()} \\
        $bam \\
        $gtf
    """
}


workflow {


    // Get BAM files from parameter
    Channel.fromFilePairs(params.bam + "{,.bai}", checkIfExists: true)
        .map { id, bam -> [ [id: id], bam[0], bam[1] ]}
        .set { bams }

    // Get GTF files from parameter
    Channel.fromPath(params.gtf, checkIfExists: true)
        .map { gtf -> [ [id: gtf.simpleName], gtf ] }
        .set { gtf }

    // Sort the BAMs by barcode
    if ( params.sort ) {
        bams = SAMTOOLS_SORT(bams.map { meta, bam, index -> [ meta, bam ] })
    }

    VELOCYTO_RUN(
        bams,
        gtf.collect()
    )
}