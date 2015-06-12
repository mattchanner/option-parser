OptionBuilder
=============

A javascript \ coffeescript command line options parser compatible with node.js and phantomjs environments.

This class represents the main builder used to construct the command line options expected by the calling application.  
Once all options are constructed, the instance can be used to parse an array of command line arguments of the form 

--longform=value -short=value
     
The results of the parse method will be an object containing attributes representing each of the parsed arguments.

Unknown arguments are stored on the returned instance as an array, accessible from the _ attribute.

A method is also added to the returned object to indicate whether the object is valid. A value of false returned 
from this method indicates that at least one configured option is absent from the returned object.


Example usage (taken from the test cases):

    builder = require("../src/options").builder()

    option = builder.add()
                    .long("test")
                    .short("t")
                    .desc("Describes the option t")
                    .defaultValue(10)
                  .prop("TEST")
