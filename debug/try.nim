import spryvm, sprycore, spryblock, spryos, spryio, sprylib

let spry = newInterpreter()
spry.addCore()
spry.addBlock()
spry.addOS()
spry.addIO()
spry.addLib()

discard spry.evalRoot """[
  # Create an Apple object
  apple = object [apple] {color = "green" price = 12}

  # Register a func to catch errors
  catch: [echo ("Ooops: ", :error)]

  # Make some code that throws error deep down

  pick = method [
    echo ("I picked a ", @color, " apple")
  ]

  eat = method [
    echo "Time to eat it..."
    throw "rotten"
  ]

  foo = func [
    apple pick; eat
  ]

  moo = func [echo "moo"]

  banana = func [
    try: [moo echo "a" foo echo "c" ] catch: [echo :error echo "caught"]
  ]

  banana
]"""
