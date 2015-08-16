should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

describe "Message Console", ->

    msg_console = null
    beforeEach ->
        msg_console = new engine.MessageConsole()

    it "adds messages to history", ->
        msg_console.show_message "foo"
        msg_console.messages[0].should.equal "foo"

    it "handles variables properly", ->
        msg_console.show_message "Q: %@ + %@ = %@", 2, 2, "what?"
        msg_console.messages[0].should.equal "Q: 2 + 2 = what?"

    it "restores messages from save", ->
        msg_console.show_message "foo"
        data = msg_console.get_save_data()
        msg_console = new engine.MessageConsole data
        msg_console.messages[0].should.equal "foo"
