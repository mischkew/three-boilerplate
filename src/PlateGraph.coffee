require './node'
ConnectionParameters = require './connectionParameters'
Connection = require './connection'

class PlateGraph
  constructor: ->
    @nodes = []

  addNode: (node) ->
    @nodes.push node

  addConnection: (node1, node2, angle, joint) ->
    parameters = new ConnectionParameters(angle, joint)
    node1.addConnection(node2, parameters)
    node2.addConnection(node1, parameters)


module.exports = PlateGraph
