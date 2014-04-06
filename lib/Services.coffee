{CRUD} = require 'node-acl'

exports.Messages = {
	"Register"
	"UnRegister"
	"Operation"
	"Publish"
}


exports.Services = {

	### 
	@param server Server - an instance of the server
	@param entityName String - model name
	@param entityId Int - the entity ID
	@param callback Function(Error, data) - a callback function to be called with the result or error 
	###
	Register : (clientId, server, entityName, entityId, callback) ->
		C = server.getController(entityName)
		C.read(entityId, callback)
		server.listeners.add(clientId,entityName, [ 'update' ], entityId)
		
	### 
	@param String clientId
	@param Server server - an instance of the server 
	@param String entityName - model name 
	@param [ node-acl.CRUD ] crudOps - crud operations 
	@param Int entityId - the entity ID 
	@param Object data - JSON data object 
	@param Function(Error, data) callback - a callback function to be called with the result or error 
	###
	Operation : (clientId, server, entityName, crudOps, entityId, data, callback) ->
		C = server.getController(entityName)
		crudOp = crudOps[0]
		switch crudOp
			when CRUD.read 
				C.read(entityId, callback)
			when CRUD.update
				C.update(entityId, data, callback)
				server.publishEvent(entityName, crudOps, entityId, data)
			else callback(new Error("bad crud operation requested:" + crudOps))


	UnRegister : ()->
		throw "TBD"

	Publish : ()->
		throw "TBD"

}