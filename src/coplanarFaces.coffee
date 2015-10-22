THREE = require 'three'
require 'meshlib'

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
        if @edgeAdjacent face1, face2, index1, index2 or
        @edgeReverseAdjacent face1, face2, index1, index2
          return true
    return false

  test123: ->
    return true

  findCoplanarFaces: (model) ->
    models = []

    for newface in model.model.getFaces()
      foundCoplanarSubmodel = -1
      for submodel in [0...models.length]
        for face in models[submodel]
          if @isAdjacent newface, face
            if @isCoplanar newface, face, 0
              if foundCoplanarSubmodel < 0
                foundCoplanarSubmodel = submodel
                models[submodel] push newface
              else
                #TODO: merge current submodel to saved submodel
                1 + 1
      if foundCoplanarSubmodel < 0
        models.push [newface]

    console.log 'end'
    return models

module.exports = CoplanarFaces
