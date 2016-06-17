# Writing good clean code for bioinformatics

## Background
Bioinformaticians are the cowboys of the programming world.  Many of us are self-taught programmers that spend most of our days writing one-off scripts that are hacked together in a rushed attempt to "get things done".  While functional, this approach makes it a nightmare to review code - be it from colleagues or the original author.

One big concerns with bioinformatics is that the field is littered with different programming languages like Bash, Python, Perl, Java, JavaScript, Go, Docker, SQL, NoSQL, R, and many others.  Therefore to get the answer one is looking for involves loosely chaining together various scripts in different languages.  This makes it difficult to standardize testing frameworks that may only work for (certain platforms)[https://en.wikipedia.org/wiki/List_of_unit_testing_frameworks].  So it's just not practical to select an overall unit testing framework.

## Proposal
A lot of bioinformatics work is script based, rather than full-on program, so there really isn't a good way to do unit tests without forming some sort of directory/package structure where you can place your tests and configure a test runner.

...or so you thought!  

In this repo, we will try to build examples for writing good clean testable code inside individual scripts.  Don't agree with my style?  Submit a pull request and we'll try and make this useful for lots of people.  I am not an expert - just someone who struggles with this everyday.

## Have Fun!
Defining a set of best practices may rub some people the wrong way - after all, who am I to do that?  But I at least hope to spark some interest from others in the community that could help out with this.  I could see a lot of people get value out of this, so help if you can.