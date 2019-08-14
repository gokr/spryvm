import unittest, spryvm, spryio, spryunittest

# The VM module to test
import sprycore, sprycompress

suite "spry compress":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addIO()
    vm.addCompress()
  test "compress":
    check run("compress \"abc123\"") == "\"\\x06\\x14abc123\""
  test "roundtrip1":
    check run("uncompress (compress \"abc123\")") == "\"abc123\""
  test "roundtrip2":
      check run("""
      msg = "There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors.
            There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors.
            There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors"
      uncompress (compress msg) == msg
      """) == "true"
  test "compressed is larger":
    check run("""
    msg = "There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors.
          There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors.
          There are only two hard problems in Computer Science: cache invalidation, naming things, and off-by-one errors"
    s1 = (msg size)
    s2 = (compress msg size)
    s1 > s2
    """) == "true"