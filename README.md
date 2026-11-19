# nf-frontend-canary

A small Nextflow pipeline. Use it to test how a run takes its inputs. It has:

- a parameter schema;
- a samplesheet schema;
- a `--fail` parameter that makes the run fail.

The pipeline defines no compute-related configuration or parameters.

## Run it

```
nextflow run . -profile test --outdir results
```

The results folder gets `summary.txt`, with one greeting for each sample.
