import unittest, spryvm

# The VM module to test
import sprycore, spryextend, sprylib, spryoo

template isolate*(code: string): string {.dirty.} =
  let vm = newInterpreter()
  vm.addCore()
  vm.addExtend() # reduce...
  vm.addLib()
  vm.addOO()
  $vm.evalRoot("[" & code & "]")


suite "spry oo":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addExtend() # reduce...
    vm.addLib()
    vm.addOO()

  test "tags":
    check isolate("o = {x = 5} o tag: 'object o tags") == "['object]"
    check isolate("o = object [] {x = 5} o tags") == "['object]"
    check isolate("o = \"foo\" getx = method [^ @x] o getx") ==
        "nil" # Because @ works only for objects
    check isolate("o = {x = 5} getx = method [^ @x] o tag: 'object o getx") == "5"
    check isolate("o = {x = 5} getx = method [eva @x] o tag: 'object o getx") == "5"
    check isolate("o = {x = 5} xplus = method [@x + 1] o tag: 'object o xplus") == "6"
    check isolate("o = {x = 5} xplus = method [do [x = 4 @x + 1]] o tag: 'object o xplus") == "6"

    # spry polymeth (reduce should not be needed here)
  test "polymethod":
    check isolate("p = polymethod reduce [method [self + 1] method [self]]") == "polymethod [method [self + 1] method [self]]"
    check isolate("[int string] -> [self]") == "method [self]"
    check isolate("$([int string] -> [self]) tags") == "[int string]"
    check isolate("p = polymethod reduce [[int] -> [1] [string] -> [2]]") == "polymethod [method [1] method [2]]"
    check isolate("p = polymethod reduce [[int] -> [1] [string] -> [2]] 42 p") == "nil"
    check isolate("inc = polymethod reduce [[int] -> [self + 1] [string] -> [self , \"c\"]] (42 tag: 'int) inc") == "43"
    check isolate("inc = polymethod reduce [[int] -> [self + 1] [string] -> [self , \"c\"]] (\"ab\" tag: 'string) inc") == "\"abc\""
