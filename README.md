# Nextflow basics

This repo contains a series of relatively simple nextflow pipelines intended to
  demonstrate some basic properties of nextflow workflows and some common 
  situations that can be solved using channel operators. The examples are meant
  to be studied in the following order: `hello_minimal.nf`, `hello_vals.nf`, 
  `hello_files1.nf`, `hello_files2.nf`, and `hello_files3.nf`.

---

## About nextflow

Nextflow documentation can be found at `https://www.nextflow.io/docs/latest/index.html`.
  Nextflow is built on top of the Groovy programming language, whose documentation
  can be found here: https://groovy-lang.org/documentation.html. Groovy, in turn, is a
  superset of the Java programming language. The system-wide java installed on
  Sumner is Java 8, which is documented at https://docs.oracle.com/javase/8/docs/api/.

A concise summary of commonly used Groovy syntax can be found within the Nextflow
  documentation (https://www.nextflow.io/docs/latest/script.html).

---

## Installing nextflow

Installation instructions can be found here: https://www.nextflow.io/docs/latest/getstarted.html

In the following code block, we demo how to install nextflow in your home directory. The 
  subdirectory names (`~/opt` and `~/bin`) are arbitrary:

```
mkdir -p ~/opt/nextflow
cd ~/opt/nextflow
curl -s https://get.nextflow.io | bash
mkdir -p ~/bin
ln -s $(pwd)/nextflow ~/bin

```

---

## Running nextflow

Each script can be run using the syntax: `nextflow run hello_<x>.nf`. This 
  will result in the hidden file `.nextflow.log`, the hidden directory 
  `.nextflow/` and the directory `work/` being created in the directory from which
  nextflow was invoked. The `.nextflow.log` file can be consulted for details
  in the case of errors. The `.nextflow` directory is used by nextflow itself,
  and the `work/` directory contains a separate subdirectory for every execution
  of every process. Each such subdirectory will have a series of hidden files 
  matching the pattern `.command.*`, as well as a file named `.exitcode` which 
  contains the numeric exitcode of the corresponding process. 

The file `.command.sh` contains the `shell:` script block, after interpolation of 
  groovy variables. The `.command.run` file contains the actual shell script
  executed by nextflow, which includes a step in which the `.command.sh` script
  is executed. Other details in `.command.run` include loading of specified
  modules (e.g. `singularity`) and the command lines used to load containers,
  including directory bindings.

---

## Scripts

### hello\_minimal.nf

This script is pure groovy (an extension of java), without any nextflowisms, 
  other than the shebang line at the top of the script. Nevertheless, this script 
  can be run just like a regular nextflow script, using the command 
  `nextflow run /path/to/hello_minimal.nf`. As with all nextflow runs, a 
  `.nextflow.log` file, a `.nextflow/` directory, and a `work/` directory are 
  created in the directory from which nextflow was invoked. This script does not 
  have any nextflow `processes` defined, so no subdirectories or files are 
  introduced into `work/`, and it remains empty when the job completes. Instead, 
  the outputs are simply printed to the console/stdout.

---

### hello\_vals.nf

An un-named workflow marks the entry point for most nextflow dsl2 scripts; that workflow
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

---

### hello\_files1.nf

This script demonstrates a problematic situation that can occur when a workflow
  branches, but the output of the branches needs to be combined so that all 
  outputs for a given input channel item can be brought back together.

In this case, files are generated that contain greetings in different languages.
  Then several types of checksum files are generated for each greeting file. This 
  script shows how a naive approach can result in ambiguities when trying to
  combine the greeting file channel with the checksum file channel so that 
  the greeting file is correctly grouped with the corresponding checksum files.

---

### hello\_files2.nf

In this example, we show how more complex item types (specifically tuples) can 
  be used to pass grouping variables through a process that can be used to 
  aggregate data from different processes for each group.

Tuples are a groovy data type for an ordered, immutable (cannot change/add/delete 
  elements) list of objects of arbitrary (and potentially different) types.
  Often (as below) we will use channel whose items are tuples composed of one or more 
  grouping variables (type 'val'), along with a list of one or more path objects
  (type 'path').

---

### hello\_files3.nf

This example extends the previous one by taking the input channel items and
  processing them separately with one series of processes (`say_it` and 
  `check_sums`), but also processes them all together in another process 
  (`greet_list`). We then combine the outputs from all three processes into the 
  final output channel, `ch_reformat`.


