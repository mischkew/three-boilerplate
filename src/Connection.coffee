require './connectionParameters'

class Connection
  constructor: (node, parameters) ->
    @node = node
    @parameters = parameters


module.exports = Connection