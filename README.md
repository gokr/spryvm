# SpryVM

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble_js.png)](https://github.com/yglukhov/nimble-tag)

[![Build Status](https://travis-ci.org/gokr/spryvm.svg?branch=master)](https://travis-ci.org/gokr/spryvm)

[![Join the chat at https://gitter.im/gokr/spry](https://badges.gitter.im/gokr/spry.svg)](https://gitter.im/gokr/spry?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)


This is the VM for the [Spry language](http://sprylang.org), packaged as a Nim library.

# What is this?

This is **not where you start out with Spry**, instead take a look at [the language website](http://sprylang.org) and install the [Spry](http://github.com/gork/spry) nimble package that in turn **depends** on this package to implement usable Spry interpreters.

# Installation

SpryVM mainly depends on Nim, so it should work fine on Windows, OSX, Linux etc, but
for the moment **I use Linux for Spry development**. The shell scripts will probably be rewritten in nimscript and thus everything can be fully cross platform - feel free to help me with that!

## Linux
The following should work on a Ubuntu/Debian, adapt accordingly for other distros.

1. Get [Nim](http://www.nim-lang.org)! I recommend using [choosenim](https://github.com/dom96/choosenim) or just following the official [instructions](http://nim-lang.org/download.html). Using choosenim it's as simple as:

    ```
    sudo apt install gcc
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh
    ```

2. Install dependencies, currently this is libsnappy-dev (or libsnappy1v5):
    ```
    sudo apt install libsnappy-dev
    ```

3. Clone this repo. Then run `nimble install` in it.

4. Finally run all tests using `cd tests && ./run.sh` (runjs.sh is for running them in nodejs, but not fully green right now). Tests should be green for **Nim 0.20.2**.

So now that you have installed Spry, you can proceed to play with the samples in the `examples` directory, see README in there for details.

## OSX
The following should work on OSX.

0. Install [Homebrew](https://brew.sh) unless you already have it.

1. Get [Nim](http://www.nim-lang.org)! I recommend using [choosenim](https://github.com/dom96/choosenim) or just following the official [instructions](http://nim-lang.org/download.html). Using choosenim it's as simple as:

    ```
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh
    ```

2. Install dependencies, currently this is only snappy and we can get it using:
    ```
    brew install snappy
    ```

3. Clone this repo. Then run `nimble install` in it. That should hopefully end up with `spry` and `ispry` built and in your path.

4. Finally run all tests using `cd tests && ./run.sh` (runjs.sh is for running them in nodejs, but not fully green right now)

So now that you have installed Spry, you can proceed to play with the samples in the `samples` directory, see README in there for details.

## Windows
First you want to have git installed, and most happily with the unix utilities included so that some of the basic unix commands work on the Windows Command prompt.

1. Installing Nim on Windows using choosenim doesn't fly ([blocked by issue 35](https://github.com/dom96/choosenim/issues/35), well, ok, the older version worked but that created a 32 bit Nim compiler which may be less optimal. You will need to follow [official installation procedure](https://nim-lang.org/install_windows.html), which is quite easy, just download the zip, unpack it and run `finish.exe` from a command prompt and follow the interactive questions.

2. Install dependencies, currently this is the snappy dll which is used for fast compression. The most reasonable place I found a precompiled version of it was on [https://snappy.machinezoo.com/downloads/](https://snappy.machinezoo.com/downloads/). Download, unpack and take the `native/snappy64.dll` or `native/snappy32.dll` and copy the proper one (presumably 64 bits) to a place where it can be found, for example in `c:\Users\<youruser>\.nimble\bin` and rename it to `libsnappy.dll`. I will fix so that it's included somehow.

3. Clone this repo. Then run `nimble install` in it. That should hopefully end up with `spry` and `ispry` built and in your path.

4. Finally run all tests using `cd tests && sh run.sh` (runjs.sh is for running them in nodejs, but not fully green right now). On windows two tests fail as of writing this.
