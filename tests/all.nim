{.warning[UnusedImport]:off.}
# The imports work via side effects - when each test module is imported,
# it registers its test suite with the unittest framework, which then runs them all.
import testspryvm
import testsprycore
import testsprymath
import testsprystring
import testspryblock
import testspryoo
import testspryio
import testspryos
import testspryreflect
import testsprycompress
import testsprymemfile
import testspryextend
import testspryjson
import testsprysqlite
import testsprylimdb
