import spryvm
import os
import limdb

type
  LimdbNode = ref object of Node
    path: string
    db: Database[string, string]

proc init(self: LimdbNode) =
  let dataDir = self.path / "data"
  createDir(dataDir)
  self.db = initDatabase(dataDir)

method `$`*(self: LimdbNode): string =
  "LimdbNode"

method eval*(self: LimdbNode, spry: Interpreter): Node =
  self

# Spry Sqlite module
proc addLimdb*(spry: Interpreter) =
  nimFunc("openLimdb"):
    let path = StringVal(evalArg(spry)).value
    let limdb = LimdbNode(path: path)
    limdb.init()
    return limdb
  nimMeth("closeLimdb"):
    let limdb = LimdbNode(evalArgInfix(spry))
    limdb.db.close()
    return limdb
  nimMeth("atString:putString:"):
    let limdb = LimdbNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    let val = StringVal(evalArg(spry)).value
    limdb.db[key] = val
  nimMeth("atString:"):
    let limdb = LimdbNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    if limdb.db.hasKey(key):
      let v = limdb.db[key]
      newValue(v)
    else:
      spry.nilVal
  nimMeth("containsString:"):
    let limdb = LimdbNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    return newValue(limdb.db.hasKey(key))
  nimMeth("deleteString:"):
    let limdb = LimdbNode(evalArgInfix(spry))
    let key = StringVal(evalArg(spry)).value
    limdb.db.del(key)

  # Library code
  discard spry.evalRoot """[
    # Higher level methods that serialize and compress
    limdbAt:put: = method [
      self atString: (compress serialize :key) putString: (compress serialize :val)
    ]
    limdbAt: = method [
      val = (self atString: (compress serialize :key))
      val nil? then: [
        ^ nil
      ] else: [
        ^ eval parse uncompress val
      ]
    ]
    limdbDelete: = method [
      self deleteString: (compress serialize :key)
    ]
  ]"""
