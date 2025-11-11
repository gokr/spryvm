import unittest, spryvm, spryunittest

# The VM module to test
import sprycore, spryio, sprysqlite

suite "spry sqlite":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addIO()
    vm.addSqlite()

  test "basics":
    check run("""
    removeFile "test.db"
    conn = openDatabase "test.db"
    conn query: "CREATE TABLE car (id INTEGER, name VARCHAR(50))"
    conn query: "INSERT INTO car (id, name) VALUES (0, ?)" params: ["Volvo"]
    result = (conn getRows: "SELECT * from car")
    conn close
    result
    """) == """[["0" "Volvo"]]"""