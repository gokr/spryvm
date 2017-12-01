#!/bin/bash
export HERE="$(dirname "$(readlink -f "$0")")"

# Core Spry
echo "***************  Core Spry implementation  **************"
cloc --exclude-dir=nimcache --read-lang-def=$HERE/cloc-nim $HERE/../spryvm
echo
echo
echo

# Core Spry tests
echo "***************  Core Spry tests  **************"
cloc --exclude-dir=nimcache --read-lang-def=$HERE/cloc-nim $HERE/../tests
echo
echo
echo

# The rest
echo "***************  Examples  **************"
cloc --exclude-ext=js --exclude-dir=nimcache --read-lang-def=$HERE/cloc-nim $HERE/../examples
echo
echo
echo


