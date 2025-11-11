import unittest, spryvm, spryunittest, sprycore, spryreflect

suite "spry reflect":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addReflect()
  test "type":
    check:
      run("x type") == "'novalue"
      run("x1 = 0 x1 type") == "'int"
      run("x2 = 0.5 x2 type") == "'float"
      run("x3 = \"a\" x3 type") == "'string"
      run("x4 = [] x4 type") == "'block"
      run("x5 = nil x5 type") == "'novalue"
      run("x6 = true x6 type") == "'boolean"
