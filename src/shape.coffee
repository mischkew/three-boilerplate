EdgeLoop = require './edgeLoop'

class Shape
  constructor: ( edgeLoops ) ->
    @edgeLoops = edgeLoops

  getEdgeLoops: ->
    return @edgeLoops

  getContour: ->
    for edgeLoop in @edgeLoops
      if edgeLoop.hole is false
        return edgeLoop

  getHoles: ->
    holes = []
    for edgeLoop in @edgeLoops
      holes.push edgeLoop if edgeLoop.hole is true
    return holes

  detectHoles: ->
    maximumIndex = null
    for edgeLoop, index in @edgeLoops
      if maximumIndex is null or
        @edgeLoops[ maximumIndex ]?.computeArea() < edgeLoop.computeArea()
          maximumIndex = index
      edgeLoop.hole = true
    @edgeLoops[ maximumIndex ]?.hole = false


module.exports = Shape
