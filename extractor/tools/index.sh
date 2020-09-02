#!/bin/sh

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

echo "running index.sh"
echo "CODEQL_PLATFORM: $CODEQL_PLATFORM"
echo "CODEQL_EXTRACTOR_RUBY_ROOT: $CODEQL_EXTRACTOR_RUBY_ROOT"
ls -lha "$CODEQL_EXTRACTOR_RUBY_ROOT/tools/$CODEQL_PLATFORM/"

if [ "$CODEQL_PLATFORM" != "linux64" ] && [ "$CODEQL_PLATFORM" != "osx64" ] ; then
    echo "Automatic build detection for $CODEQL_PLATFORM is not implemented."
    exit 1
fi

"$CODEQL_EXTRACTOR_RUBY_ROOT/tools/$CODEQL_PLATFORM/ruby-autobuilder"
