README
======

Implements checks for some of the
[Ruby](https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE)
style guide items.

This tool is meant to be use as a pre-commit hook for git, to ensure the code
is properly formatted. Run the following
    cd .git/hooks
    ln -s /path/to/bin/rstyle
and you'll have to be compliant with the rstyle checks to be able to commit
code to the repository.

It can also be used to check one or more ruby files in standalone mode:
    rstyle /path/to/rubyfile.rb

Style checks
============

The style checker looks for the following:

* line longer than 80 characters
* empty line contains whitespace
* line contains tab(s)
* line ends with whitespace
* no space after ,
* space after ( and [ or before ) and ]
* methods should be in snake_case

It will also issue warnings for the following:

* don't use for unless you know what you are doing
