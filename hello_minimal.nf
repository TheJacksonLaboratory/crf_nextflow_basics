#!/usr/bin/env nextflow

// single-line comment

/* multi-line comment start

This script will create a ./work directory and ./.nextflow* files, but no output
  files in work directory. Instead, all it will do is print greeting to stdout.

This script is pure groovy (an extension of java), without any nextflowisms, other
  than the shebang line at the top of the script.

multi-line comment end: */

greet = 'hello'

println("$greet with parens!")
println "$greet without parens!"
println '$greet with single quotes!'

