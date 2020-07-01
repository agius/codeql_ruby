#!/bin/sh

set -eu

if [ "$CODEQL_PLATFORM" != "osx64" ] ; then
  echo "Automatic build detection for $CODEQL_PLATFORM is not implemented."
  exit 1
fi

# CODEQL_EXTRACTOR_RUBY_SOURCE_ARCHIVE_DIR=/Users/agius/Projects/codeql-stuff/codeql-ruby-example/src
# CODEQL_PLATFORM=osx64
# CODEQL_EXTRACTOR_RUBY_LOG_DIR=/Users/agius/Projects/codeql-stuff/codeql-ruby-example/log
# CODEQL_DIST=/Users/agius/codeql-home/codeql
# CODEQL_EXTRACTOR_RUBY_SCRATCH_DIR=/Users/agius/Projects/codeql-stuff/codeql-ruby-example/working
# CODEQL_JAVA_HOME=/Users/agius/codeql-home/codeql/tools/osx64/java
# CODEQL_EXTRACTOR_RUBY_WIP_DATABASE=/Users/agius/Projects/codeql-stuff/codeql-ruby-example
# CODEQL_EXTRACTOR_RUBY_TRAP_DIR=/Users/agius/Projects/codeql-stuff/codeql-ruby-example/trap/ruby
# JAVA_MAIN_CLASS_50625=com.semmle.cli2.CodeQL

"$CODEQL_EXTRACTOR_RUBY_ROOT/tools/$CODEQL_PLATFORM/ruby-autobuilder"
