#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*********************************************************************************
This script demonstrates a problematic situation that can occur when a workflow
  branches and the output of the branches needs to be combined so that all 
  outputs for a given input channel item can be brought back together.

In this case, files are generated that contain greetings in different languages.
  Then several types of checksum files are generated for each greeting file. This 
  script shows how a naive approach can result in ambiguities when trying to
  combine the greeting file channel with the checksum file channel so that 
  the greeting file is correctly grouped with the corresponding checksum files.

*********************************************************************************/

process say_it {

  input: val word
  output: path 'hello.out'

  shell:
    '''
    echo "!{word} solar system, i'm in '$PWD'" > hello.out
    '''
}

process check_sums {

  input: path file_in
  output: path '*.{md5,sha256,sha512}'

  shell:
    '''
    # can nest 1x or 2x quoted strings w/i triple single quoted multi-line string.
    echo "file_in: '!{file_in}'"
    md5sum '!{file_in}' > '!{file_in}.md5'
    sha256sum '!{file_in}' > '!{file_in}.sha256'
    sha512sum '!{file_in}' > '!{file_in}.sha512'
    '''
}

workflow {

  ch_in = channel.of('hello', 'ciao', 'hola', 'bonjour')
  ch_in.subscribe({ println("ch_in: $it") })

  ch_hello = say_it(ch_in)
  ch_hello.subscribe({ println("ch_hello: $it") })

  ch_sums = check_sums(ch_hello)
  ch_sums.subscribe({ println("ch_sums: $it") })
}

