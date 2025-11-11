import unittest, spryvm, spryunittest

# The VM module to test
import sprycore, spryjson

suite "spry JSON":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addJSON()

  test "parse":
    check run("""
        parseJSON "{\"age\": 35, \"pi\": 3.1415}"
        """) == "{\"age\":35,\"pi\":3.1415}"

  test "tospry":
    # Hash table order is non-deterministic, check both possible orderings
    check run("""
      (parseJSON "{\"age\": 35, \"pi\": 3.1415}") toSpry
      """) in ["{\"age\" = 35 \"pi\" = 3.1415}", "{\"pi\" = 3.1415 \"age\" = 35}"]

  test "toJSON":
    # Hash table order is non-deterministic, check both possible orderings
    check run("""
      (parseJSON "{\"age\": 35, \"pi\": 3.1415}") toSpry toJSON
     """) in ["{\"age\":35,\"pi\":3.1415}", "{\"pi\":3.1415,\"age\":35}"]
