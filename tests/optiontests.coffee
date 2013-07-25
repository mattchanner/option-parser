
exports.testOptionProperties = (test) ->

    builder = require("../src/options").builder()

    option = builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    test.equal(option.desc(), "desc", "Exported desc to be 'desc', found #{option.desc()}")
    test.equal(option.long(), "test", "Exported long form to be 'test', found #{option.long()}")
    test.equal(option.short(), "t", "Exported short form to be 't', found #{option.short()}")
    test.equal(option.defaultValue(), 10, "Exported default value of 10, found #{option.defaultValue()}")
    test.equal(option.prop(), "TEST", "Exported prop to be TEST, found #{option.prop()}")
    
    test.done()

exports.testOptionDescribe = (test) ->
    builder = require("../src/options").builder()

    option = builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    desc = option.describe()
    test.equal(desc, "-t, --test=10 desc")
    test.done()

exports.testOptionDoesMatch = (test) ->
    builder = require("../src/options").builder()

    option = builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    test.ok(option.matches("-t"), "Expected -t to match option when short form is set to 't'")
    test.ok(option.matches("--test"), "Expected --test to match option when long form is set to 'test'")

    test.done()

exports.testOptionoesNotMatch = (test) ->
    builder = require("../src/options").builder()

    option = builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    test.ok(not option.matches("--test2"), "Expected --test2 to NOT match option when long form is set to 'test'")
    test.ok(not option.matches("-tt"), "Expected -tt to NOT match option when short form is set to 't'")
    test.done()

exports.testBuilderAddMultiple = (test) ->    
    builder = require("../src/options").builder()

    builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")
    .builder.add()
        .long("test2")
        .short("t2")
        .desc("desc2")
        .defaultValue(20)
        .prop("TEST2")

    test.equal(2, builder.count(), "Expected an option count of 2, found #{builder.count()}")
    test.done()

exports.testParseSingleshort = (test) ->
    builder = require("../src/options").builder()

    builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    result = builder.parse ["-t=test"]
    test.ok(result?)
    test.ok(result.TEST?)
    test.equal(result.TEST, "test")
    test.done()

exports.testUnknownArgs = (test) ->
    builder = require("../src/options").builder()

    builder.add()
        .long("test")
        .short("t")
        .desc("desc")
        .defaultValue(10)
        .prop("TEST")

    result = builder.parse ["-u=unknown"]
    test.ok(result?)
    test.equal(1, result._.length)
    test.equal(result._[0][0], "-u")
    test.equal(result._[0][1], "unknown")
    test.done()

exports.multipleArguments = (test) ->
    builder = require("../src/options").builder()

    builder.add()
        .long("width").short("w").desc("The width of the path").defaultValue("700px").prop("width")
    .builder.add()
        .long("username").short("u").desc("The username to authenticate with").prop("username")

    test.equal(builder.count(), 2)

    first = builder.options[0]
    test.equal(first.long(), "width", "Expected long to be 'width' for first argument, but was #{first.long()}")

    test.done()

exports.testRealWorldExample = (test) ->

    builder = require("../src/options").builder()

    builder.add()
        .long("width").short("w").desc("The width of the path").defaultValue("700px").prop("width")
    .builder.add()
        .long("username").short("u").desc("The username to authenticate with").prop("username")
    .builder.add()
        .long("password").short("p").desc("The password to authenticate with").prop("password")
    .builder.add()
        .long("address").short("a").desc("The address of the site to launch").prop("address")
    .builder.add()
        .long("identifier").short("id").desc("The id to display").prop("id")

    result = builder.parse ["--width=600px", "-u=Administrator", "--password=Administrator2", "-id=12345", "-a=http://www.google.com"]
    
    builder.print "test", console.log
    test.equal(result.width, "600px", "Width should be 600px but was #{result.width}")
    test.equal(result.username, "Administrator", "Username should be Administrator but was #{result.username}")
    test.equal(result.password, "Administrator2", "Username should be Administrator2 but was #{result.password}")
    test.equal(result.address, "http://www.google.com", "Address should be http://www.google.com but was #{result.address}")
    test.equal(result.id, "12345", "id should be 12345 but was #{result.id}")

    test.done()

exports.parseThrowsErrorWhenNoOptionsAreDefined = (test) ->
    builder = require("../src/options").builder()

    test.throws ->
        builder.parse ["-a=jhdjk"]

    test.done()

exports.parseAddsOptionsWithDefaultsWhenNotSupplied = (test) ->
    builder = require("../src/options").builder()

    builder.add()
        .long("width").short("w").desc("The width of the path").defaultValue("700px").prop("width")
    .builder.add()
        .long("username").short("u").desc("The username to authenticate with").prop("username")
    .builder.add()
        .long("password").short("p").desc("The password to authenticate with").prop("password")

    result = builder.parse ["-u=Administrator", "--password=Administrator2"]

    test.equal(result.width, "700px", "Width should be set to the default value of 700px when not supplied, but was #{result.width}")
    test.equal(result.username, "Administrator", "Username should be Administrator but was #{result.username}")
    test.equal(result.password, "Administrator2", "Username should be Administrator2 but was #{result.password}")

    test.done()
