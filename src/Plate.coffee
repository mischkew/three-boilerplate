Node = require './Node'

class Plate extends Node
  constructor: (@shape, @thickness) ->
    super() # thickness in the direction of the normal


module.exports = Plate
