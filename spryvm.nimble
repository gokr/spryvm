# Package
version       = "0.7.1"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language interpreter in Nim"
license       = "MIT"
skipDirs      = @["examples", "examples/browser", "tests"]

# Deps
requires "nim >= 0.17.0"
requires "python"
requires "ui"
requires "nimsnappy"

when defined(nimdistros):
  import distros
  if detectOs(Ubuntu):
    foreignDep "libsnappy-dev"
  elif detectOs(MacOSX):
    foreignDep "snappy"
  elif detectOs(Windows):
    foreignDep "snappy"

task test, "Run the tests":
  withDir "tests":
    exec "nim c -r all"
