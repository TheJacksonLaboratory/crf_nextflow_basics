#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*********************************************************************************
In this example, we show how more complex item types (specifically tuples) can 
  be used to pass grouping variables through a process that can be used to 
  aggregate data from different processes for each group.

Tuples are a groovy data type for an ordered, immutable (cannot change/add/delete 
  elements) list of objects of arbitrary (and potentially different) types.
  Often (as below) we will use channel whose items are tuples composed of one or more 
  grouping variables (type 'val'), along with a list of one or more path objects
  (type 'path').

*********************************************************************************/

process say_it {

  // the output channel items are tuples w/ a grouping variable, and a 
  //   corresponding path:

  input: val word
  output: tuple val(word), path('hello.out')

  shell:
    '''
    echo "!{word} world, my userid is $(whoami)" > hello.out
    '''
}

process check_sums {

  // both input and output channel items are tuples with grouping variable
  //   in first position; input channel items have single path in second position; 
  //   output channel items have list of paths in second position.

  input: tuple val(word), path(file_in)
  output: tuple val(word), path('*.{md5,sha256,sha512}')

  shell:
    '''
    # can nest single quoted strings w/i 3x single quoted multi-line string.
    echo "file_in: '!{file_in}'"
    md5sum '!{file_in}' > '!{file_in}.md5'
    sha256sum '!{file_in}' > '!{file_in}.sha256'
    sha512sum '!{file_in}' > '!{file_in}.sha512'
    '''
}

workflow {

  ch_in = channel.of('hello', 'ciao', 'hola', 'bonjour')
  ch_in.subscribe({ println("ch_in: $it\n") })

  ch_hello = say_it(ch_in)
  ch_hello.subscribe({ println("ch_hello: $it\n") })

  ch_sums = check_sums(ch_hello)
  ch_sums.subscribe({ println("ch_sums: $it\n") })

  // join channels on (by default) first element (grouping key) in each tuple:

  ch_join = ch_sums.join(ch_hello)
  ch_join.subscribe({ println("ch_join: $it\n") })

  // ch_join tuples are tuple(val, list(path), path); here, convert to 
  //   tuple(val, list(path)), by taking third element (the last path) and
  //   moving it into the second element (the list of paths). This will 
  //   simplify definition, use and manipulation of downstream channels:

  ch_reformat = ch_join.map({
    key = it.get(0)
    val = it.get(1).clone()
    val.add(it.get(2))
    return tuple(key, val)
  })
  ch_reformat.subscribe({ println("ch_reformat: $it\n") })
}

