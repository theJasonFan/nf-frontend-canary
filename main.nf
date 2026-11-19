#!/usr/bin/env nextflow

process GREET {
    tag "${sample}"

    input:
    tuple val(sample), val(greeting)

    output:
    path "${sample}.txt"

    script:
    """
    cat <<'GREETING_EOF' > '${sample}.txt'
${greeting}, ${sample}
GREETING_EOF
    """
}

process PUBLISH {
    publishDir params.outdir, mode: 'copy'

    input:
    path greetings

    output:
    path 'summary.txt'

    script:
    """
    cat \$(printf '%s\\n' ${greetings} | sort) > summary.txt
    """
}

process FAIL {
    script:
    """
    echo 'nf-frontend-canary: --fail is true, so this run fails on purpose.' >&2
    exit 1
    """
}

workflow {
    if (params.fail) {
        FAIL()
    }
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true, sep: params.input.endsWith('.tsv') ? '\t' : ',')
        .map { row -> tuple(row.sample, row.greeting) }
    ch_greetings = GREET(ch_samples)
    PUBLISH(ch_greetings.collect())
}
