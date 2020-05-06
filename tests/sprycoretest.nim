import unittest, spryvm, spryunittest, sprycore, sprylib

import sprycore, sprylib


template isolate*(code: string): string {.dirty.} =
  let vm = newInterpreter()
  vm.addCore()
  vm.addLib()
  $vm.evalRoot("[" & code & "]")

suite "spry core":
  setup:
    let vm = newInterpreter()
    vm.addCore()
    vm.addLib()

  test "evaluation":
    # Parse properly, show renders the Node tree
    check show("[3 + 4]") == "[3 + 4]"
    # And run
    check isolate("3 + 4") == "7"
    # A block is just a block, no evaluation
    check isolate("[3 + 4]") == "[3 + 4]"
    # But we can use do to evaluate it
    check isolate("do [4 + 3]") == "7"
    # But we need to use func to make a closure from it
    check isolate("func [3 + 4]") == "func [3 + 4]"
    # Which will evaluate itself when being evaluated
    check isolate("'foo = func [3 + 4] foo") == "7"

  test "maps":
    check isolate("{}") == "{}"
    check isolate("{} empty?") == "true"
    check isolate("{x = 1} empty?") == "false"
    check isolate("{a = 1 b = 2}") in ["{a = 1 b = 2}", "{b = 2 a = 1}"]
    check isolate("{a = 1 b = \"hey\"}") in ["{a = 1 b = \"hey\"}", "{b = \"hey\" a = 1}"]
    check isolate("{a = {d = (3 + 4) e = (5 + 6)}}") in ["{a = {d = 7 e = 11}}", "{a = {e = 11 d = 7}}"]
    check isolate("{a = 3} at: 'a") == "3"
    check isolate("{3 = 4 6 = 1} at: 6") == "1" # int, In spry any Node can be a key!
    check isolate("{\"hey\" = 4 true = 1 6.0 = 8} at: \"hey\"") == "4" # string
    check isolate("{\"hey\" = 4 true = 1 6.0 = nil} at: 6.0") == "nil" # float
    #check isolate("{nil = 4} at: nil") == "4") # nil  humm...
    #check isolate("{true = false} at: true") == "false") # nil humm..
    check isolate("dict = {a = 3} dict at: 'a put: 5 dict at: 'a") == "5"

  test "assignment":
    check isolate("x = 5") == "5"
    check isolate("x = 5 x") == "5"
    check isolate("x = 5 eval x") == "5" # We can also eval it
    check isolate("f = func [3 + 4] f") == "7" # Functions are evaluated

  test "reassignment":
    check isolate("q1 := 3 q1") == "nil"
    check isolate("q2 = 5 q2 := 6 q2") == "6"
    check isolate("q3 = 5 q3 = 6 q3") == "6"
    check isolate("Foo = {x = 5} Foo::x := 3 eval Foo") == "{x = 3}"
    check isolate("Foo = {} Foo::x := 3 eval Foo") == "{}"
    check isolate("Foo = {x = nil} Foo::x := 3 eval Foo") == "{x = 3}"
    check isolate("Moo = {x = 5} Moo::x = 3 eval Moo") == "{x = 3}"

  test "nil":
    # nil, set?, set:
    check isolate("eval x") == "nil"
    check isolate("x set?") == "false"
    check isolate("'x set?") == "false"
    check isolate("x nil?") == "true"
    check isolate("x = 1 x set?") == "true"
    check isolate("x = 1 'x set?") == "true"
    check isolate("x = 1 x nil?") == "false"
    check isolate("x = nil x set?") == "true"
    check isolate("x = nil 'x set?") == "true"
    check isolate("x = nil x nil?") == "true"
    check isolate("x = 1 root removeAt: 'x x set?") == "false"
    check isolate("x = 1 root removeAt: 'x 'x set?") == "false"
    check isolate("'x set: 1 'x set?") == "true"
    check isolate("x = 5 x := nil eval x") == "nil"
    check isolate("'x set: 5 eval x") == "5"
    check isolate("x = 'foo x set: 5 eval foo") == "5"
    check isolate("(litword \"foo\") set: 5 eval foo") == "5"

  test "basic math":
    # Precedence and basic math
    check isolate("3 * 4") == "12"
    check isolate("3 + 1.5") == "4.5"
    check isolate("5 - 3 + 1") == "3" # Left to right
    check isolate("3 + 4 * 2") == "14" # Yeah
    check isolate("3 + (4 * 2)") == "11" # Thank god
    check isolate("3 / 2") == "1.5" # Goes to float
    check isolate("3 / 2 * 1.2") == "1.8" #
    check isolate("3 + 3 * 1.5") == "9.0" # Goes to float

    # And we can nest also, since a block has its own Activation
    # Note that only last result of block is used so "1 + 7" is dead code
    check isolate("5 + do [3 + do [1 + 7 1 + 9]]") == "18"

  test "print":
    # print (like Rebol "form")
    check isolate("\"ab[c\"") == "\"ab[c\""
    check isolate("123 print") == "\"123\""
    check isolate("\"abc123\" print") == "\"abc123\""
    check isolate("[\"abc123\" 12] print") == "\"abc123 12\""

  test "concatenation":
    # Concatenation
    check isolate("\"ab\", \"cd\"") == "\"abcd\""
    check isolate("[1] , [2 3]") == "[1 2 3]"


  test "set and get":
    # Set and get variables
    check isolate("x = 4 5 + x") == "9"
    check isolate("x = 1 x = x eval x") == "1"
    check isolate("x = 4 x") == "4"
    check isolate("x = 1 x := (x + 2) eval x") == "3"
    check isolate("x = 4 k = do [y = (x + 3) eval y] k + x") == "11"
    check isolate("x = 1 do [x := (x + 1)] eval x") == "2"

  test "parse":
    # Use parse word
    check isolate("parse \"[3 + 4]\"") == "[3 + 4]"
    check isolate("parse \"[x := 4]\"") == "[x := 4]"
    check isolate("do parse \"[3 + 4]\"") == "7"

  test "strings":
    check isolate("\"ab\" empty?") == "false"  
    check isolate("\"\" empty?") == "true"  

  test "booleans":
    # Boolean
    check isolate("true") == "true"
    check isolate("true not") == "false"
    check isolate("false") == "false"
    check isolate("false not") == "true"
    check isolate("3 < 4") == "true"
    check isolate("3 > 4") == "false"
    check isolate("(3 > 4) not") == "true"
    check isolate("false or false") == "false"
    check isolate("true or false") == "true"
    check isolate("false or true") == "true"
    check isolate("true or true") == "true"
    check isolate("false and false") == "false"
    check isolate("true and false") == "false"
    check isolate("false and true") == "false"
    check isolate("true and true") == "true"
    check isolate("3 > 4 or (3 < 4)") == "true"
    check isolate("3 > 4 and (3 < 4)") == "false"
    check isolate("7 > 4 and (3 < 4)") == "true"

  test "comparisons":
    # Comparisons
    check isolate("7 >= 4") == "true"
    check isolate("4 >= 4") == "true"
    check isolate("3 >= 4") == "false"
    check isolate("7 <= 4") == "false"
    check isolate("4 <= 4") == "true"
    check isolate("3 <= 4") == "true"
    check isolate("\"abc\" >= \"abb\"") == "true"
    check isolate("\"abc\" >= \"abc\"") == "true"
    check isolate("\"abc\" >= \"abd\"") == "false"
    check isolate("\"abc\" <= \"abb\"") == "false"
    check isolate("\"abc\" <= \"abc\"") == "true"
    check isolate("\"abc\" <= \"abd\"") == "true"

  test "equality and identity":
    check isolate("3 == 4") == "false"
    check isolate("4 == 4") == "true"
    check isolate("3.0 == 4.0") == "false"
    check isolate("4 == 4.0") == "true"
    check isolate("4.0 == 4") == "true"
    check isolate("4.0 != 4") == "false"
    check isolate("4.1 != 4") == "true"
    check isolate("\"abc\" == \"abc\"") == "true"
    check isolate("\"abc\" == \"AAA\"") == "false"
    check isolate("true == true") == "true"
    check isolate("false == false") == "true"
    check isolate("false == true") == "false"
    check isolate("true == false") == "false"
    check isolate("\"abc\" == \"abc\"") == "true"
    check isolate("\"abc\" == \"ab\"") == "false"
    check isolate("\"abc\" != \"ab\"") == "true"
    check isolate("true === true") == "true" # True for all singletons
    check isolate("nil === nil") == "true"
    check isolate("'foo === 'foo") == "true" # Litwords are canonicalized
    check isolate("'foo == 'foo") == "true" # Words are equal
    check isolate("$(reify 'foo) == (reify 'foo)") == "true" # Words are equal
    check isolate("$(reify 'foo) == (reify '$foo)") == "true" # Words are equal
    check isolate("$(reify 'foo) === (reify 'foo)") == "false" # Other words are not canonicalized
    check isolate("1 === 1") == "false"
    check isolate("[1 2] == [1 2]") == "true"
    check isolate("[1 2] === [1 2]") == "false"
    check isolate("x = [1 2] y = x y === x") == "true"
    check isolate("[1 2] != [1]") == "true"
    check isolate("[1 2] == [1]") == "false"
    check isolate("[1 2] == [1]") == "false"

