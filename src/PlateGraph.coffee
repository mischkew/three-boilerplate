require './node'
ConnectionParameters = require './connectionParameters'
Connection = require './connection'

class PlateGraph
  constructor: ->
    @nodes = []

  addNode: (node) ->
    @nodes.push node

  addConnection: (node1, node2, angle, joint, intersectionLine) ->
    parameters = new ConnectionParameters(angle, joint, intersectionLine)
    node1.addConnection(node2, parameters)
    node2.addConnection(node1, parameters)


module.exports = PlateGraph
