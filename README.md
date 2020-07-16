# CodeQL Ruby

This repo contains tools and example queries to use [CodeQL](https://securitylab.github.com/tools/codeql) to analyze and query Ruby codebases. Inspired by the [open-source CodeQL Go library](https://github.com/github/codeql-go) and taking some cues from the [CodeQL JavaScript extractor](https://github.com/github/codeql/tree/master/javascript/extractor), this project provides:

- a [QL database schema](https://help.semmle.com/codeql/advanced-glossary.html#ql-database-schema) defining Ruby semantics for the CodeQL engine
- an [extractor](https://help.semmle.com/codeql/glossary.html#extractor) to generate a [CodeQL database](https://help.semmle.com/codeql/about-codeql.html#about-codeql-databases) from a Ruby codebase
- a [CodeQL library](https://help.semmle.com/QL/ql-handbook/modules.html#library-modules) for the Ruby language to allow easy querying

## Proof of Concept

This tool is currently in **proof-of-concept** stage. Not only should you not use this in production, it's currently unusable for research. This will be updated as we get this thing off the ground, but for now it is only online as a demonstration and to allow anyone who would like to to try it out, fork it, or contribute their own code.

Progress will be tracked on [agius/codeql_ruby](https://github.com/agius/codeql_ruby), and you can follow it via:

- [Pull requests](https://github.com/agius/codeql_ruby/pulls) for all code changes

- [Github Projects on this repo](https://github.com/agius/codeql_ruby/projects) - currently on [Phase 2: Usefulness](https://github.com/agius/codeql_ruby/projects/1)

If you have specific thoughts, suggestions, proposals, use cases, etc, please feel free to contact the maintainers:

- [open an issue](https://github.com/agius/codeql_ruby/issues/new) on [agius/codeql_ruby](https://github.com/agius/codeql_ruby) 
- [tweet at @agius](http://twitter.com/agius)
- join us in the `#codeql-hacking` channel in the Github Security Lab Slack team - request an invite on [the Github Security Lab page](https://securitylab.github.com/get-involved)

## Dependencies

This proof-of-concept is currently only tested using the following:

|   tool | version                                                      |
| -----: | ------------------------------------------------------------ |
|  macOS | 10.15 - Catalina                                             |
|   ruby | 2.7.0p0 using [rbenv](https://github.com/rbenv/rbenv)        |
| codeql | [CLI tools](https://help.semmle.com/codeql/codeql-cli/procedures/get-started.html) version 2.2.3 |

More setups will be supported in the future as this gets built out.

## Installation

To use the extractor and query library with CodeQL, you will need to have the CodeQL CLI tools downloaded and set up.

1. Follow the instructions on [Getting Started with the CodeQL CLI](https://help.semmle.com/codeql/codeql-cli/procedures/get-started.html)

2. Verify your CodeQL installation works by running `codeql resolve languages`

3. Clone this repo as a sibling directory to your CodeQL installation. If you follow the conventions outlined in the getting started guide, you can use this command:

   ```shell
   $ pwd
   # $HOME/codeql-home
   
   $ ls
   codeql codeql-repo
   
   $ git clone https://github.com/agius/codeql_ruby.git codeql-ruby-repo
   
   $ ls
   codeql codeql-repo codeql-ruby-repo
   ```

4. Enter the directory and install the executable via the Rake task:

   ```shell
   $ cd codeql-ruby-repo
   
   # install dependencies for development & testing
   $ bundle install
   
   # install the codeql_ruby gem to your local Ruby setup
   $ bundle exec rake install
   ```

5. Symlink the extractor directory from this repo into your CodeQL CLI installation:

   ```shell
   $ cd ~/codeql-home/codeql
   $ ln -s ~/codeql-home/codeql-ruby-repo/extractor ruby
   ```

6. Verify that Ruby is now one of the recognized languages for the CodeQL CLI:

   ```shell
   $ codeql resolve languages
   # ...should see
   # ruby ($HOME/codeql-home/codeql/ruby)
   # ...in the list
   ```

With that, you should be good to go! Check out "Usage" and "Development" below.

## Usage

Currently the extractor extracts all Ruby files nested in the directory from which the extractor is run. Essentially all files found by:

```shell
$ find . -name '*.rb'
```

Expanding extraction to dependencies and related files is a work-in-progress.

You can create a database for the directory by using the codeql create database functionality:

```shell
$ codeql database create ~/codeql-home/example-ruby-db --language=ruby
```

You should then see the CodeQL database in the provided folder:

```shell
$ ls -lha ~/codeql-home/example-ruby-db
...
codeql-database.yml
...
```

You can run queries against this database using the CodeQL CLI - we'll use [the codeql query run command](https://help.semmle.com/codeql/codeql-cli/commands/query-run.html) for simplicity. This will run the spec example query from this repo, which simply outputs all nodes:

```shell
$ codeql query run --database=<db_dir> spec/spec/base_unsafe_script/example.ql
# ...snip output
Starting evaluation of base-unsafe-script-ruby-queries/example.ql.
Evaluation completed (110ms).
| col0 |         col1         |
+------+----------------------+
| eval | This is a leaf node. |
| ARGV | This is a leaf node. |
| 1    | This is a leaf node. |
```

For more about learning CodeQL, see [Semmle / Github / Microsoft's guides here](https://help.semmle.com/QL/learn-ql/).

### Using with Visual Studio Code

To use the ruby library with Visual Studio Code, first you'll need to follow [the setup instructions for CodeQL in VS Code](https://help.semmle.com/codeql/codeql-for-vscode/procedures/setting-up.html). 

If you had already set up the command line via the procedures above, the VS Code extension should detect the command-line installation and use it. You should now be able to use Ruby the same way as any other CodeQL-supported language, by adding the database generated above.

If you have not already set up the CLI, you'll need to do that now, then [change the "Executable Path" setting](https://help.semmle.com/codeql/codeql-for-vscode/reference/settings.html#choosing-a-version-of-the-codeql-cli) in VS Code to ensure it is using your command-line installation (which has the symlinked `ruby` directory for Ruby language support).

## Development

Make sure you've run through the setup procedure above so that the CodeQL CLI is working with Ruby support.

Feature development is ongoing.

Run tests via:

```shell
$ bundle exec rake spec

# ...or...

$ bundle exec rspec
```

The spec suite includes a helper to create a CodeQL ruby database, run a query against it, and get the query results as JSON. It simply shells out to the CodeQL CLI installation to run the commands for you, building a db in the `build/` directory. See `spec_helper.rb` for the code which handles this.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/agius/codeql_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/agius/codeql_ruby/blob/master/CODE_OF_CONDUCT.md).

To contribute a new feature or change:

1. Fork this repo
2. Create a feature branch
3. Add your changes and write tests for them
4. Push your changes to your fork of codeql_ruby
5. Make a pull request to this repo


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CodeqlRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/agius/codeql_ruby/blob/master/CODE_OF_CONDUCT.md).
