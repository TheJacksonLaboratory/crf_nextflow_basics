#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process say_it {

  input: val word
  output: path 'hello.out'

  shell:
    '''
    echo "!{word} solar system, i'm in '$PWD'" > hello.out
    '''
}

// Put the sendMail() method wherever you want to send an email notification
// during your workflow. In this example, the email notification occurs after
// the say_it process completes
sendMail( to: 'frank.zappulla@jax.org',
subject: 'NextFlow pipeline completed!',
body: 'Hi, your nextflow pipeline has completed.' )
