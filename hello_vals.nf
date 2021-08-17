#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*********************************************************************************

Un-named workflow marks entry point for most nextflow dsl2 scripts; that workflow
  can create channels, pass them to named processes or named workflows, and capture
  output in order to pass to another process/workflow, etc. In this case, the
  un-named workflow builds a 'value channel' with several 'items' (one word per 
  language) in it and passes it to a process which makes a separate greeting string 
  for each item.

This script does not create any files explicitly, but just outputs the greetings
  to stdout.  Each process execution (one per item in the process input channel)
  will run under `work/` in a dedicated subdirectory. You can run `find work/` to 
  see the files deposited there, which are all hidden and begin with `.command`
  or `.exitcode`. If this script had explicit output files, those would appear in 
  the process's subdirectory under `work/` with whatever names the script assigned.

*********************************************************************************/

process say_it {

  input: val word
  output: stdout

  //  Block labeled with `shell:` interpreted as bash; more flexible than `script:`, since
  //  wrapping block in tripled up single quotes results (a regular groovy multi-line
  //  string without `${x}` interpolation) in groovy variables interpolated 
  //  w/ `!{x}` notation (this is a nextflow extension of groovy), while bash 
  //  variables/processes are interpolated using w/ `${x}` notation, obviating need for 
  //  escapes for bash variables when using both. Can embed single or double quoted 
  //  strings within this block. 

  shell:

    // groovy code can go here:
    println("say_it:groovy:word: $word")

    '''
    # a bash comment; groovy '//' won't work in the triple 1x quoted block

    # can nest 1x or 2x quoted strings within a shell triple 1x quoted block;
    #   `word` is groovy variable; `whoami` is a bash command, and `PWD` is 
    #   a bash variable. The main command run here, is `echo`. You can
    #   run any command that would be available on the command line.
    
    echo "!{word} world, my userid is $(whoami), and my directory is $PWD"

    '''
}

workflow {

  // create a 'value' channel with several items in it:

  ch_in = channel.of('hello', 'hallo', 'hola', 'bonjour')

  // process each item in parallel; output orders can vary base on run times!!!

  ch_out = say_it(ch_in)
  ch_out.subscribe({ print("ch_out: $it") })
}

