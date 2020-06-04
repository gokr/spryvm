import spryvm

method typeName*(self: Node): string {.base.} =
  raiseRuntimeException("Nodes need to implement typeName")

method typeName*(self: IntVal): string =
  "int"

method typeName*(self: FloatVal): string =
  "float"

method typeName*(self: StringVal): string =
  "string"

method typeName*(self: TrueVal): string =
  "boolean"

method typeName*(self: FalseVal): string =
  "boolean"

method typeName*(self: NilVal): string =
  "novalue"

method typeName*(self: EvalWord): string =
  "evalword"

method typeName*(self: EvalModuleWord): string =
  "evalmoduleword"

method typeName*(self: EvalSelfWord): string =
  "evalselfword"

method typeName*(self: GetWord): string =
  "getword"

method typeName*(self: GetModuleWord): string =
  "getmoduleword"

method typeName*(self: GetSelfWord): string =
  "getselfword"

method typeName*(self: LitWord): string =
  "litword"

method typeName*(self: EvalArgWord): string =
  "evalargword"

method typeName*(self: GetArgWord): string =
  "getargword"

method typeName*(self: Blok): string =
  "block"

method typeName*(self: Funk): string =
  "func"

method typeName*(self: Meth): string =
  "method"

method typeName*(self: Paren): string =
  "paren"

method typeName*(self: Curly): string =
  "curly"

method typeName*(self: Map): string =
  "map"

method typeName*(self: Binding): string =
  "binding"

method typeName*(self: Activation): string =
  "activation"

# Spry Reflection module
proc addReflect*(spry: Interpreter) =
  nimMeth("type"):
    spry.newLitWord(evalArgInfix(spry).typeName)

