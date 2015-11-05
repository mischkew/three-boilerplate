

class ShapeLayouter

  constructor: (maxWidth) ->
    @shapesWithOffset = []
    @maxWidth = maxWidth
    @height = 0
    @scale = 1.0

  addShapes: ( shapes ) ->
    for shape in shapes
      shapesWithOffset = {
        shape: shape, offsetX: 0.0, offsetY: 0.0, width: 0.0, height: 0.0 }
      @findBoundsAndSetToOrigin shapesWithOffset
      @shapesWithOffset.push shapesWithOffset
    @sortShapesByHeight()
    console.log @shapesWithOffset

  findBoundsAndSetToOrigin: (shapesWithOffset) ->
    shape = shapesWithOffset.shape
    edgeLoop = shape.edgeLoops[0].xyPlaneVertices
    leftmostVertexX = edgeLoop[0].x
    rightmostVertexX = edgeLoop[0].x
    bottommostVtertexY = edgeLoop[0].y
    topmostVtertexY = edgeLoop[0].y

    for vertex in edgeLoop
      if vertex.x < leftmostVertexX then leftmostVertexX = vertex.x
      if vertex.x > rightmostVertexX then rightmostVertexX = vertex.x
      if vertex.y < bottommostVtertexY then bottommostVtertexY = vertex.y
      if vertex.y > topmostVtertexY then topmostVtertexY = vertex.y
    shapesWithOffset.offsetX = -leftmostVertexX
    shapesWithOffset.offsetY = -bottommostVtertexY
    shapesWithOffset.width = topmostVtertexY - bottommostVtertexY
    shapesWithOffset.height = rightmostVertexX - leftmostVertexX

  sortShapesByHeight: ->
    @shapesWithOffset.sort (a, b) ->
      return if a.height >= b.height then 1 else -1

  layout: ->
    console.log ''

  getObjectURL: ->
    console.log ''


module.exports = ShapeLayouter
