#!/usr/bin/env nextflow

// single-line comment

/* multi-line comment start

This script is pure groovy (an extension of java), without any nextflowisms, other
  than the shebang line at the top of the script.

Nevertheless, this script can be run just like a regular nextflow script, using 
  the command `nextflow run /path/to/hello_minimal.nf`.

As with all nextflow runs, a `.nextflow.log` file, a `.nextflow/` directory, and
  a `work/` directory are created in the directory from which nextflow was invoked.

This script does not have any nextflow `processes` defined, so no subdirectories 
  or files are introduced into `work/`, and it remains empty when the job completes.

Instead, the outputs are simply printed to the console/stdout.

multi-line comment end: */

// initialize a groovy variable; type inferred from assignment rvalue:
greetings = [ 'hello', 'ciao', 'hola', 'bonjour' ]

println()       // blank-line to output for better readability

for(greeting : greetings) {
  println("$greeting within 2x quotes, with parens!")
  println "$greeting within 2x quotes, without parens!"
  println '$greeting with 1x quotes!\n'
}

