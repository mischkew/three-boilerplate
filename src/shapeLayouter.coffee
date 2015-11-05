SVG = require './svg'

class ShapeLayouter

  constructor: (maxWidth) ->
    @shapesWithOffset = []
    @maxWidth = maxWidth
    @width = 0
    @height = 0
    @scale = 1.0
    @margin = 2

  addShapes: ( shapes ) ->
    for shape in shapes
      shapesWithOffset = {
        shape: shape, offsetX: 0.0, offsetY: 0.0, width: 0.0, height: 0.0 }
      @findBoundsAndSetToOrigin shapesWithOffset
      @shapesWithOffset.push shapesWithOffset

  findBoundsAndSetToOrigin: (shapesWithOffset) ->
    shape = shapesWithOffset.shape
    edgeLoop = shape.getContour().xyPlaneVertices
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
    shapesWithOffset.width = rightmostVertexX - leftmostVertexX
    shapesWithOffset.height = topmostVtertexY - bottommostVtertexY

  sortShapesByHeight: ->
    @shapesWithOffset.sort (a, b) ->
      return if a.height <= b.height then 1 else -1

  layout: ->
    @sortShapesByHeight()
    cursor = { x: 0.0, y: 0.0 }
    heightOfRow = 0.0
    @width = 0
    for shape in @shapesWithOffset
      if cursor.x + shape.width <= @maxWidth
        shape.offsetX += cursor.x
        shape.offsetY += cursor.y
        if heightOfRow < shape.height then heightOfRow = shape.height
        cursor.x += shape.width + @margin
      else
        cursor.x = 0.0
        cursor.y += heightOfRow + @margin
        shape.offsetX += cursor.x
        shape.offsetY += cursor.y
        cursor.x = shape.width + @margin
        heightOfRow = shape.height
      if cursor.x - @margin > @width then @width = cursor.x - @margin
      @height = cursor.y + heightOfRow

  getObjectURL: ->
    @layout()
    svg = new SVG @width, @height
    svg.addShapesWithOffset @shapesWithOffset
    url = svg.getObjectURL()
    return url


module.exports = ShapeLayouter
