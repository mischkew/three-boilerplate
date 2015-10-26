THREE = require 'three'
meshlib = require 'meshlib'
stlParser = require 'stl-parser'


module.exports.loadModel = (parent, camera, scene) -> (event) ->
  return load event
    .then parse(parent, camera, scene)

# HELPERS

load = (event) ->
  file = event.dataTransfer.files[0]
  reader = new FileReader()
  return new Promise (resolve, reject) ->
    reader.onload = resolve
    reader.onerror = reject
    reader.onabort = reject
    reader.readAsArrayBuffer file


toStandardGeometry = (modelObject) ->

  {
    vertexCoordinates
    faceVertexIndices
    faceNormalCoordinates
  } = modelObject.mesh.faceVertex

  geometry = new THREE.Geometry()

  for vi in [0..vertexCoordinates.length - 1] by 3
    geometry.vertices.push new THREE.Vector3(
      vertexCoordinates[vi],
      vertexCoordinates[vi + 1],
      vertexCoordinates[vi + 2]
    )

  for fi in [0..faceVertexIndices.length - 1] by 3
    geometry.faces.push new THREE.Face3(
      faceVertexIndices[fi],
      faceVertexIndices[fi + 1],
      faceVertexIndices[fi + 2],
      new THREE.Vector3(
        faceNormalCoordinates[fi],
        faceNormalCoordinates[fi + 1],
        faceNormalCoordinates[fi + 2]
      )
    )

  return geometry


parse = (parent, camera, scene) -> (event) ->
  fileContent = event.target.result

  return new Promise (resolve, reject) ->
    parserInstance = stlParser(fileContent)

    parserInstance.on 'error', (error) ->
      reject error

    parserInstance.on 'data', (data) ->
      console.log('data', data)

      model = meshlib.Model.fromObject { mesh: data }
      model
        .setFileName 'model.stl'
        .setName 'model.stl'
        .calculateNormals()
        .buildFaceVertexMesh()
        .getObject()
        .then (modelObject) ->
          while (parent.children.length > 0)
            parent.remove parent.children[0]

          # geometry = new THREE.BoxGeometry(1, 1, 1)
          geometry = toStandardGeometry modelObject
          material =
            new THREE.MeshBasicMaterial({ color: 0x00ff00, wireframe: true })
          mesh = new THREE.Mesh(geometry, material)
          mesh.geometry.computeBoundingSphere()
          mesh.geometry.computeFaceNormals()
          mesh.geometry.computeVertexNormals()
          parent.add mesh

          resolve { geometry, model }

          # zoomTo geometry.boundingSphere, camera, scene


module.exports.zoomTo = (boundingSphere, camera, scene) ->
  radius = boundingSphere.radius
  center = boundingSphere.center

  alpha = camera.fov
  distanceToObject = radius / Math.sin(alpha)

  rv = camera.position.clone()
  rv = rv.normalize().multiplyScalar(distanceToObject)
  zoomAdjustmentFactor = 2.5
  rv = rv.multiplyScalar(zoomAdjustmentFactor)

  #apply scene transforms (e.g. rotation to make y the vector facing upwards)
  target = center.clone().applyMatrix4(scene.matrix)
  position = target.clone().add(rv)

  camera.position.set position.x, position.y, position.z
  camera.lookAt target
