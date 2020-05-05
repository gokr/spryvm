import unittest, spryvm, spryunittest, spryio

# The VM module to test
import sprycore, spryblock

template isolate*(code: string): string {.dirty.} =
  let vm = newInterpreter()
  vm.addCore()
  vm.addBlock()
  vm.addIO()
  $vm.evalRoot("[" & code & "]")

suite "spry block":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addIO()
    vm.addBlock()

  test "newBlock":
    check isolate("a = newBlock a add: 1 a add: 2") == "[1 2]"
    check isolate("a = newBlock: 2 a at: 0 put: 1 a at: 1 put: 2") == "[1 2]"

  test "access":
    check isolate("[3 4] first") == "3"
    check isolate("[3 4] last") == "4"

  test "fill":
    check isolate("newBlock: 2") == "[nil nil]"
    check isolate("a = newBlock: 2 a at: 0 put: 9") == "[9 nil]"

  test "reverse":
    check isolate("[1 2 3] reverse") == "[3 2 1]"

  test "streaming":
    check isolate("x = [3 4] x read") == "3"
    check isolate("x = [3 4] x pos: 1 x read") == "4"
    check isolate("x = [3 4] x pos: 1 x reset x read") == "3"
    check isolate("x = [3 4] x next") == "3"
    check isolate("x = [3 4] x next x next") == "4"
    check isolate("x = [3 4] x next x end?") == "false"
    check isolate("x = [3 4] x next x next x end?") == "true"
    check isolate("x = [3 4] x next x next x next") == "nil"
    check isolate("x = [3 4] x next x next x prev") == "4"
    check isolate("x = [3 4] x next x next x prev x prev") == "3"
    check isolate("x = [3 4] x pos") == "0"
    check isolate("x = [3 4] x next x pos") == "1"
    check isolate("x = [3 4] x write: 5") == "[5 4]"

  test "meta":
    check isolate("x = func [3 + 4] $x write: 5 x") == "9"

  test "detect":
    check isolate("""
    [1 2 3 4] detect: [:each > 2]
    """) == "3"

  test "map":
    check isolate("""
    [1 2 3 4] map: [:each + 1]
    """) == "[2 3 4 5]"

  test "select":
    check isolate("""
    [1 2 3 4] select: [:each > 2]
    """) == "[3 4]"

  test "spryselect":
    check isolate("""
    [1 2 3 4] spryselect: [:each > 2]
    """) == "[3 4]"

  test "map":
    check isolate("""
    map: = method [:lambda
    result = []
    self reset
    [self end?] whileFalse: [
      result add: (do lambda (self next)) ]
    ^ result ]
    [1 2 3 4] map: [:x * 2]
    """) == "[2 4 6 8]"

  test "max:":
    check isolate("[1 2 3] max: [:each] default: 0") == "3"
    check isolate("[1 2 3] max: (func [:each * 6]) default: 0") == "18"
    check isolate("[] max: [:each] default: 7") == "7"
    check isolate("[1 20 3] max: [:each] default: 0") == "20"
    check isolate("[7] max: [:each] default: 0") == "7"

  test "findIndex:":
    check isolate("[{x = 100} {x = 50} {x = 120}] findIndex: func [:each each::x == 120]") == "2"
    check isolate("[{x = 100} {x = 50} {x = 120}] findIndex: [:each each::x == 120]") == "2"
    