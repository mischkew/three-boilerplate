THREE = require 'three'

class HoleDetector

  detectHoles: ( shapes ) ->
    @myShapes = shapes
    for shape in shapes
      shape.detectHoles()

  getDrawable: () ->
    node3D = new THREE.Object3D()
    for shape in @myShapes
      for edgeLoop in shape.getEdgeLoops()
        geomToDraw = new THREE.Geometry()

        for vertex, vertexInd in edgeLoop.vertices
          geomToDraw.vertices.push( vertex )

          if vertexInd >= 2
            face = new THREE.Face3( 0, vertexInd - 1, vertexInd )
            geomToDraw.faces.push( face )

        material = new THREE.MeshBasicMaterial(
          color: if edgeLoop.hole then 0xff0000 else 0x00ff00 )
        mesh = new THREE.Mesh( geomToDraw, material )
        node3D.add(mesh)

    return node3D



module.exports = HoleDetector
