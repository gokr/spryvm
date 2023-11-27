import supersnappy
import spryvm

# Spry compression
proc addCompress*(spry: Interpreter) =
  # Compression of string
  nimFunc("compress"):
    let source = StringVal(evalArg(spry)).value
    let compressed = compress(source)
    newValue(cast[string](compressed))
  nimFunc("uncompress"):
    let source = StringVal(evalArg(spry)).value
    let uncompressed = uncompress(source)
    newValue(cast[string](uncompressed))
