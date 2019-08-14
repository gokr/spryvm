import spryvm
import db_sqlite
import sequtils

type
  DbConnNode = ref object of Node
    conn: DbConn
  RowNode = ref object of Blok

method `$`*(self: DbConnNode): string =
  "DbConnNode"

method eval*(self: DbConnNode, spry: Interpreter): Node =
  self

method `$`*(self: RowNode): string =
  "RowNode"

method eval*(self: RowNode, spry: Interpreter): Node =
  self

# Spry Sqlite module
proc addSqlite*(spry: Interpreter) =
  nimFunc("openDatabase"):
    let fileName = StringVal(evalArg(spry)).value
    let conn = open(fileName, "", "", "")
    DbConnNode(conn: conn)
  nimMeth("close"):
    let node = DbConnNode(evalArgInfix(spry))
    let conn = node.conn
    conn.close()
    return node
  nimMeth("query:params:"):
    let node = DbConnNode(evalArgInfix(spry))
    let conn = node.conn
    let query = StringVal(evalArg(spry)).value
    let nodes = SeqComposite(evalArg(spry)).nodes
    let stringValues: seq[string] = nodes.map(proc(x:Node): string = StringVal(x).value)
    conn.exec(sql(query), stringValues)
    return node
  nimMeth("getRows:params:"):
    let node = DbConnNode(evalArgInfix(spry))
    let conn = node.conn
    let query = StringVal(evalArg(spry)).value
    let nodes = SeqComposite(evalArg(spry)).nodes
    let stringValues = nodes.map(proc(x:Node): string = StringVal(x).value)
    let blok = newBlok()
    for row in conn.rows(sql(query), stringValues):
      var cols = row.map(proc(x:string): Node = StringVal(value: x))
      let rowBlok = newBlok(cols)
      blok.add(rowBlok)
    return blok
  
  # Library code
  discard spry.evalRoot """[
    # Without params
    getRows: = method [ self getRows: :x params: []]
    query: = method [ self query: :x params: []]
  ]"""