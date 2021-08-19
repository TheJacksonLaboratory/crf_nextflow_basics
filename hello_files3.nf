#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*********************************************************************************

This example extends the previous one by taking the input channel items and
  processing them separately with one process (say_it and check_sums), but also
  processes them all together in another process (greet list). We then combine
  the outputs from all three processes into the final output channel, ch_reformat.

*********************************************************************************/

process say_it {

  input: val word
  output: tuple val(word), path('hello.out')

  shell:
    '''
    echo "!{word} world, my userid is $(whoami)" > hello.out
    '''

  stub:
    """
    touch hello.out
    """
}

process check_sums {

  input: tuple val(word), path(file_in)
  output: tuple val(word), path('*.{md5,sha256,sha512}')

  shell:
    '''
    echo "file_in: '!{file_in}'"
    md5sum '!{file_in}' > '!{file_in}.md5'
    sha256sum '!{file_in}' > '!{file_in}.sha256'
    sha512sum '!{file_in}' > '!{file_in}.sha512'
    '''

  // going back to 2x quotes, so groovy variables interpolated w/ "${x}" syntax:
  stub:
    """
    touch ${file_in}.md5
    touch ${file_in}.sha256
    touch ${file_in}.sha512
    """
}

process greet_list {

  input: val words_in
  output: path 'words.out'

  shell:
    '''
    echo "greeting words: !{words_in}" > 'words.out'
    '''

  stub:
    """
    touch words.out
    """
}

workflow {

  ch_in = channel.of('hello', 'ciao', 'hola', 'bonjour')
  ch_in.subscribe({ println("ch_in: $it\n") })

  // the 'collect()' operator collects all channel items and 
  //   returns them as single list item:

  ch_list = greet_list(ch_in.collect())
  ch_list.subscribe({ println("ch_list: $it\n") })

  ch_hello = say_it(ch_in)
  ch_hello.subscribe({ println("ch_hello: $it\n") })

  ch_sums = check_sums(ch_hello)
  ch_sums.subscribe({ println("ch_sums: $it\n") })

  // combine() operator combines all items from one channel
  //   with all items in a second channel:

  ch_join1 = ch_hello.combine(ch_list)
  ch_join1.subscribe({ println("ch_join1: $it\n") })

  // join() operator combines all items in two channels based 
  //   on grouping key which is (by default) first element in 
  //   each item:

  ch_join2 = ch_sums.join(ch_join1)
  ch_join2.subscribe({ println("ch_join2: $it\n") })

  ch_reformat = ch_join2.map({
    key = it.get(0)
    val = it.get(1).clone()
    val.add(it.get(2))
    val.add(it.get(3))
    return tuple(key, val)
  })
  ch_reformat.subscribe({ println("ch_reformat: $it\n") })
}

