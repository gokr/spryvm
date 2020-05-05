import unittest, spryvm, spryunittest, os

# The VM module to test
import sprycore, spryio, spryblock, sprycompress, spryrocksdb

suite "spry rocksb":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addBlock()
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
    """) == "nil"
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
    """) == "nil"
  test "delete contains not":
    check run("""
    rock = openRocksDB "testdb"
    rock atString: "hey" putString: "there"
    rock deleteString: "hey"
    result = (rock containsString: "hey")
    rock closeRocksDB
    result
    """) == "false"
  test "rock atput":
    check run("""
    rock = openRocksDB "testdb"
    rock rockAt: [a true 23] put: [a b 23 ["hey"]]
    result = (rock rockAt: [a true 23])
    rock closeRocksDB
    result
    """) == """[a b 23 ["hey"]]"""
  test "rock delete":
    check run("""
    rock = openRocksDB "testdb"
    rock rockAt: [a true 24] put: [a b 23 ["hey"]]
    val = (rock rockAt: [a true 24])
    ((val at: 2) == 23) then: [
      rock rockDelete: [a true 24]
    ]
    result = (rock rockAt: [a true 24])
    rock closeRocksDB
    result
    """) == "nil"
    
  