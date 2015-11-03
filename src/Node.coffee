require './connectionParameters'
Connection = require './connection'

# A Node can be something like a plate or 3D Snippet3D
# which can have multiple adjacent Nodes which need
# to have a connector

class Node
  constructor: ->
    @connectionList = []

  addConnection: (node, parameters) ->
    connection = new Connection(node, parameters)
    @connectionList.push connection


module.exports = Node
