# Package
version       = "0.8.0"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language interpreter in Nim"
license       = "MIT"
skipDirs      = @["examples", "examples/browser", "tests"]

# Deps
requires "nim >= 0.20.2"
requires "python"
requires "ui"
requires "snappy"

task test, "Run the tests":
  withDir "tests":
    exec "nim c -r all"
