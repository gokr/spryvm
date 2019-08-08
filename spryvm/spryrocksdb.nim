import spryvm
import os, cpuinfo
import rocksdb

type
  RocksDBNode = ref object of Node
    path: string
    db: RocksDBInstance

proc init(self: RocksDBNode): bool =
  let
    dataDir = self.path / "data"
    backupsDir = self.path / "backups"
  createDir(dataDir)
  createDir(backupsDir)
  let s = self.db.init(dataDir, backupsDir)
  s.ok

method `$`*(self: RocksDBNode): string =
  "RocksDBNode"

method eval*(self: RocksDBNode, spry: Interpreter): Node =
  self

# Spry Sqlite module
proc addRocksDB*(spry: Interpreter) =
  nimFunc("openDatabase"):
    let path = StringVal(evalArg(spry)).value
    let rock = RocksDBNode(path: path)
    let ok = rock.init()
    if ok:
      return rock
    else:
      return spry.undefVal
  nimMeth("close"):
    let rock = RocksDBNode(evalArgInfix(spry))
    rocksdb.close(rock.db)
    return rock
  nimMeth("atString:putString:"):
    let rock = RocksDBNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    let val = StringVal(evalArg(spry)).value
    let s = rock.db.put(toOpenArrayByte(key, 0, key.len-1), toOpenArrayByte(val, 0, val.len-1))
    newValue(s.ok)
  nimMeth("atString:"):
    let rock = RocksDBNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    var s = rock.db.getBytes(toOpenArrayByte(key, 0, key.len-1))
    if s.ok:
      return newValue(cast[string](s.value))
    else:
      return spry.undefVal
  nimMeth("containsString:"):
    let rock = RocksDBNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    var s = rock.db.contains(toOpenArrayByte(key, 0, key.len-1))
    return newValue(s.value)
  nimMeth("deleteString:"):
    let rock = RocksDBNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    var s = rock.db.del(toOpenArrayByte(key, 0, key.len-1))
    return newValue(s.ok)

  # Library code
  discard spry.evalRoot """[
    # Serialize
    rockAt:put: = method [ self atString: (compress serialize :key) putString: (compress serialize :val) ]
    rockAt: = method [
      val = (self atString: (compress serialize :key))
      val ? then: [^(parse uncompress val)] else: [^undef]
    ]
  ]"""