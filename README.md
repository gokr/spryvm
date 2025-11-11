# SpryVM

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble_js.png)](https://github.com/yglukhov/nimble-tag)

[![Build Status](https://travis-ci.org/gokr/spryvm.svg?branch=master)](https://travis-ci.org/gokr/spryvm)

This is the VM for the [Spry language](http://sprylang.se/), packaged as a Nim library.

# What is this?

This is **not where you start out with Spry**, instead take a look at [the language website](http://sprylang.se) and install the [Spry](http://github.com/gokr/spry) nimble package that in turn **depends** on this package to implement usable Spry interpreters. This repository contains only the core Parser/Interpreter.

# Installation

SpryVM mainly depends on Nim, so it should work fine on Windows, OSX, Linux etc, but
for the moment **I use Linux for Spry development**. The shell scripts should probably be rewritten in nimscript and thus everything can be fully cross platform - feel free to help me with that!

1. Install Nim.

2. Clone this repo. Then run `nimble install` in it.

3. Finally run all tests using `nimble test` (runjs.sh is for running them in nodejs, but not fully green right now).
