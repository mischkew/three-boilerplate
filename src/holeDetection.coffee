THREE = require 'three'

class HoleDetector

  detectHoles: ( shapes ) ->
    @myShapes = shapes
    for shape in shapes
      maximumIndex = null

      computationalGeom = new THREE.Geometry()
      computationalGeom.vertices.push( shape[0].vertices[ 0 ].clone() )
      computationalGeom.vertices.push( shape[0].vertices[ 1 ].clone() )
      computationalGeom.vertices.push( shape[0].vertices[ 2 ].clone() )
      face = new THREE.Face3( 0, 1, 2 )
      computationalGeom.faces.push( face )
      computationalGeom.computeFaceNormals()
      normal = face.normal
      console.log "normal #{normal.x} #{normal.y} #{normal.z}"

      zAxis = new THREE.Vector3( 0, 0, 1 )
      rotationAxis = new THREE.Vector3( 0, 0, 1 )
      rotationAxis.cross( normal )
      console.log "rotAx #{rotationAxis.x}  #{rotationAxis.y}  #{rotationAxis.z}"

      dot = zAxis.dot( normal )
      console.log "dot #{dot}"
      angle = -Math.acos( dot )
      console.log "angle #{angle}"

      for vertex in computationalGeom.vertices
        console.log "V #{vertex.x}  #{vertex.y}  #{vertex.z}"

      rotationMatrix = new THREE.Matrix4()
      rotationMatrix.set(
        ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.x + Math.cos(angle),
        ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y - Math.sin(angle) * rotationAxis.z,
        ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.z + Math.sin(angle) * rotationAxis.y,
        0,
        ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y + Math.sin(angle) * rotationAxis.z,
        ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.y + Math.cos(angle),
        ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.z - Math.sin(angle) * rotationAxis.x,
        0,
        ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y + Math.sin(angle) * rotationAxis.z,
        ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.z + Math.sin(angle) * rotationAxis.x,
        ( 1 - Math.cos(angle) ) * rotationAxis.z * rotationAxis.z + Math.cos(angle),
        0,
        0, 0, 0, 1)


      computationalGeom.applyMatrix( rotationMatrix )

      for vertex in computationalGeom.vertices
        console.log "V #{vertex.x}  #{vertex.y}  #{vertex.z}"

      computationalGeom.dispose()

      for sequence, sequenceIndex in shape
        sequence.area += vertex.x *
          sequence.vertices[ ( i + 1 ) %% sequence.vertices.length ].y -
          sequence.vertices[ ( i + 1 ) %% sequence.vertices.length ].x *
          vertex.y for vertex, i in sequence.vertices
        sequence.area *= 0.5
        maximumIndex = sequenceIndex if not shape[maximumIndex]? or
          shape[maximumIndex]?.area < sequence.area
        sequence.hole = true

      shape[ maximumIndex ]?.hole = false


    for shape, shapeInd in shapes
      console.log "shape #{shapeInd}"
      for sequence, sequenceInd in shape
        console.log "sequence #{sequenceInd}"
        console.log "area = #{sequence.area}"
        console.log "hole = #{sequence.hole}"


  getDrawable: () ->
    node3D = new THREE.Object3D()
    for shape in @myShapes
      for sequence in shape
        geomToDraw = new THREE.Geometry()

        for vertex, vertexInd in sequence.vertices
          geomToDraw.vertices.push( vertex )

          if vertexInd >= 2
            face = new THREE.Face3( 0, vertexInd - 1, vertexInd )
            geomToDraw.faces.push( face )

        material = new THREE.MeshBasicMaterial(
          color: if sequence.hole then 0xff0000 else 0x00ff00 )
        mesh = new THREE.Mesh( geomToDraw, material )
        node3D.add(mesh)

    return node3D



module.exports = HoleDetector
