Node = require './node'

class Plate extends Node
  constructor: (@shape, @thickness, @planeConstant, @name) ->
    super()
    # thickness in the direction of the normal


module.exports = Plate
