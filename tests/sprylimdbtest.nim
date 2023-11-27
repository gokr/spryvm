import unittest, spryvm, spryunittest, os

# The VM module to test
import sprycore, spryio, spryblock, sprycompress, sprylimdb

suite "spry limdb":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addBlock()
    vm.addIO()
    vm.addCompress()
    vm.addLimdb()

  teardown:
    removeDir("testdb")

  test "at put":
    check run("""
    db = openLimdb "testdb"
    db atString: "hey" putString: "there"
    result = (db atString: "hey")
    db closeLimdb
    result
    """) == "\"there\""

  test "at not":
    check run("""
    db = openLimdb "testdb"
    result = (db atString: "kangaroo")
    db closeLimdb
    result
    """) == "nil"

  test "contains":
    check run("""
    db = openLimdb "testdb"
    db atString: "hey" putString: "there"
    result = (db containsString: "hey")
    db closeLimdb
    result
    """) == "true"

  test "contains not":
    check run("""
    db = openLimdb "testdb"
    result = (db containsString: "gurka")
    db closeLimdb
    result
    """) == "false"

  test "delete":
    check run("""
    db = openLimdb "testdb"
    db atString: "hey" putString: "there"
    db deleteString: "hey"
    result = (db atString: "hey")
    db closeLimdb
    result
    """) == "nil"

  test "delete contains not":
    check run("""
    db = openLimdb "testdb"
    db atString: "hey" putString: "there"
    db deleteString: "hey"
    result = (db containsString: "hey")
    db closeLimdb
    result
    """) == "false"

  test "db atput":
    check run("""
    db = openLimdb "testdb"
    db limdbAt: [a true 23] put: [a b 23 ["hey"]]
    result = (db limdbAt: [a true 23])
    db closeLimdb
    result
    """) == """[a b 23 ["hey"]]"""

  test "db delete":
    check run("""
    db = openLimdb "testdb"
    db limdbAt: [a true 24] put: [a b 23 ["hey"]]
    val = (db limdbAt: [a true 24])
    ((val at: 2) == 23) then: [
      db limdbDelete: [a true 24]
    ]
    result = (db limdbAt: [a true 24])
    db closeLimdb
    result
    """) == "nil"

