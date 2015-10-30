THREE = require 'three'
EdgeLoop = require './edgeLoop'

class Shape
  constructor: ( edgeLoops, normal ) ->
    @edgeLoops = edgeLoops
    @normal = normal

  getEdgeLoops: ->
    return @edgeLoops

  getContour: ->
    for edgeLoop in @edgeLoops
      if edgeLoop.hole is false
        return edgeLoop

  getHoles: ->
    holes = []
    for edgeLoop in @edgeLoops
      holes.push edgeLoop if edgeLoop.hole is true
    return holes

  detectHoles: ->
    maximumIndex = null
    for edgeLoop, index in @edgeLoops
      if maximumIndex is null or
        @edgeLoops[ maximumIndex ]?.computeArea() < edgeLoop.computeArea()
          maximumIndex = index
      edgeLoop.hole = true
    @edgeLoops[ maximumIndex ]?.hole = false

  layIntoXYPlane: ->
    zAxis = new THREE.Vector3( 0, 0, 1 )
    rotationAxis = new THREE.Vector3( 0, 0, 1 )
    rotationAxis.cross( @normal )
    dot = zAxis.dot( @normal )
    angle = -Math.acos( dot )

    rotationMatrix = new THREE.Matrix3()
    rotationMatrix.set(
      ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.x + Math.cos(angle),
      ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y - Math.sin(angle) * rotationAxis.z,
      ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.z + Math.sin(angle) * rotationAxis.y,
      ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y + Math.sin(angle) * rotationAxis.z,
      ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.y + Math.cos(angle),
      ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.z - Math.sin(angle) * rotationAxis.x,
      ( 1 - Math.cos(angle) ) * rotationAxis.x * rotationAxis.y + Math.sin(angle) * rotationAxis.z,
      ( 1 - Math.cos(angle) ) * rotationAxis.y * rotationAxis.z + Math.sin(angle) * rotationAxis.x,
      ( 1 - Math.cos(angle) ) * rotationAxis.z * rotationAxis.z + Math.cos(angle))

    for edgeLoop in @edgeLoops
      edgeLoop.layIntoXYPlane rotationMatrix


module.exports = Shape
