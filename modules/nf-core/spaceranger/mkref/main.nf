process SPACERANGER_MKREF {
    tag "$fasta"
    label 'process_high'

    container "nf-core/spaceranger:3.0.0"

    input:
    path fasta
    path gtf
    val reference_name

    output:
    path "${reference_name}", emit: reference
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "SPACERANGER_MKREF module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    // --localcores is passed to the martian runtime and specifies the number of allocated jobs
    // --nthreads is passed to the STAR index generation.
    // see also https://github.com/nf-core/scrnaseq/issues/329
    """
    spaceranger \\
        mkref \\
        --genome=$reference_name \\
        --fasta=$fasta \\
        --genes=$gtf \\
        --localcores=${task.cpus} \\
        --localmem=${task.memory.toGiga()} \\
        --nthreads=${task.cpus} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaceranger: \$(spaceranger -V | sed -e "s/spaceranger spaceranger-//g")
    END_VERSIONS
    """
}
