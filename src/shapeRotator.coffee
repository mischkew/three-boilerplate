THREE = require 'three'

class ShapeRotator

  constructor: ->
    @drawable = new THREE.Object3D()

  layIntoXYPlane: ( shapes ) ->
    @myShapes = shapes
    for shape in shapes
      shape.layIntoXYPlane()
    @setupDrawable()

  setupDrawable: ->
    while (@drawable.children.length > 0)
      @drawable.remove @drawable.childen[0]
    material = new THREE.LineBasicMaterial( color: 0xAAAAFF )
    for shape in @myShapes
      for edgeLoop in shape.getEdgeLoops()
        geomToDraw = new THREE.Geometry()

        for vertex, vertexInd in edgeLoop.xyPlaneVertices
          geomToDraw.vertices.push( vertex )

        geomToDraw.vertices.push( edgeLoop.xyPlaneVertices[0] )

        line = new THREE.Line( geomToDraw, material )
        @drawable.add( line )

  getDrawable: ->
    return @drawable

module.exports = ShapeRotator