# Will cause type exceptions
#  check isolate("false == 4") == "false")
#  check isolate("4 == false") == "false")
#  check isolate("\"ab\" == 4") == "false")
#  check isolate("4 == \"ab\"") == "false")


  test "blocks":
    # Block indexing and positioning
    check isolate("[3 4] size") == "2"
    check isolate("[] size") == "0"
    check isolate("[3 4] empty?") == "false"
    check isolate("[] empty?") == "true"
    check isolate("[3 4] at: 0") == "3"
    check isolate("[3 4] at: 1") == "4"
    check isolate("[3 4] at: 0 put: 5") == "[5 4]"
    check isolate("x = [3 4] x at: 1 put: 5 eval x") == "[3 5]"
    check isolate("x = [3 4] x add: 5 eval x") == "[3 4 5]"
    check isolate("x = [3 4] x removeLast eval x") == "[3]"
    check isolate("x = [3 4] x removeFirst x") == "[4]"
    check isolate("x = [3 4 5] x removeAt: 1 x") == "[3 5]"
    check isolate("[3 4], [5 6]") == "[3 4 5 6]"
    check isolate("[3 4] contains: 3") == "true"
    check isolate("[3 4] contains: 8") == "false"
    check isolate("{x = 1 y = 2} contains: 'x") == "true"
    check isolate("{x = 1 y = 2} contains: 'z") == "false"
    check isolate("{\"x\" = 1 \"y\" = 2} contains: \"x\"") == "true"
    check isolate("{\"x\" = 1 \"y\" = 2} contains: \"z\"") == "false"
    check isolate("[false bum 3.14 4] contains: 'bum") == "true"
    check isolate("[1 2 true 4] contains: 'false") == "false" # Note that block contains words, not values
    check isolate("[1 2 true 4] contains: 'true") == "true"
    check isolate("x = false b = [] b add: x b contains: x") == "true"

    # copyFrom:to:
    check isolate("[1 2 3] copyFrom: 1 to: 2") == "[2 3]"
    check isolate("[1 2 3] copyFrom: 0 to: 1") == "[1 2]"
    check isolate("\"abcd\" copyFrom: 1 to: 2") == "\"bc\""

  test "homoiconicism":
    # Data as code
    check isolate("code = [1 + 2 + 3] code at: 2 put: 10 do code") == "14"

  test "conditionals":
    # then:, then:else:, unless:, unless:else:
    check isolate("x = true x then: [true]") == "true"
    check isolate("false then: [12]") == "nil"
    check isolate("x = false x then: [true]") == "nil"
    check isolate("(3 < 4) then: [\"yay\"]") == "\"yay\""
    check isolate("(3 > 4) then: [\"yay\"]") == "nil"
    check isolate("(3 > 4) then: [\"yay\"] else: ['ok]") == "'ok"
    check isolate("(3 > 4) then: [true] else: [false]") == "false"
    check isolate("(4 > 3) then: [true] else: [false]") == "true"
    check isolate("(3 < 4) then: [5]") == "5"
    check isolate("3 < 4 then: [5]") == "5"
    check isolate("3 < 4 else: [5]") == "nil"
    check isolate("3 < 4 then: [1] else: [2]") == "1"
    check isolate("3 < 4 else: [1] then: [2]") == "2"
    check isolate("5 < 4 else: [1] then: [2]") == "1"
    check isolate("5 < 4 then: [1] else: [2]") == "2"

  test "loops":
    # loops, eva will
    check isolate("x = 0 5 repeat: [x := (x + 1)] x") == "5"
    check isolate("x = 0 0 repeat: [x := (x + 1)] x") == "0"
    check isolate("x = 0 5 repeat: [x := (x + 1)] x") == "5"
    check isolate("x = 0 [x > 5] whileFalse: [x := (x + 1)] x") == "6"
    check isolate("x = 10 [x > 5] whileTrue: [x := (x - 1)] x") == "5"
    check isolate("foo = func [x = 10 [x > 5] whileTrue: [x := (x - 1) ^11] ^x] foo") == "11" # Return inside
    check isolate("foo = func [x = 10 [x > 5 ^99] whileTrue: [x := (x - 1)] ^x] foo") == "99" # Return inside


  test "functions":
    # func
    check isolate("z = func [3 + 4] z") == "7"
    check isolate("x = func [3 + 4] eva $x") == "func [3 + 4]"
    check isolate("x = func [3 + 4] 'x") == "'x"
    check isolate("x = func [3 + 4 ^ 1 8 + 9] x") == "1"
    # Its a non local return so it returns all the way, thus it works deep down
    check isolate("x = func [3 + 4 do [ 2 + 3 ^ 1 1 + 1] 8 + 9] x") == "1"
    check isolate("x = method [3 + 4 do [2 + 3 ^(self + 1) + 1] 8 + 9] 9 x") == "10"
    check isolate("x = method [self < 4 then: [do [^9] 8] else: [^10]] 2 x") == "9"
    check isolate("do [:a] 5") == "5"
    check isolate("x = func [:a a + 1] x 5") == "6"
    check isolate("x = func [:a + 1] x 5") == "6" # Slicker than the above!
    check isolate("x = func [:a :b eval b] x 5 4") == "4"
    check isolate("x = func [:a :b a + b] x 5 4") == "9"
    check isolate("x = func [:a + :b] x 5 4") == "9" # Again, slicker
    check isolate("z = 15 x = func [:a :b a + b + z] x 1 2") == "18"
    check isolate("z = 15 x = func [:a + :b + z] x 1 2") == "18" # Slick indeed
    # Variadic and dynamic args
    # This func does not pull second arg if first is < 0.
    check isolate("add = func [ :a < 0 then: [^ nil] ^ (a + :b) ] add -4 3") == "3"
    check isolate("add = func [ :a < 0 then: [^ nil] ^ (a + :b) ] add 1 3") == "4"
    # Macros, they need to be able to return multipe nodes...
    check isolate("z = 5 foo = func [:$a ^ func [a + 10]] fupp = foo z z := 3 fupp") == "13"
    # func closures. Creates two different funcs closing over two values of a
    check isolate("c = func [:a func [a + :b]] d = (c 2) e = (c 3) (d 1 + e 1)") == "7" # 3 + 4
    # Funcs and blocks should both be able to run using do
  
  test "do func":
    check isolate("echo do func [3 + 4]") == "7"
    check isolate("foo = func [3 + 4] echo do $foo") == "7"
  test "do block":
    check isolate("foo = [3 + 4] echo do $foo") == "7"
  test "do paren":
    check isolate("foo = $(3 + 4) echo do $foo") == "7"
  test "do curly":
    check isolate("foo = ${3 + 4} echo do $foo") == "7"

  test "ast manipulation":
    # Testing $ word that prevents evaluation, like quote in Lisp
    check isolate("x = $(3 + 4) $x at: 2") == "4"

    # Testing literal word evaluation into the real word
    #check isolate("eva 'a") == "a")
    #check isolate("eva ':$a") == ":$a")

  test "do":
    check isolate("do [:b + 3] 4") == "7" # Muhahaha!
    check isolate("do [:b + :c - 1] 4 3") == "6" # Muhahaha!
    check isolate("d = 5 do [:x] d") == "5"
    check isolate("d = 5 do [:$x] d") == "d"
    # x will be a Word, need val and key prims to access it!
    #check isolate("a = \"ab\" do [:$x ($x print), \"c\"] a") == "\"ac\"") # x becomes "a"
    check isolate("a = \"ab\" do [:x , \"c\"] a") == "\"abc\"" # x becomes "ab"

  test "scoping":
    # @ and ..
    check isolate("d = 5 do [eval $d]") == "5"
    check isolate("d = 5 do [eval $@d]") == "nil"
    check isolate("d = 5 do [eval d]") == "5"
    check isolate("d = 5 do [eval @d]") == "nil"

  # func infix works too, and with 3 or more arguments too...
  test "methods":
    check isolate("xx = func [:a :b a + b + b] xx 2 (xx 5 4)") == "28" # 2 + (5+4+4) + (5+4+4)
    check isolate("xx = method [:b self + b] 5 xx 2") == "7" # 5 + 7
    check isolate("xx = method [self + :b] 5 xx 2") == "7" # 5 + 7
    check isolate("xx = method [:b self + b + b] 5 xx (4 xx 2)") == "21" # 5 + (4+2+2) + (4+2+2)
    check isolate("xx = method [self + :b + b] (5 xx 4) xx 2") == "17" # 5+4+4 + 2+2
    check isolate("pick2add = method [:b :c self at: b + (self at: c)] [1 2 3] pick2add 0 2") == "4" # 1+3
    check isolate("pick2add = method [self at: :b + (self at: :c)] [1 2 3] pick2add 0 2") == "4" # 1+3

  test "misc":
    # Ok, but now we can do arguments so...
    check isolate("""
    factorial = func [:n > 0 then: [n * factorial (n - 1)] else: [1]]
    factorial 12
    """) == "479001600"

    # Implement simple for loop
    check isolate("""
    for = func [:n :m :blk
    x = n
    [x <= m] whileTrue: [
      do blk x
      x := (x + 1)]]
    r = 0
    for 2 5 [r := (r + :i)]
    eval r
    """) == "14"

    check isolate("""
    r = 0 y = [1 2 3]
    y do: [r := (r + :e)]
    eval r
    """) == "6"

  test "reflection":
    # The word locals gives access to the local Map
    check isolate("do [d = 5 locals]") == "{d = 5}"
    check isolate("do [d = 5 locals at: 'd]") == "5"
    check isolate("locals at: 'd put: 5 d + 2") == "7"
    check isolate("map = do [a = 1 b = 2 locals] (map at: 'a) + (map at: 'b) ") == "3"
    check isolate("map = do [a = 1 b = 2 c = 3 (locals)] (map get: a) + (map get: b) + (map get: c)") == "6"

  test "self":
    # The word self gives access to the receiver for methods only
    check isolate("self") == "nil" # self not bound for funcs
    check isolate("xx = func [self] xx") == "nil" # self not bound for funcs
    check isolate("xx = method [self + self] o = 12 o xx") == "24" # Multiple self
    check isolate("xx = method [node] foo xx") == "foo" # Access to unevaled self
    check isolate("xx = method [node at: 0] $(3 + 4) xx") == "3" # Access to unevaled self
    check isolate("[] add: 1 ; add: $ + ; add: 2 echo ; do ;") == "3" # Access to last self ;

    check isolate("x = object [] {a = 1 foo = method [self at: 'a]} x::foo") == "1"
    check isolate("x = object [] {a = 1 foo = method [true then: [self at: 'a]]} x::foo") == "1"
    check isolate("x = object [] {a = 1 foo = method [true then: [@a]]} x::foo") == "1"
    check isolate("x = object [] {a = 1 foo = method [^ @a]} x::foo") == "1"
    check isolate("x = object [] {a = 1 foo:bar: = method [^ (@a + :foo + :bar)]} x::foo: 2 bar: 3") == "6"
    check isolate("x = object [] {a = 1 foo = method [^ @a]} eva $x::foo") == "method [^ @a]"
    check isolate("x = object ['foo 'bar] {a = 1} x tags") == "['foo 'bar 'object]"

  test "cascade":
    # The word ; gives access to the last known infix argument
    check isolate("[1] add: 2 ; add: 3 ; size") == "3"

  test "activation":
    # The word activation gives access to the current activation record
    check isolate("activation") == "activation [[activation] 1]"

  test "tags":
    # Add and check tag
    check isolate("x = 3 x tag: 'num x tag? 'num") == "true"
    check isolate("x = 3 x tag: 'num x tag? 'bum") == "false"
    check isolate("x = 3 x tag: 'num x tags") == "['num]"
    check isolate("x = 3 x tag? 'bum") == "false"
    check isolate("x = 3 x tags: ['bum 'num] x tags") == "['bum 'num]"
    check isolate("x = 3 x tags: ['bum 'num] x tag? 'bum") == "true"
    check isolate("x = 3 x tags: ['bum 'num] x tag? 'lum") == "false"

    # spry serialize parse
  test "serialize":
    check isolate("serialize [1 2 3 \"abc\" {3.14}]") == "\"[1 2 3 \\\"abc\\\" {3.14}]\""
    check isolate("parse serialize [1 2 3 \"abc\" {3.14}]") == "[1 2 3 \"abc\" {3.14}]"

  test "lib":
    # Library code
    check isolate("assert (3 < 4) \"3 less than 4\"") == "true"

  test "clone":
    check isolate("a = 12 b = clone a a = 9 eva b") == "12"
    check isolate("a = \"abc\" b = clone a a = \"zzz\" eva b") == "\"abc\""
    check isolate("a = [[1 2]] b = clone a (b at: 0) at: 0 put: 5 eval a") == "[[5 2]]"
    check isolate("a = [[1 2]] b = clone a b add: 5 eval a") == "[[1 2]]"
    check isolate("x = $(3 4) clone $x") == "(3 4)" # Works for Paren
    check isolate("x = ${3 4} clone $x") == "{3 4}" # Works for Curly
    check isolate("a = {x = 1} clone a") == "{x = 1}"
    check isolate("a = {x = [1]} b = clone a (b at: (reify 'y) put: 2) (b get: y) + ((b get: x) at: 0) ") == "3"
    check isolate("a = {x = [1]} b = clone a (b set: y to: 2) (b get: y) + ((b get: x) at: 0)") == "3"
    check isolate("a = {x = [1]} b = clone a (b set: y to: 2) (a get: y)") == "nil"

  test "modules":
    # Modules
    check isolate("Foo = {x = 10} eva Foo::x") == "10" # Direct access works
    check isolate("Foo = {x = 10} eva Foo::y") == "nil" # and missing key works too
    check isolate("Foo = {x = 10} Foo::x := 3 eva Foo::x") == "3"
    check isolate("eva Foo::y") == "nil"
    check isolate("Foo = {x = 10} eva $Foo::x") == "10"
    check isolate("Foo = {x = func [:x + 1]} eva $Foo::x") == "func [:x + 1]"
    check isolate("Foo = {x = func [:x + 1]} Foo::x 3") == "4"
    check isolate("eval modules") == "[]"
    check isolate("modules add: {x = 10} eval modules") == "[{x = 10}]"
    check isolate("modules add: {x = 10} x") == "10"
    check isolate("foo = func [bar = {x = 10} bar::x + 1] bar = 10 eval foo") == "11"
    check isolate("do [bar = {x = 1 y = 2} do [bar::x + 1]]") == "2"
  test "modules lookup":
    check isolate("Foo = {x = func [:x + 1]} Bar = {x = 7} modules add: Foo modules add: Bar x 1") == "2"
  test "modules lookup 2":
    check isolate("Foo = {x = func [:x + 1] y = 10} Bar = {x = func [:x + 2]} modules add: Bar modules add: Foo x y") == "12"

  test "iteration":
    check isolate("x = 0 [1 2 3] do: [x := (x + :y)] x") == "6"
    check isolate("x = 0 1 to: 3 do: [x := (x + :y)] x ") == "6"
    check isolate("y = [] -2 to: 2 do: [y add: :n] y") == "[-2 -1 0 1 2]"
    check isolate("x = [] 1 to: 3 do: [x add: :y] x ") == "[1 2 3]"
    check isolate("x = [] 3 to: 1 by: -1 do: [x add: :y] x ") == "[3 2 1]"

  test "map":
    # Maps and Words, all variants should end up as same key
    check isolate("map = {x = 1} map at: 'x put: 2 map at: (reify '$x) put: 3 map at: (reify ':x) put: 4 eval map") == "{:x = 4}"

  test "various tricks":
    # Implementing prefix minus
    check isolate("mm = func [0 - :n] mm 7 + 2") == "-5"

    # Implementing ifTrue: using then:, two variants
    check isolate("ifTrue: = method [:blk self then: [^do blk] else: [^nil]] 3 > 2 ifTrue: [99] ") == "99"
    check isolate("ifTrue: = method [:blk self then: [^do blk] nil] 1 > 2 ifTrue: [99] ") == "nil"

  test "catch throw no args":
    check isolate("activation catch: [42] throw") == "42"
  test "catch throw no args two levels":
    check isolate("bar = func [throw] foo = func [activation catch: [42] bar] foo") == "42"
  test "catch throw one arg":
    check isolate("activation catch: [:thing + 4] throw 3") == "7"
  test "catch throw one arg two levels":
    check isolate("bar = func [throw 9] foo = func [activation catch: [:x + 42] bar] foo") == "51"
