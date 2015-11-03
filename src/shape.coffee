THREE = require 'three'
EdgeLoop = require './edgeLoop'

class Shape
  constructor: ( edgeLoops, normal ) ->
    @edgeLoops = edgeLoops
    @normal = normal
    @rotationMatrix = null

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
    rotation = new THREE.Vector3( 0, 0, 1 )
    rotation.cross( @normal )
    dot = zAxis.dot( @normal )
    angle = -Math.acos( dot )

    cosOfAngle = Math.cos(angle)
    sinOfAngle = Math.sin(angle)
    oneMinusCos = 1 - cosOfAngle

    oneMinusCosTimesX = oneMinusCos * rotation.x
    oneMinusCosTimesY = oneMinusCos * rotation.y

    @rotationMatrix = new THREE.Matrix3()
    @rotationMatrix.set(
      oneMinusCosTimesX * rotation.x + cosOfAngle,
      oneMinusCosTimesX * rotation.y - sinOfAngle * rotation.z,
      oneMinusCosTimesX * rotation.z + sinOfAngle * rotation.y,
      oneMinusCosTimesX * rotation.y + sinOfAngle * rotation.z,
      oneMinusCosTimesY * rotation.y + cosOfAngle,
      oneMinusCosTimesY * rotation.z - sinOfAngle * rotation.x,
      oneMinusCosTimesX * rotation.y + sinOfAngle * rotation.z,
      oneMinusCosTimesY * rotation.z + sinOfAngle * rotation.x,
      oneMinusCos * rotation.z * rotation.z + cosOfAngle)

    for edgeLoop in @edgeLoops
      edgeLoop.layIntoXYPlane @rotationMatrix


module.exports = Shape
