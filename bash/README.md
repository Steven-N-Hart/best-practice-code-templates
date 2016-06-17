# BEST PRACTICES FOR BASH SCRIPTING
1.  [The shebang](#the-shebang)
2.  [`set` options](#set-options)
3.  [Defaults and Documentation](#defaults-and-documentation)
4.  [Use `getopts`](#use-getopts)
5.  [Source configuration files](#source-configuration-files)
6.  [Structure](#structure)

# The shebang
The first lines of code I add to my bash script are about the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)).  This tells the operating system what type of interpreter to use if one is not provided.  For example, if the bash interpreter is located at `/bin/bash` and the shebang in your script (we'll use dummy_program.sh) is set to `#!/bin/bash`, then 
`./dummy_program.sh` and `bash ./dummy_program.sh` are equivalent.  However, this is essentially hard coding a path, which I don't like to do.  Instead, I leverage the environment varialbe (`env`) to tell me where my bash is using the following syntax: 
`#!/usr/bin/env bash`.

# `set` options
Bash has a lot of little neat tricks that can be super helpful and should always be use (IMHO).  
* `set -e` tells your script to exit if a command fails. 
* `set -u` tells your script to exit if you try to use an undeclared variable
* `set -x` prints out a log of the commands run, useful for debugging.  I usually thie this value into `getopts` (see below) as a verbose option.

# Defaults and Documentation
In the next section of code is where I set any of my default variables - if there are any.  I put them here because I will read in variables from the command-line in the next step.  If any optional command-line parameters are defined, they will override my defaults.  In this case, let's assume I set some arbitrary default value: `MY_MESSAGE="Hello World!"`.

Next, I add a plain english description of what my code is, what it expects as input, and what it outputs.

After that, I set my `usage` function to describe all of the options and relevant infomration that I want to share with the user.

So far, we have the 3 lines that should be in EVERY bash file as well as a descripion and any default options
```bash
#!/usr/bin/env bash
set -e
set -u

#####################################################################
###  Descripion
#####################################################################
The purpose of this script is to print a phrase n times. It requires
a number value to tell it how many times to repeat.  If a phrase is
not specified, "Helo World!" will be used.

#####################################################################
###  Set default thresholds
#####################################################################
MY_MESSAGE="Hello World!"
usage ()
{
cat << EOF

Usage: ./dummy_program.sh [options] <num_repeats>

REQUIRED
	num_repeats:	an iteger that determines how many times to repeat the message

OPTIONAL
	-m 	message to repeat [default: "Hello World!"]
	-t  run unit test only
	-h 	print this help message

NOTES
	If specifying a message, make sure to include it in double quotes

EOF
}

```
You can see that I have clearly delineated the default thresholds into its own section.  This makes finding things easier later.  I also clearly define what are the required, optional, and default parameters used as well as any pertinent notes for the user.

# Use `getopts`
Here comes the fun stuff.  When I want to pass parameters from the command-line, I use getopts.  Here is the basic structure of `getopts`:
```bash
while getopts "m:th" OPTION; do
  case $OPTION in
    m)  MY_MESSAGE=$OPTARG ;;    # Overwrite "Hello World!" default if provided
    h)  usage                    # Help and exit
        exit ;;
    t)  RUN_TEST=true ;;
    \?) echo "Invalid option: -$OPTARG. See output file for usage." >&2
        usage
        exit ;;
    :)  echo "Option -$OPTARG requires an argument. See output file for usage." >&2
        usage
        exit ;;
  esac
done
```
What this bit is doing is looping through and parsing all the command-line parameters that are supplied with the script.  Notice the  `:` in `m:`.  This means that there is a value afer message that needs to be imported.  The `h` and the `t` don't have one because they are flags.  If a message is specified, the special `$OPTARG` variable will set `$MY_MESSAGE` to be the quoted string supplied from the CLI. If the `h` flag is specified, it immediately triggers the `usage` function we defined above and exits.  I'm using the `t` flage here to set a variable I will use later that determines if I should run the code, or just the unit tests.  The last two options getting parsed just make sure that no undefined paramters get used and that those with a `:` are required to have some value (i.e. are not flags).
