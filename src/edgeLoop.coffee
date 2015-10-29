class EdgeLoop

  # input vertices is array of Meshlib vertices
  constructor: (vertices) ->
    @vertices = vertices
    @area = null
    @hole = null
    @xyPlaneVertices = null

  computeArea: ->
    if @area is null
      @area = 0
      for vertex, i in @vertices
        @area += vertex.x * @vertices[ ( i + 1 ) %% @vertices.length ].y -
          @vertices[ ( i + 1 ) %% @vertices.length ].x * vertex.y
      @area *= 0.5
    return @area


module.exports = EdgeLoop
