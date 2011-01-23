README
======

Implements checks for some of the
[Ruby](https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE)
style guide items.

This tool is mean to use as a pre-commit hook for git, to ensure the code is
properly formatted. Run the following
    cd .git/hooks
    ln -s /path/to/bin/rstyle
and you'll have to be compliant with the rstyle checks to be able to commit
code to the repository.