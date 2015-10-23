THREE = require 'three'
meshlib = require 'meshlib'

CoplanarFaces =

  isCoplanar: (face1, face2, threshold) ->
    normal1 = new THREE.Vector3(face1.normal.x, face1.normal.y, face1.normal.z)
    normal2 = new THREE.Vector3(face2.normal.x, face2.normal.y, face2.normal.z)
    return normal1.angleTo(normal2) <= threshold

  edgeAdjacent: (face1, face2, index1, index2) ->
    return (@isSameVec face1.vertices[index1], face2.vertices[index2]) and
      (@isSameVec face1.vertices[(index1 + 1) % 3],
      face2.vertices[(index2 + 1) % 3])

  edgeReverseAdjacent: (face1, face2, index1, index2) ->
    return (@isSameVec face1.vertices[index1],
      face2.vertices[(index2 + 1) % 3]) and
      (@isSameVec face1.vertices[(index1 + 1) % 3], face2.vertices[index2])

  isAdjacent: (face1, face2) ->
    for index1 in [0..2]
      for index2 in [0..2]
        if @edgeAdjacent(face1, face2, index1, index2) or
        @edgeReverseAdjacent(face1, face2, index1, index2)
          return true
    return false

  isSameVec: (vector1, vector2) ->
    if vector1.x is vector2.x and
        vector1.y is vector2.y and
        vector1.z is vector2.z
      return true
    else
      return false

  isSameFace: (face1, face2) ->
    for i in [0..2]
      if not @isSameVec(face1.vertices[i], face2.vertices[i])
        return false
    if not @isSameVec(face1.normal, face2.normal)
      return false
    return true

  isAdjacentAndCoplanar: (face1, face2, threshold) ->
    return @isAdjacent(face1, face2) and @isCoplanar(face1, face2, threshold)

  findCoplanarFaces: (model) ->

    faces = model.model.getFaces()
    #console.log 'faces.length ' + faces.length
    planarModels = []

    faceUsed = []
    for i in [0...faces.length]
      faceUsed.push[false]

    searchCoplanarFaces = (face1, index1, planarModel) =>

      planarModel.push face1
      faceUsed[index1] = true

      for face2, index2 in faces when index1 isnt index2 and
          not faceUsed[index2] and
          @isAdjacentAndCoplanar(face1, face2, 0.00001)
        searchCoplanarFaces face2, index2, planarModel

    for face1, index1 in faces when not faceUsed[index1]
      planarModels.push []
      searchCoplanarFaces face1, index1, planarModels[planarModels.length - 1]

    #console.log 'planarModels.length ' + planarModels.length
    return planarModels

module.exports = CoplanarFaces
