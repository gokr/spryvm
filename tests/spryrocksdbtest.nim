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
    rock = openRocksDB "testdb"
    rock atString: "hey" putString: "there"
    result = (rock atString: "hey")
    rock closeRocksDB
    result
    """) == "\"there\""
  test "at not":
    check run("""
    rock = openRocksDB "testdb"
    result = (rock atString: "hey")
    rock closeRocksDB
    result
    """) == "undef"
  test "contains":
    check run("""
    rock = openRocksDB "testdb"
    rock atString: "hey" putString: "there"
    result = (rock containsString: "hey")
    rock closeRocksDB
    result
    """) == "true"
  test "contains not":
    check run("""
    rock = openRocksDB "testdb"
    result = (rock containsString: "rocket")
    rock closeRocksDB
    result
    """) == "false"
  test "delete":
    check run("""
    rock = openRocksDB "testdb"
    rock atString: "hey" putString: "there"
    rock deleteString: "hey"
    result = (rock atString: "hey")
    rock closeRocksDB
    result
    """) == "undef"
  
  test "atput":
    check run("""
    rock = openRocksDB "testdb"
    rock rockAt: [a true 23] put: [a b 23 ["hey"]]
    result = (rock rockAt: [a true 23])
    rock closeRocksDB
    result
    """) == """[a b 23 ["hey"]]"""
  