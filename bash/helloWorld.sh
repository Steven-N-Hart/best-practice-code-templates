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

# Get the DUMMY_VERSION parameter from the config file, if it exists
# otherwise, set it to NA
if  [[ "$CONFIG_FILE" ]]
then
  source "$CONFIG_FILE"
else
  DUMMY_VERSION="NA"
fi


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

#Vaidate required input
if [[ -z "$NUM_REPEATS" ]] || [[ "$NUM_REPEATS" -le 0 ]] && [[ -z "$RUN_TEST" ]] && ! [[ "$NUM_REPEATS" =~ ^[0-9]+$ ]]
then
  logError "ERROR" E001 "You need to supply a number to the\n\tprint_statement function, but you supplied \"$NUM_REPEATS\"\n\tSee -h for details"
  exit
fi

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
    echo $EXPECTED > exp.out
    echo $OBSERVED > obs.out
  fi
}

# This just indicates which tests to run
#    you can add more tests here if you need to
function run_tests {
  print_test_x2 PASS
  print_test_x2 FAIL
}

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