class Option
    ###
    ## The Option Class
     Instances of this class represent a single command line option. It can be
     configured to use either a long form where -- is used to denote the option 
     or a shorter form indicated by a single -

     @example
           --longform=<val>
           -short=<val>

     The parsed option is identified on the resulting object by the value defined
     by the prop setter method.

     The object is intended to be used in a fluent way, where setter methods are
     typically chained together to allow for easy construction:

     @example
       option.short("a").long("longname").prop("property").desc("Option description").defaultValue(10)

     The desc property provides additional information about this option when it is printed to
     the console (in the case of a usage request for example).

     The defaultValue property when set, will be used to populate the parsed object in the case
     where no option was supplied on the command line.
    ###

    make_prop = (owner, name, getter, setter) ->
        ###
         Constructs a fluent property method on the owner instance which 
         can be used in the following way:
        
         @example
           instance.prop(value)    # Sets prop to a value of '123'
           value = instance.prop() # Gets the value of prop
        
         The setter method will return back an instance of the owner, enabling
         further fluent property methods to be called.
        ###
        owner[name] = (arg) ->
            if arg?
                setter(arg)
                owner
            else
                getter()

    constructor: (@builder) ->
        ###
         Constructs a new instance of the option instance with the builder reference automatically
         assigned as an attribute on the object.
        
         @param {OptionBuilder} builer The parent builder.
        ###        
        _short = ""
        _long = ""
        _description = ""
        _defaultValue = ""
        _prop = ""

        make_prop this, "short",        ( -> _short),       ((arg) -> _short = arg)
        make_prop this, "long",         ( -> _long),        ((arg) -> _long = arg)
        make_prop this, "desc",         ( -> _description), ((arg) -> _description = arg)
        make_prop this, "defaultValue", ( -> _defaultValue),  ((arg) -> _defaultValue = arg)
        make_prop this, "prop",         ( -> _prop),        ((arg) -> _prop = arg)

    describe: () ->
        ###
        Returns a string that describes the settings for this option instance
        When all properties are supplied, the string will be of the form:
        
         @example
           -[short name], --[long name]=[default value] [description]
        ###
        sb = []
        
        if @short() isnt ""
            sb.push "-#{@short()}"
            if @long() isnt ""
                sb.push ", "

        if @long() isnt ""
            sb.push "--#{@long()}"

        if @defaultValue() isnt ""
            sb.push "=#{@defaultValue()} "
        else
            sb.push "=<val> "

        sb.push @desc()
        sb.join ""

    matches: (key) ->
        ###
         Returns a value indicating whether this option instance matches the key provided.
         A match is case sensitive, matching on either the configured short or long forms
        
         @example
            option = builder.add().short("s").long("long")
        
            option.matches("-s")  # returns true
            option.matches("--long")  # returns true
            option.matches("--s")  # returns false, s is not the long form for this option
        ###
        if @short() isnt "" and "-#{@short()}" is key
            return true
        if @long() isnt "" and "--#{@long()}" is key
            return true
        false

class OptionBuilder
    ###
     The OptionBuilder class
    ---------------------------
     This class represents the main builder used to construct the command line options expected
     by the calling application.  Once all options are constructed, the instance can be used
     to parse an array of command line arguments of the form --longform=value -short=value
     
     The results of the parse method will be an object containing attributes representing each
     of the parsed arguments.

     Unknown arguments are stored on the returned instance as an array, accessible from the _
     attribute.

     A method is also added to the returned object to indicate whether the object is valid.
     A value of false returned from this method indicates that at least one configured option
     is absent from the returned object.
    ###

    constructor: ->
        ###
         Constructs a new instance of the option builder.
        ###
        @options = []
        @verbose = false

    add: () ->
        ###
        Adds and returns a new option instance to the builder.
         
        @example
          builder.add().short("s").long("long")
        
        In order to return back to the builder instance in a fluent manor, simply
        use the builder property on the option returned by add:
        
        @example
          builder.add().short("s").builder.add().short("another")
        ###
        option = new Option(this)
        @options.push option
        option

    count: () ->
        ### Returns the number of options the builder contains ###
        @options.length

    print: (programName, writer) ->
        ###
        Prints usage information based on the options configured within the builder.
        
        @param {String} programName The name to appear in the usage banner
        @param {Function} writer The writer to invoke with each line of text 
        ###
        writer("Usage: ")
        writer("")
        writer("#{programName} [options]")
        writer("")
        @options.forEach (opt) -> writer (opt.describe())

    parse: (args) ->
        ###
        The main method to parse the supplied input arguments in order to construct
        an object to represent these options.
        
        The arguments supplied should be of the form
        
         @example
            --longarg=value1 -short=s
        
         If the following command line arguments were supplied:
        
          --address=http://www.google.com -q=nodejs
        
         The options could be parsed in the following way:
        
         <pre>
        
          builder = require('options').builder()
          builder.add().short("a").long("address").prop("address").desc("The address to browse to")
          builder.add().short("q").long("query").prop("query").desc("The query string to submit")
          builder.add().short("o").long("optional").prop("optionalArg").desc("An optional arg").defaultValue("test")
        
        
          args = require('system').args
          options = builder.parse args
          console.log options.address  # should print http://www.google.com
          console.log options.query    # should print 'nodejs'
          console.log options.optional # should print 'test'
          console.log options.isValid() # Should print true
          </pre>
        ###
        if @count() is 0
            throw new Error("No options have been defined")

        result = {}
        
        # store any unknown switches / arguments in an array
        result._ = []

        array_args = [].concat args

        if @verbose
            console.log "Parsing arguments: #{array_args.join(',')}"

        # enumerate the input arguments and map them to switches
        array_args.forEach (arg) =>
            keyValue = arg.split "="
            if keyValue? and keyValue.length is 2
                opt = @options.filter((opt) -> opt.matches(keyValue[0]))
                if opt.length is 0
                    if @verbose
                        console.log "Unknown argument #{keyValue[0]} found, storing in bucket"
                    result._.push keyValue
                else
                    firstOpt = opt[0]
                    if @verbose
                        console.log "Found argument #{firstOpt.prop()}"
                    result[firstOpt.prop()] = keyValue[1] or firstOpt.defaultValue()

        # fill in any missing arguments if they contain default values
        for opt in @options
            if not result[opt.prop()] and opt.defaultValue() isnt ""
                result[opt.prop()] = opt.defaultValue()

        result.isValid = () =>
            allValid = true
            @options.forEach (opt) ->
                if @verbose
                    console.log "Testing result for presence of #{opt.prop()}"
                if not result[opt.prop()]?
                    if @verbose
                        console.log "Missing required property #{opt.prop()}"
                    allValid = false
            allValid

        result

# Return a class reference
exports.OptionBuilder = OptionBuilder

# Constructs a new instance and returns this
exports.builder = () -> new OptionBuilder()