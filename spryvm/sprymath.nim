import spryvm
import math

when not defined(spryMathNoRandom):
  import random

# Spry math module
proc addMath*(spry: Interpreter) =
  # Just like in Smalltalk
  nimMeth("negated"):
    let v = evalArgInfix(spry)
    if v of FloatVal:
      return newValue(-FloatVal(v).value)
    else:
      return newValue(-IntVal(v).value)
  nimMeth("binom"): newValue(binom(IntVal(evalArgInfix(spry)).value, IntVal(evalArg(spry)).value))
  nimMeth("fac"): newValue(fac(IntVal(evalArgInfix(spry)).value))
  nimMeth("powerOfTwo?"): newValue(isPowerOfTwo(IntVal(evalArgInfix(spry)).value))
  nimMeth("nextPowerOfTwo"): newValue(nextPowerOfTwo(IntVal(evalArgInfix(spry)).value))
  # nimMeth("sum", false): newValue(sum(SeqComposite(evalArg(spry)).value))
  when not defined(spryMathNoRandom):
    nimMeth("random"):
      let max = evalArgInfix(spry)
      if max of FloatVal:
        return newValue(rand(FloatVal(max).value))
      else:
        return newValue(rand(IntVal(max).value))
  nimMeth("sqrt"):
    let self = evalArgInfix(spry)
    if self of FloatVal:
      return newValue(sqrt(FloatVal(self).value))
    else:
      return newValue(sqrt(float(IntVal(self).value)))
  nimMeth("sin"): newValue(sin(FloatVal(evalArgInfix(spry)).value))
  nimMeth("cos"): newValue(cos(FloatVal(evalArgInfix(spry)).value))
  nimMeth("mod"):
    let a = evalArgInfix(spry)
    let b = evalArg(spry)
    if a of FloatVal:
      return newValue(FloatVal(a).value mod (FloatVal(b).value))
    else:
      return newValue(IntVal(a).value mod (IntVal(b).value))