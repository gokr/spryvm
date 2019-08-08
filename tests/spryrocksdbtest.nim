import unittest, spryvm, spryunittest, os

# The VM module to test
import sprycore, spryio, sprycompress, spryrocksdb

suite "spry rocksb":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addIO()
    vm.addCompress()
    vm.addRocksDB()

  teardown:
    removeDir("testdb")

  test "atput":
    check run("""
    rock = openDatabase "testdb"
    rock atString: "hey" putString: "there"
    result = (rock atString: "hey")
    rock close
    result
    """) == "\"there\""
  test "at not":
    check run("""
    rock = openDatabase "testdb"
    result = (rock atString: "hey")
    rock close
    result
    """) == "undef"
  test "contains":
    check run("""
    rock = openDatabase "testdb"
    rock atString: "hey" putString: "there"
    result = (rock containsString: "hey")
    rock close
    result
    """) == "true"
  test "contains not":
    check run("""
    rock = openDatabase "testdb"
    result = (rock containsString: "rocket")
    rock close
    result
    """) == "false"
  test "delete":
    check run("""
    rock = openDatabase "testdb"
    rock atString: "hey" putString: "there"
    rock deleteString: "hey"
    result = (rock atString: "hey")
    rock close
    result
    """) == "undef"
  
  test "atput":
    check run("""
    rock = openDatabase "testdb"
    rock rockAt: [a true 23] put: [a b 23 ["hey"]]
    result = (rock rockAt: [a true 23])
    rock close
    result
    """) == """[a b 23 ["hey"]]"""
  