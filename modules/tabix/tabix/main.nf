process TABIX_TABIX {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(tab)

    output:
    tuple val(meta), path("*.tbi"), optional:true, emit: tbi
    tuple val(meta), path("*.csi"), optional:true, emit: csi
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    tabix $args $tab

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tabix: \$(echo \$(tabix -h 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${tab}.tbi
    cat <<-END_VERSIONS > versions.yml

    "${task.process}":
        tabix: \$(echo \$(tabix -h 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """
}
