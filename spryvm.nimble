# Package
version       = "0.9.4"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language interpreter in Nim"
license       = "MIT"
skipDirs      = @["tests"]

# Deps
requires "nim >= 2.0.0"
requires "python"
requires "ui"
requires "supersnappy"
requires "smtp"
requires "db_connector"
requires "https://github.com/capocasa/limdb"

task test, "Run the tests":
  withDir "tests":
    exec "nim c -r all"
