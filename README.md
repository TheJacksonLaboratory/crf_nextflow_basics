# Nextflow basics

This repo contains a series of relatively simple Nextflow pipelines intended to
  demonstrate some basic properties of Nextflow workflows and some common 
  situations that can be solved using channel operators. The examples are meant
  to be studied in the following order: `hello_minimal.nf`, `hello_vals.nf`, 
  `hello_files1.nf`, `hello_files2.nf`, and `hello_files3.nf`. They are written 
  using the recently introduced dsl2 syntax, which will become the default syntax
  in comming years.

---

## About Nextflow

Nextflow documentation can be found at https://www.nextflow.io/docs/latest/index.html.
  Nextflow is built on top of the Groovy programming language, whose documentation
  can be found here: https://groovy-lang.org/documentation.html. Groovy, in turn, is a
  superset of the Java programming language. The system-wide Java installed on
  Sumner is Java 8, which is documented at https://docs.oracle.com/javase/8/docs/api/.

A concise summary of commonly used Groovy syntax can be found within the Nextflow
  documentation at https://www.nextflow.io/docs/latest/script.html. Groovy is essentially
  a relaxed superset of Java, which does not require explicit type declarations, and
  drastically reduces the need for semicolons and parantheses in expressions. 

Nextflow adds to Groovy the concepts of `process`, `channel` and a set of operators for 
  channel objects. A pipeline is a series of processes which are tied together by 
  channels. The pipelines can be linear, in which case they can be quite simple to write. 
  However, in many cases, you may want the workflow to branch, then collect all the 
  outputs from the different branches into a final output dataset. In some cases, the 
  data from a branching workflow needs to be brought together into subsets corresponding 
  to e.g. individual inputs. This case, which is illustrated in example `hello_files1.nf`, 
  can be tackled in a variety of ways. One relatively clean and efficient way to do it is 
  by passing a grouping variable with each set of files, as outlined in `hello_files2.nf`, 
  and extended to a slightly more complex situation in `hello_files3.nf`. This solution
  requires familiarity with basic channel operators, which are introduced in the scripts.
  Working out your code so that the channels have the right contents can take quite a bit
  of work, and testing it by actually running each process can be very time consuming, if 
  any process takes a long time to run. Instead, we can use our knowledge of what files 
  are expected from each process to mock that process during code testing. This can be done
  using `stubs`, which are demonstrated in `hello_files3.nf`.

---

## Installing Nextflow

Installation instructions can be found here: https://www.nextflow.io/docs/latest/getstarted.html

In the following code block, we demo how to install Nextflow in your home directory. The 
  subdirectory names `~/opt` and `~/bin` are arbitrary. **It is also assumed that `~/bin` is
  in your `PATH`.** If not, you can add it in `~/.bashrc`, then `source ~/.bashrc` to load 
  the change into your current environment. 

```
mkdir -p ~/opt/nextflow
cd ~/opt/nextflow
curl -s https://get.nextflow.io | bash
mkdir -p ~/bin
ln -s $(pwd)/nextflow ~/bin
cd
which nextflow      ## should point back to ~/bin
nextflow -v         ## check install by invoking Nextflow, getting version

```

---

## Running Nextflow

Each script can be run using the syntax: `nextflow run hello_<x>.nf`. This 
  will result in the hidden file `.nextflow.log`, the hidden subdirectory 
  `.nextflow/` and the subdirectory `work/` being created in the directory from which
  Nextflow was invoked. The `.nextflow.log` file can be consulted for details
  in the case of errors. The `.nextflow` directory is used by Nextflow itself,
  and the `work/` directory contains a separate subdirectory for every execution
  of every process. Each such subdirectory will have a series of hidden files 
  matching the pattern `.command.*`, as well as a file named `.exitcode` which 
  contains the numeric exitcode of the corresponding process. In addition, if the
  process produces output files, they will be found in this subdirectory under 
  whatever name the process assigns.

The process execution subdirectory file `.command.sh` contains the `shell:` script 
  block, after interpolation of Groovy variables, and can be useful for debugging 
  the interpolation process. The `.command.run` file contains the actual bash script 
  executed by Nextflow, which includes the step in which the `.command.sh` script is 
  called. Other details in `.command.run` include loading of specified **modules** 
  (e.g. `singularity`) and the command lines used to load containers, including 
  **container directory bindings**. The file `.command.out` contains process 
  output to `stdout`, and `stderr` output is found in `.command.err`. In addition,
  there is a `.command.log` file, which contains the same output as `.command.out`, 
  but adds in output from e.g. the job queueing system (slurm on Sumner).

