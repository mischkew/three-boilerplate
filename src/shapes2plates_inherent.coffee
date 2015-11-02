require './shape'
Plate = require './plate'
Shape = require './shape'
THREE = require 'three'
greinerHormann = require 'greiner-hormann'

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
          # normals parallel?
          shape1.normal.angleTo(-shape2.normal) < @threshold and
          # facing together?
          (shape2.edgeLoops[0].vertices[0] - shape1.edgeLoops[0].vertices[0])
          .angleTo(shape1.normal) <= Math.PI / 2 and
          # plate thickness ok?
          @checkPlateThickness(plane1, shape2)
        candidates.push { shape1, shape2 }
    return candidates

  parseToPolygon: (shape) ->
    polygon = []
    for edgeLoop in shape.edgeLoops
      polyPart = []
      for vertex in edgeLoop.vertices
        polyPart.push [vertex.x, vertex.y]
      polygon.push polyPart
    return polygon

  parseToShape: (polygon)

  getPlate: (shape1, shape2) ->
    shape1.layIntoXYPlane()
    shape2.layIntoXYPlane()
    # shape2 closer to origin? if yes, swap them for the algorithm
    swap = shape2.edgeLoops[0].vertices[0].z < shape1.edgeLoops[0].vertices[0].z
    polygon1 = if swap then @parseToPolygon shape2 else @parseToPolygon shape1
    polygon2 = if swap then @parseToPolygon shape1 else @parseToPolygon shape2
    intersection = greinerHormann.intersection(polygon1, polygon2)
    intersectionShape = new Shape

  findInherentPlates: (shapes) ->
    candidates = @findPlateCandidates(shapes)
    plates = []
    for cadidate in candidates
      plates.push @getPlate(shape1, shape2)

module.exports = InherentPlates
