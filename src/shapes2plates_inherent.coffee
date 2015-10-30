require './shape'
Plate = require './plate'
THREE = require 'three'

class InherentPlates

  constructor: ->
    @drawable = new THREE.Object3D()
    @debug = false
    @angleThreshold = 0.001
    @thicknessThreshold = 0.001
    @plateThicknesses = []

  addPlateThickness: (plateThickness) ->
    @plateThicknesses.push plateThickness

  addPlateThicknesses: (plateThicknesses) ->
    @plateThicknesses.concat plateThicknesses

  checkPlateThickness: (plane, shape) ->
    for plateThickness in @plateThicknesses
      if @thicknessThreshold > Math.abs(plateThickness -
          plane1.distanceToPoint(shape2.edgeLoops[0].vertices[0]))
        return true
    return false

  findPlateCandidates: (shapes) ->
    candidates = []
    for shape1, index1 in shapes
      plane1 = new THREE.Plane().setFromNormalAndCoplanarPoint(
        shape1.normal, shape1.edgeLoops[0].vertices[0])
      for shape2, index2 in shapes when index1 < index2 and
          shape1.normal.angleTo(-shape2.normal) < @threshold and
          @checkPlateThickness(plane1, shape2) # TODO: facing together?
        candidates.push { shape1, shape2 }
    return candidates

  findInherentPlates: (shapes) ->
    candidates = @findPlateCandidates(shapes)
    # TODO: What now?
    # intersections = @getIntersection(shape1, shape2)


module.exports = InherentPlates
