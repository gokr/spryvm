# Package
version       = "0.9.5"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language interpreter in Nim"
license       = "MIT"
skipDirs      = @["tests"]

# Deps
requires "nim >= 2.2.6"
requires "python"
requires "ui"
requires "supersnappy"
requires "smtp"
requires "db_connector"
requires "https://github.com/capocasa/limdb"

# Run all tests in a single compilation unit (faster)
task testall, "Run the tests":
  withDir "tests":
    exec "nim c -r all"

# Run tests with colors using testament
task testament, "Run all tests using testament":
  withDir "tests":
    exec "testament --colors:on pattern 'test*.nim'"