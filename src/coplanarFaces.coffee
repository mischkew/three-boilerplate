THREE = require 'three'
meshlib = require 'meshlib'

CoplanarFaces =

  isCoplanar: (face1, face2, threshold) ->
    plane1 = new THREE.Plane()
    .setFromNormalAndCoplanarPoint( face1.normal, face1.vertices[0] )
    plane2 = new THREE.Plane()
    .setFromNormalAndCoplanarPoint( face2.normal, face2.vertices[0] )
    return floatEqual( plane1.constant, plane2.constant, threshold ) and
    plane1.parallelTo( plane2, threshold )

  edgeAdjacent: (face1, face2, index1, index2) ->
    return face1.vertices[index1] is face2.vertices[index2] and
      face1.vertices[(index1 + 1) % 3] is face2.vertices[(index2 + 1) % 3]

  edgeReverseAdjacent: (face1, face2, index1, index2) ->
    return face1.vertices[index1] is face2.vertices[(index2 + 1) % 3] and
      face1.vertices[(index1 + 1) % 3] is face2.vertices[index2]

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

  test123: ->
    return true

  # calculateSurfaceArea: (vertices) ->
  #   Δ1X = vertices[1].x - vertices[0].x
  #   Δ1Y = vertices[1].y - vertices[0].y
  #   Δ1Z = vertices[1].z - vertices[0].z
  #   Δ2X = vertices[2].x - vertices[0].x
  #   Δ2Y = vertices[2].y - vertices[0].y
  #   Δ2Z = vertices[2].z - vertices[0].z
  #   x = (Δ1Y * Δ2Z) - (Δ1Z * Δ2Y)
  #   y = (Δ1Z * Δ2X) - (Δ1X * Δ2Z)
  #   z = (Δ1X * Δ2Y) - (Δ1Y * Δ2X)

    return 0.5 * Math.sqrt (x * x) + (y * y) + (z * z)

  findCoplanarFaces: (model) ->

    faces = model.model.getFaces()
    console.log 'faces.length ' + faces.length
    # console.log faces[0]
    planarModels = []

    #for face in faces
    #  console.log @calculateSurfaceArea face.vertices

    searchCoplanarFaces = (face1, planarModel) =>

      planarModel.push face1
      faces.splice(faces.indexOf(face1), 1)

      for face2 in faces when (not @isSameFace(face1, face2)) and
          @isAdjacent(face1, face2) and @isCoplanar(face1, face2, 5)
        planarModel.push face2
        faces.splice(faces.indexOf(face2), 1)
        searchCoplanarFaces face2 planarModel

    while faces.length > 0

      planarModels.push []
      searchCoplanarFaces(faces[0], planarModels[planarModels.length - 1])

    console.log 'planarModels.length ' + planarModels.length

    #for pm in planarModels
    #  console.log @calculateSurfaceArea pm[0].vertices

    # for planarModel, index in planarModels
    #   if index < 2
    #     console.log(planarModel[0])
    #   tempmodel = meshlib.Model.fromFaces planarModel
    #   tempmodel
    #     .getObject()
    #     .then (modelObject) ->
    #       planarModels[index] = modelObject

    return planarModels

  # findCoplanarFaces: (model) ->
  #   models = []
  #
  #   for newface in model.model.getFaces()
  #     foundCoplanarSubmodel = -1
  #     for submodel in [0...models.length]
  #       for face in models[submodel]
  #         if @isAdjacent newface, face
  #           if @isCoplanar newface, face, 0
  #             if foundCoplanarSubmodel < 0
  #               foundCoplanarSubmodel = submodel
  #               models[submodel] push newface
  #             else
  #               #TODO: merge current submodel to saved submodel
  #               1 + 1
  #     if foundCoplanarSubmodel < 0
  #       models.push [newface]
  #
  #   console.log 'end'
  #   return models

module.exports = CoplanarFaces
