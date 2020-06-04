import spryvm, sprycore, spryblock, spryos, spryio, sprylib

let spry = newInterpreter()
spry.addCore()
spry.addBlock()
spry.addOS()
spry.addIO()
spry.addLib()

discard spry.eval """[
  # A recursive factorial
  factorial = func [:n > 0 then: [n * factorial (n - 1)] else: [1]]

 echo ("Time to compute 100k factorial 12: " , (([
    100000 repeat: [factorial 12]
  ] timeToRun) print))
]"""

discard spry.eval """[
  blk = []
  echo ("Time to create a block: " , (([
    1 to: 4000000 do: [blk add: :i]
  ] timeToRun) print))

  sum1 = 0
  echo ("Time to sum a block: " , (([
    blk do: [sum1 := (sum1 + :$each)]
  ] timeToRun) print))

  sum2 = 0
  echo ("Time to sum a block using primitive: " , (([
    sum2 := (blk sum)
  ] timeToRun) print))

  assert (sum1 == 8000002000000) "Sum1"
  assert (sum2 == 8000002000000) "Sum2"
]"""

discard spry.eval """[
  # Report the results of running the two tiny Squeak benchmarks.
  #
  # ar 9/10/1999: Adjusted to run at least 1 sec to get more stable results
  #       On a 292 MHz G3 Mac: 23,000,000 bytecodes/sec; 980,000 sends/sec
  #       On a 400 MHz PII/Win98:  18,000,000 bytecodes/sec; 1,100,000 sends/sec
  #       On a 2800 MHz i7:  1,200,000,000 bytecodes/sec; 25,000,000 sends/sec
  #       On a 2800 MHz i7 (CogVM):  1,700,000,000 bytecodes/sec; 260,000,000 sends/sec

  benchmark = method [
    # Handy bytecode-heavy benchmark
    # (500000 // time to run) = approx bytecodes per second
    # 5000000 // (Time millisecondsToRun: [10 benchmark]) * 1000
    # 3059000 on a Mac 8100/100
    sze = 8190
    count = 0
    1 to: self do: [
      count := 0
      flags = newBlock: (sze + 1) # Hack to keep indexing same as in Smalltalk
      flags fill: true
      1 to: sze do: [
        (flags at: :i) then: [
          prime = (i + 1)
          k = (i + prime)
          [k <= sze] whileTrue: [
            flags at: k put: false
            k := (k + prime)
          ]
          count := (count + 1)]
        ]
      ]
    ^count
  ]

  benchFib = method [
    # Handy send-heavy benchmark
    # (result // seconds to run) = approx calls per second
    self < 2
        then: [^1]
        else: [
          # Hmmm... bug here... self is broken somehow on recursion
          a = (self - 1)
          b = (self - 2)
          ^(a benchFib + (b benchFib) + 1)]
  ]

  n1 = 1
  t1 = 0
  [t1 := ([n1 benchmark] timeToRun)
  t1 < 1000] whileTrue: [
    n1 := (n1 * 2)] # Note: #benchmark's runtime is about O(n)

  n2 = 28
  t2 = 0
  r = 0
  [t2 := ([r := (n2 benchFib)] timeToRun)
  t2 < 1000] whileTrue: [
    n2 := (n2 + 1)]
          # Note: #benchFib's runtime is about O(k^n),
          #       where k is the golden number = (1 + 5 sqrt) / 2 = 1.618....

  echo (((n1 * 500000 * 1000) / t1) print, " bytecodes/sec; ")
  echo (((r * 1000) / t2) print, " sends/sec")
]"""
