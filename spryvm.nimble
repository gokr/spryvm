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
requires "https://github.com/status-im/nim-rocksdb.git#5b1307cb1f4c85bb72ff781d810fb8c0148b1183"

task test, "Run the tests":
  withDir "tests":
    exec "nim c -r all"
