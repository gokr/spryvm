import spryvm

# Spry core lib module, only depends on core
proc addLib*(spry: Interpreter) =
  discard spry.evalRoot """[
    # Trivial error function
    error = func [echo :msg quit 1]

    # Trivial assert
    assert = func [:x :msg x then: [echo (msg, " OK")] else: [error (msg, " FAILED")] ^x]

    # Objects are tagged as 'object plus additional tags
    object = func [:ts
      :map tags: clone ts; tag: 'object
      ^ map
    ]

    # Modules are objects tagged as 'module
    module = func [^ object ['module] :map]

    # try:catch:
    try:catch: = func [:blk catch: :handler do blk]
  ]"""
