# BEST PRACTICES FOR ANY SCRIPTING
1.  [Comment too often](#comment-too-often)
2.  [Always have a detailed usage statement](#always-have-a-detailed-usage-statement)
3.  [ConSisTant CASe](#consistant-case)
4.  [Functions, Functions, Functions](#functions,-functions,-functions)
5.  [Unit tests](#unit-tests)
6.  [Explicit variable names](#explicit-variable-names)
7.  [Version control](#version-control)

# Comment too often
This is the most important feature of any code.  You really need to comment the hell out of your code.  If you don't, you and others will pay the price later.
<img src="http://allthingsoracle.com/wp-content/uploads/2011/11/Oracle-development-comments-code.png" height=200>

# Always have a detailed usage statement
Running a script without any arguments, `-h`, or `--help` should always print a usage statement.  The statements should detail what all the command line parameters are, and prefereably what the range of acceptable values are.  This is the most important piece of documentation for your end users, since few will actually open up your code to dig into it to see what it's doing.  Be very clear about what influence each of the parameters are.  You should also identify any default values here as well.

# ConSisTant CASe
Try to follow as standard use of case in your code.  I prefer to use [camelCase](https://en.wikipedia.org/wiki/CamelCase) for consistency, but sometimes I will use uppercase variables for FILE inputs to my scripts.  The reason you want this consistency is to prevent any bugs in your code where you capitalized a variable name when it should have not been.

# Functions, Functions, Functions
This is one I am still have trouble with, but it is the most critical when it comes to [unit testing](https://en.wikipedia.org/wiki/Unit_testing).  Unit testing should be done only on 1 function at a time.  If you can write your code in a function, do it.  It makes things re-useable, and the main part of your code more readable.  Most tasks can be put into small functions like reading in a file, reordering columns of data, or performing a transformation of data.

# Unit tests
[Unit tests](https://en.wikipedia.org/wiki/Unit_testing) are also known as function tests.  They test that your function is producing the expected result.  You should always test both a postive and a negative control.  More specific examples of unit tests are described in the individual code sections.

# Explicit variable names
Generic variable names like `a` or `temp` are completely uninformative and make your code harder to understand.  If your variable contains the line of an input file, try to call it `$line` or `$lineFromInput` so it is easier to remember what data it actually contains.

# Version control
If you don't use version control, you should drop everything and learn how to use it.  There are tons of online video tutorials that can help with this.  You can also learn to use it correctly by following a predefined branching strategy.  Several good stratgies are located [here](https://www.atlassian.com/git/tutorials/comparing-workflows/).  We tend to use the [GitFlow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) strategy at my place of work, but if you like something else, use that.  I will have a [best practices document](https://github.com/Steven-N-Hart/best-practice-code-templates/blob/master/git/README.md) for gitflow as part of this series.

