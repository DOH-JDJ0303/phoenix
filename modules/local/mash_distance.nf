process MASH_DIST {
    tag "$meta.id"
    label 'process_low'
    container "staphb/mash:2.3"

    input:
    tuple val(meta), path(query), val(fairy_outcome), path(reference)

    output:
    tuple val(meta), path("*.txt"), emit: dist
    path("versions.yml")          , emit: versions

    when:
    //if there are scaffolds left after filtering
    "${fairy_outcome[4]}" == "PASSED: More than 0 scaffolds in ${meta.id} after filtering."

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    db_version=\$(echo ${reference} | cut -d'_' -f1,2)
    # Setup to catch any issues while grabbing date from DB name
    if [[ "\${db_version}" = "" ]]; then
        db_version="REFSEQ_unknown"
    fi
    mash \\
        dist \\
        -p $task.cpus \\
        $args \\
        $reference \\
        $query > ${prefix}_\${db_version}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mash: \$(mash --version 2>&1)
        Mash Sketch: $reference
    END_VERSIONS
    """
}
