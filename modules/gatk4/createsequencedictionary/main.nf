process GATK4_CREATESEQUENCEDICTIONARY {
    tag "$fasta"
    label 'process_medium'

    input:
    path fasta

    output:
    path "*.dict"       , emit: dict
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    def avail_mem = 6
    if (!task.memory) {
        log.info '[GATK CreateSequenceDictionary] Available memory not known - defaulting to 6GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    gatk --java-options "-Xmx${avail_mem}g" CreateSequenceDictionary \\
        --REFERENCE $fasta \\
        --URI $fasta \\
        --TMP_DIR . \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch test.dict

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
