# BEST PRACTICES FOR BASH SCRIPTING
1.  [The shebang](#the-shebang)
2.  [`set` options](#set-options)
3.  [Defaults and Documentation](#defaults-and-documentation)
4.  [Use `getopts`](#use-getopts)
5.  [Source configuration files](#source-configuration-files)
6.  [Structure](#structure)
    * [Writing the Test](#writing-the-test)
    * [Writing the Function](#writing-the-function)
    * [Tying together the test and function](#tying-together-the-test-and-function)
    * [The whole thing](#the-whole-thing)
7.  [Summary](#summary)


# The shebang
The first lines of code I add to my bash script are about the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)).  This tells the operating system what type of interpreter to use if one is not provided.  For example, if the bash interpreter is located at `/bin/bash` and the shebang in your script (we'll use dummy_program.sh) is set to `#!/bin/bash`, then `./dummy_program.sh` and `bash ./dummy_program.sh` are equivalent.  However, this is essentially hard coding a path, which I don't like to do.  Instead, leverage the environment varialbe (`env`) to tell where my bash is using the following syntax: 
`#!/usr/bin/env bash`.

# `set` options
Bash has a lot of little neat tricks that can be super helpful and should always be use (IMHO).  
* `set -e` tells your script to exit if a command fails. 
* `set -u` tells your script to exit if you try to use an undeclared variable
* `set -x` prints out a log of the commands run, useful for debugging.  I usually thie this value into `getopts` (see below) as a verbose logging option.

# Defaults and Documentation
In the next section of code is where I set any of my default variables - if there are any.  I put them here because I will read in variables from the command-line in the next step.  If any optional command-line parameters are defined, they will override my defaults.  In this case, let's assume I set some arbitrary default value: `MY_MESSAGE="Hello World"`.

Next, I add a plain english description of what my code is, what it expects as input, and what it outputs.

After that, I set my `usage` function to describe all of the options and relevant information that I want to share with the user.

So far, we have the 3 lines that should be in EVERY bash file as well as a descripion and any default options
```bash
#!/usr/bin/env bash
set -e
set -u

#####################################################################
###  Descripion
#####################################################################
# The purpose of this script is to print a phrase n times. It requires
# a number value to tell it how many times to repeat.  If a phrase is
# not specified, "Helo World" will be used.

#####################################################################
###  Set default thresholds & collect inputs
#####################################################################
# Initialize global variables
MY_MESSAGE="Hello World"
CONFIG_FILE=""
NUM_REPEATS=""
RUN_TEST=""

usage (){
cat << EOF

Usage: ./dummy_program.sh [options] -n <num_repeats>

REQUIRED
  -n   an integer that determines how many times to repeat the message

OPTIONAL
  -m   message to repeat [default: "Hello World"]
  -c   configuration file 
  -t   run unit test only
  -l   print out log messages
  -h   print this help message

NOTES
  If specifying a message, make sure to include it in double quotes.
  The configuration file should contain a version number as a variable.

EOF
exit
}

```
You can see that I have clearly delineated the default thresholds into its own section.  This makes finding things easier later.  I also clearly define what are the required, optional, and default parameters used as well as any pertinent notes for the user.

# Use `getopts`
Here comes the fun stuff.  When I want to pass parameters from the command-line, I use getopts.  Here is the basic structure of `getopts`:
```bash
# Read in command line arguments
while getopts "n:m:c:lht" OPTION; do
  case $OPTION in
    n)  NUM_REPEATS=$OPTARG ;;   # Get the number of repeats
    m)  MY_MESSAGE="$OPTARG" ;;  # Overwrite "Hello World" default if provided
    c)  CONFIG_FILE=$OPTARG ;;   # Configuration file
    l)  set -x ;;                # Turn on debugging mode
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
What this bit is doing is looping through and parsing all the command-line parameters that are supplied with the script.  Notice the  `:` in the `n:`, `m:`, and `c:` parameters?  This means that there is a value after the flag that needs to be imported.  If a message is specified, the special `$OPTARG` variable will set `$MY_MESSAGE` to be the quoted string supplied from the CLI.  The `l`, `h`, and `t` parameters don't have one because they are flags. If `-h` is specified, it immediately triggers the `usage` function we defined above and exits.  I'm using the `t` flag here to set a variable I will use later that determines if I should run the code, or just the unit tests.  The last two options getting parsed just make sure that no undefined paramters get used (`\?`) and that those with a `:` are required to have some value (i.e. are not flags).

# Source configuration files
Using `getopts` is great for interactive analysis, but if you want to run a script multiple times, its best to set up a configuration file that sets variables for you so you don't have to have a very long command.  This is where I like to put anything where the paths have to be hard coded (such as versions of tools I want to use) or any varibles nested inside complicated scripts.  The simplist config file is a simple text file that sets variables.  Take this config file for example:
```bash
DUMMY_VERSION="1.0"
```
It is just a text file that sets an environment variable `DUMMY_VERSION` to `1.0`.  Not a very useful variable in this example, but you get the idea.  To have access to the `DUMMY_VERSION` variable, you need to add the following to your code:
```bash
# Get the DUMMY_VERSION parameter from the config file, if it exists
# otherwise, set it to NA
if  [[ "$CONFIG_FILE" ]]
then
	source "$CONFIG_FILE"
else
	DUMMY_VERSION="NA"
fi
```
Here I made sure that there was a file passed from the CLI (option `-c`) before I sourced it.  By using the `source` function, I have now made the `DUMMY_VERSION` variable available to this script.  If no config file was provided, I set the value to `NA`.  Either way, I now have made sure that I have a value set for `DUMMY_VERSION`.

The next step is to do any input validation.  Here, I am making sure the `$NUM_REPEATS` variable is not null (it's a required argument), making sure it's a number > 0, and ensuring that I didn't specify that I want to run tests.  This way when I run my test,  I don't have to supply a `-n` parameter
```bash
#Vaidate required input
if [[ -z "$NUM_REPEATS" ]] || [[ "$NUM_REPEATS" -le 0 ]] && [[ -z "$RUN_TEST" ]] && ! [[ "$NUM_REPEATS" =~ ^[0-9]+$ ]]
then
  logError "ERROR" E001 "You need to supply a number to the\n\tprint_statement function, but you supplied \"$NUM_REPEATS\"\n\tSee -h for details"
  exit
fi
```

Finally, because some of us are anal-rententive, let's create a simple logging function so that we always report errors in the same fashion.

```bash
# Create a systematic logging function
logError () {
    local LEVEL="${1}"
    local CODE="${2}"
    local MESSAGE="${3}"
    local SCRIPT_NAME=$(basename "$0")
    echo "
################################################################
${LEVEL} ${SCRIPT_NAME} ${SGE_TASK_ID-NA} ${CODE} ${MESSAGE}
################################################################
"
        #Note: the SGE_TASK_ID is a special variable when using the sun grid engine
}
```


# Structure
OK.  This is where it gets hard.  I want to use functions for everything so I can build unit tests, but I also want to be able to run the script so it can do what I want it to do.  Therefore, I need to split my script into a test part and a run part.  I'll do this using functions that I'll need to define.

```bash
if [ -z "$RUN_TEST" ]
then
	# Run the script
	run_main
else
	# Run the testing framework
	run_tests
fi
```

In best-practice style, let's first start with my `run_tests` function.  If we remember, this script is supposed to print out a message repeated `$NUM_REPEATS` times.  To run that function, I need a string to print, and a number of times to repeat it.  So we need to build a series of tests for positive negative examples.

### Writing the Test
Let's say the function we want to test is named `print_statement` - even though we haven't actually built it yet. We
want `print_statement` to accept 2 parameters: the number of times a string needs to be printed, and a string to print.  Notice, I put the required arguments first and the optional argument last.  So let's build an example that shoud print "Hello World" 2 times.  Importantly, we want to capture the result of the function (that we still haven't written yet), so I'll introduce notation to do that as well.  First let's create a function named `print_test_x2` that should return "Hello World" printed exatly twice.
```bash
#####################################################################
###  Define tests
#####################################################################
function print_test_x2 {
  # Set a truth variable so you have something to compare your result to
  # use the "local" designation so we don't overwrite any global variables
  local STATUS=${1:-}
  local EXPECTED="Hello World
Hello World"
  if [ "$STATUS" == "PASS" ]
  then
    local NUM_REPEATS=2
  elif [ "$STATUS" == "FAIL" ]
  then
    #Set a variable that shouldn't pass
    local NUM_REPEATS="NA"
    local EXPECTED="
################################################################
ERROR helloWorld.sh NA E001 Expecting a number but got \"$NUM_REPEATS\"
################################################################"
  else
    #Don't run tests that aren't configured properly
    logError "WARNING" W001 "You need to supply either a PASS or FAIL parameter"
  fi
  # Get the result of the print_statement function (that we haven't made yet) and store it into another local variable called OBSERVED
  local OBSERVED=$(print_statement $NUM_REPEATS)
  # Now make sure that the OBSERVED is what you expect it to be
  if [[ "$OBSERVED" == "$EXPECTED" ]]
  then
    echo "print_test_x2 test $STATUS has passed"
  else
    echo "print_test_x2 test $STATUS has FAILED"
    echo -e "\tOBSERVED:"
    echo -e "\t\t$OBSERVED"
    echo -e "\tEXPECTED:"
    echo -e "\t\t$EXPECTED"
  fi
}

# This just indicates which tests to run
#    you can add more tests here if you need to
function run_tests {
  print_test_x2 PASS
  print_test_x2 FAIL
}
```
Congratulations, we just created our first test!  We created a function (`print_test_x2`) that calls the function we want to test (`print_statement`).  Some key features are:
* Used a conditional `if` statement so we could determine if we wanted a positive (`PASS`) or negative (`FAIL`) result and not have to write new code
* Used a `local` variable setting so we didn't overwrite global variables
* For the failure, we printed out why it failed so we can debug easier
* We still haven't written the function we're testing, but we know what it should and should not be!

# Writing the Function
Now that we have tests built for the function, let's go ahead and build the function.
```bash

#####################################################################
###  Define functions
#####################################################################
# The function will take in at most 2 arguments
# The 1st argument is a number that is for how many times the string should be repeated
# The second argument is the quoted string to be repeated
#     If the 2nd option is not provided, then the default of "Hello World" will be used
function print_statement {

  # The first thing one should do is to validate your inputs
  # Validate that first argument is defined, an integer, at least a value of 1
  if ! [[ "$NUM_REPEATS" =~ ^[0-9]+$ ]]
  then
    echo "##################### ERROR #####################"
    echo "You need to supply a number to the print_statement function"
    echo "Instead, you supplied $NUM_REPEATS"
    exit
  fi
  
  # If the 2nd option is not provided, then the default of "Hello World" will be used
  if [[ "$MY_MESSAGE" &&  -z "$MY_MESSAGE" ]]
    then
    local STATEMENT="Hello World"
  else
    # use the provided message
    local STATEMENT="$MY_MESSAGE"
  fi

  # Print the $STATEMENT $NUM_REPEATS number of times
  for x in $(seq 1 "$NUM_REPEATS")
  do
    echo "$STATEMENT"
  done
}
```
### Tying together the test and function
OK.  Now we have a test and a function, but we need a way for our script to know which one it should run - either the test or the function.  Remeber the wrapper functions we used earlier (`run_main` & `run_tests`), but still didn't define yet?  Let's go ahead and create those functions here.
```bash
#####################################################################
###  Define functions
#####################################################################
# The function will take in at most 2 arguments
# The 1st argument is a number that is for how many times the string should be repeated
# The second argument is the quoted string to be repeated
#     If the 2nd option is not provided, then the default of "Hello World" will be used
function print_statement {
  # The first thing one should do is to validate your inputs
  # Validate that first argument is defined, an integer, at least a value of 1
  
  if ! [[ "$NUM_REPEATS" =~ ^[0-9]+$ ]]
  then
    logError "ERROR" E001 "Expecting a number but got \"$NUM_REPEATS\""
    exit
  fi
  
  # If the 2nd option is not provided, then the default of "Hello World" will be used
  if [[ "$MY_MESSAGE" &&  -z "$MY_MESSAGE" ]]
    then
    local STATEMENT="Hello World"
  else
    # use the provided message
    local STATEMENT="$MY_MESSAGE"
  fi

  # Print the $STATEMENT $NUM_REPEATS number of times
  for x in $(seq 1 "$NUM_REPEATS")
  do
    echo "$STATEMENT"
  done
}

# This just indicates that you want to run the main script, passing it 2 parameters:
# 1. NUM_REPEATS
# 2. MY_MESSAGE
function run_main {
    # make sure to quote your variables to accout for whitespaces
    print_statement "$NUM_REPEATS" "$MY_MESSAGE"
}

```
**__Importantly__**, I am testing the same function (`print_statement`) in both the testing route and the program route.  It just doesn't make sense to test one function and use another.

Then we can string together a conditional statement to determine if the program should be run or tested.
```bash
#####################################################################
###  MAIN
#####################################################################
#Determine if you should run tests or the actual program
if [ -z "$RUN_TEST" ]
then
	# Run the script
	run_main "$NUM_REPEATS" "$MY_MESSAGE"
else
	# Run the testing framework
	run_tests
fi

set +x
```
# The whole thing
You can view the whole thing in [helloWorld.sh](https://github.com/Steven-N-Hart/best-practice-code-templates/blob/master/bash/helloWorld.sh)
# Summary
I know this is probably the longest "Hello World" you've seen, but it's the most basic example of how to write good, clean, testable code.  Some of the best practices covered here include:
* Extensively comment
* Use variable names in a consistant case
* Use descriptive variable names
* Move away from positional operators (`$1`, $2`,etc.) ASAP because they are not descriptive
* Make everything a function
* Validate your file inputs and your functional inputs
* Test things that work, and things that shouldn't work
* Use `local` to set varible names so you don't overwrite global values
* Make sure to test the same function that your program uses
* Write your tests BEFORE you write your function
* Make sure to include your `set` variables to enforce strictness in your code
* Quote all your variables so you don't get tripped up with whitespaces
* Always have an informative help section that contains all the possible CLI options, and thier descriptions
* Point your shebang (`#!`) to the environment instead of the path 
* Initialize any global variables
* Give informative and consistantly formatted error messages
* Seperate your code into distinctive and consistently formatted elements (e.g. MAIN, Define functions, Define tests, etc)