Nextflow outputs can be cleaned up by runnning `rm -r .nextflow* work` in the 
  directory from which Nextflow was invoked.

---

## Scripts

### hello\_minimal.nf

This script is pure Groovy (an extension of Java), without any Nextflow-isms, 
  other than the shebang line at the top of the script. Nevertheless, this script 
  can be run just like a regular Nextflow script, using the command 
  `nextflow run /path/to/hello_minimal.nf`. As with all Nextflow runs, a 
  `.nextflow.log` file, a `.nextflow/` directory, and a `work/` directory are 
  created in the directory from which Nextflow was invoked. This script does not 
  have any Nextflow `processes` defined, so no subdirectories or files are 
  introduced into `work/`, which remains empty when the job completes. Instead, 
  the outputs are simply printed to the console/stdout.

---

### hello\_vals.nf

An un-named workflow marks the entry point for most Nextflow dsl2 scripts; that workflow
  can create channels, pass them to named processes or named workflows, and capture
  output in order to pass to another process/workflow, etc. In this script, the
  un-named workflow builds a 'value channel' with several 'items' (in this example,
  each item is one word from a different language) in it and passes it to a process 
  which makes a separate greeting string for each item in the input channel. Each 
  resulting greeting becomes a single item in the output channel.

This script does not create any files explicitly, but just outputs the greetings
  to `stdout`.  Each process execution (one per item in the process input channel)
  will run under `work/` in a dedicated subdirectory. You can run `find work/` to 
  see the files deposited there, which are all hidden and begin with `.command`
  or `.exitcode`. If this script had explicit output files, those would appear in 
  the process's subdirectory under `work/` with whatever names the script assigned.

---

### hello\_files1.nf

This script demonstrates a problematic situation that can occur when a workflow
  branches, but the output of the branches needs to be combined so that all 
  outputs for a given item in the input channel can be brought back together.

In this case, files are generated that contain greetings in different languages
  (one greeting per input word). Then several types of checksum files are 
  generated for each greeting file. This script shows how a naive approach can 
  result in ambiguities when trying to combine the greeting file channel with 
  the checksum file channel so that the greeting file is correctly grouped with 
  the corresponding checksum files. How are we to get the outputs from 
  `ch_hello` and `ch_sums` combined together again, and how do we keep track of 
  which greeting corresponds to each resulting set of outputs?

This script does generate output files at each step, which you can see by running
  `find work`. Note that the output files are named identically in each directory,
  which is the nexflow way of doing things (don't need complex file naming logic
  to keep outputs separated -- Nextflow instead automatically uses different output 
  directories for each input item instead), but can result in ambiguities when 
  trying to track the outputs back to the corresponding inputs.

---

### hello\_files2.nf

In this example, we show how more complex item types (specifically tuples) can 
  be used to pass grouping variables through a process that can be used to 
  aggregate data from different processes for each group and associate outputs
  with inputs (the problem introduced in the last example).

Tuples are a Groovy data type for an ordered, immutable (cannot change/add/delete 
  elements) list of objects of arbitrary (and potentially different) types.
  Often (as below) we will use channel whose items are tuples composed of one or more 
  grouping variables (type `val`), along with a list of one or more path objects
  (type `path`). So our channels are often defined as `tuple val(group), path(files)`,
  where `group` will receive a grouping variable (typically a `String`) and `files`
  will get set to either a single `Path` object or an `ArrayList` of `Path` objects.

---

### hello\_files3.nf

This example extends the previous one by taking the input channel items and
  processing them separately with two sequential processes (`say_it` and 
  `check_sums`), but also processes them all together in another process 
  (`greet_list`). We then combine the outputs from all three processes into the 
  final output channel, `ch_reformat`. 

This example also introduces the use of stubs for quickly prototyping and
  debugging channel configurations. If we know what output files a process produces,
  we can mock those outputs using a `stub:` section within the corresponding
  process. Running these stubs lets us work out the code for channel manipulations
  without having to run the actual production process, which can be helpful in
  cases where that production process takes a long time to complete. In order to
  execute just the stubs, we run the script using `nextflow run -stub hello_files3.nf`.
  This results in the `stub:` block being executed for each process in place of the 
  process's `shell:` block. For production, we still run the script with the usual
  `nextflow run hello_files3.nf` invocation, in which case the `shell:` blocks are
  run and `stub:` blocks are skipped. If we run with the `-stub` option, the
  `work/` directory will have all the expected files, but they will all be empty
  (since the `stub:` script used the `touch` command to make the output files in 
  this case). But this is enough for checking that the channel structures are as
  expected at each step in the pipeline. Once the code is worked out with stubs, 
  you can then run the production code to check the `script:` blocks, after which
  everything should be working. 


