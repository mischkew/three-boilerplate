THREE = require 'three'

class EdgeLoop
  # input vertices is array of Meshlib vertices
  constructor: ( vertices ) ->
    @vertices = vertices
    @area = null
    @hole = null
    @xyPlaneVertices = null

  computeArea: ->
    if @area is null
      @area = 0
      for vertex, i in @xyPlaneVertices
        nextI = ( i + 1 ) %% @xyPlaneVertices.length
        @area += vertex.x * @xyPlaneVertices[ nextI ].y -
          vertex.y * @xyPlaneVertices[ nextI ].x
      @area = 0.5 * Math.abs( @area )
    return @area

  layIntoXYPlane: ( rotationMatrix ) ->
    @xyPlaneVertices = []
    for vertex in @vertices
      planeVertex = new THREE.Vector3( vertex.x, vertex.y, vertex.z )
      planeVertex.applyMatrix3 rotationMatrix
      @xyPlaneVertices.push planeVertex


module.exports = EdgeLoop
