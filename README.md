# WARNING: DO NOT USE THIS PIPELINE

## Velocyto POC in Nextflow

This is a crude pipeline for running Velocyto. The main aim is to test the difference in resource use between sorting and not sorting the pipeline, not to do anything useful. Good luck. Here be monsters.

To run:
```
nextflow run adamrtalbot/nf-velocyto --bam '*.bam' --gtf '*.gtf'
```

Optional parameters include:

`--sort`: Sort the BAMs by barcode and position as [per the Velocyto documentation](https://velocyto.org/velocyto.py/tutorial/cli.html#notes-on-first-runtime-and-parallelization). 

`--outdir`: Path to write results to. Defaults to `output`
