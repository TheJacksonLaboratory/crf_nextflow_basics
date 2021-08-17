#!/usr/bin/env nextflow

// single-line comment

/* multi-line comment start

This script is pure groovy (an extension of java), without any nextflowisms, other
  than the shebang line at the top of the script.

Nevertheless, this script can be run just like a regular nextflow script, usin 
  the command `nextflow run /path/to/hello_minimal.nf`.

As with all nextflow runs, a `.nextflow.log` file, a `.nextflow/` directory, and
  a `work/` directory are created in the directory from which nextflow was invoked.

This script does not have any nextflow `processes` defined, so no subdirectories 
  or files are introduced into `work/`, and it remains empty when the job completes.

Instead, the outputs are simply printed to the console/stdout.

multi-line comment end: */

greet = 'hello'

println("$greet within 2x quotes, with parens!")
println "$greet within 2x quotes, without parens!"
println '$greet with 1x quotes!'

