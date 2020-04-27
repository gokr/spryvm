# Package
version       = "0.9.0"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language interpreter in Nim"
license       = "MIT"
skipDirs      = @["tests"]

# Deps
requires "nim >= 1.2.0"
requires "python"
requires "ui"
requires "snappy"
requires "rocksdb <= 0.2.0"

task test, "Run the tests":
  withDir "tests":
    exec "nim c -r all"
