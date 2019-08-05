import snappy
import spryvm

# Spry compression
proc addCompress*(spry: Interpreter) =
  # Compression of string
  nimFunc("compress"):
    let source = StringVal(evalArg(spry)).value
    let compressed = compress(toOpenArrayByte(source, 0, source.len-1))
    newValue(cast[string](compressed))
  nimFunc("uncompress"):
    let source = StringVal(evalArg(spry)).value
    let uncompressed = uncompress(toOpenArrayByte(source, 0, source.len-1))
    newValue(cast[string](uncompressed))
