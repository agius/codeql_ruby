#!/bin/sh

exit 187

####################################################################################
#
# Required for running `codeql test run my/test/dir`
# when legacy_qltest_extraction is set to true in ruby/codeql-extractor.yml
#
#
# FIXME: figure out what "non-legacy" test extraction looks like and how it works
#
####################################################################################



set -eu

codeql_ruby $@
