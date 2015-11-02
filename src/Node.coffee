require './ConnectionParameters'
require './Connection'

class Node
  constructor: ->
    @connectionList = []

  addConnection: (node, parameters) ->
    connection = new Connection(node, parameters)
    @connectionList.push connection


module.exports = Node
