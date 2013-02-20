{RedisClient} = require '../lib/RedisClient'
{Server} = require '../lib/Server'
{Config} = require '../lib/Config'
{CRUD} = require 'node-acl'
{Services,Messages} = require '../lib/Services'
{Tester} = require './controller/Tester'

sioc = require 'socket.io-client'

__config = Config.get Config.preset.TEST
__server = null
getServerInstance = ()->
	# if _server then _server.
	__server = new Server __config

__client = null
getClientInstance = ()->
	__client = sioc.connect( "http://127.0.0.1", { 'port': __config.server.port , 'reconnect': false, 'force new connection': true})

describe "Server Specs",->

	beforeEach ->
		console.log "==========running new test=========="
		RedisClient.get(__config).flushdb()

	afterEach ->
		RedisClient.destroy(true)
		__server?.shutdown()
		__client?.disconnect()

	it "registers and listens to pub sub on backend",->
		asyncSpecWait()
		server = getServerInstance()
		spy = spyOn(server, "recieveEvent").andCallFake ()-> 
			expect(true).toEqual(true)
			asyncSpecDone()
		server.onPulishReady ()->
			server.publishEvent "some event"

	it "registers request recieved and intercepted by services",->
		asyncSpecWait()
		acl = [ role : "public", model: "tester", crudOps : [CRUD.read] ]
		testObj = { a: "a", b: "b" }
		spy = spyOn(Services, Messages.Register).andCallFake (a,b,c,d,cb)-> 
			cb(null, testObj)
		server = getServerInstance()
		client = getClientInstance()
		client.on 'connect', ->
			client.emit Messages.Register, "tester", [CRUD.read], 1, (err, data)->
				expect(data).toEqual(testObj)
				asyncSpecDone()



	xit "allows creating express server"
	xit "cleans up after disconnection of a client"

		
