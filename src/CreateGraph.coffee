Node = require './node'
Plate = require './plate'
Shape = require './shape'
require './connectionParameters'
Connection = require './connection'
PlateGraph = require './plateGraph'
THREE = require 'three'
numeric = require './numeric-1.2.6.js'

class CreateGraph
  constructor: ->
    @plateGraph = new PlateGraph()
    @newSceneElements = []

  createGraph: (plates, model) ->
    @findIntersection(plates)
    return @newSceneElements

  createPlane: (vertex1, vertex2, vertex3) ->
    plane = new THREE.Plane()
    plane.setFromCoplanarPoints(vertex1, vertex2, vertex3)
    return plane

  findPointOnBothPlanes: (dir, plate1, plate2) ->
    # solve underdetermined linear system (therefore set one value to 0)
    if dir.x isnt 0
      solution = numeric.round(numeric.solve(
            [[plate1[0].normal.y, plate1[0].normal.z],
            [plate2[0].normal.y, plate2[0].normal.z]],
            [-plate1[0].constant, -plate2[0].constant]))
      return new THREE.Vector3( 0, solution[0], solution[1] )
    else if dir.y isnt 0
      solution = numeric.round(numeric.solve(
            [[plate1[0].normal.x, plate1[0].normal.z],
            [plate2[0].normal.x, plate2[0].normal.z]],
            [-plate1[0].constant, -plate2[0].constant]))
      return new THREE.Vector3( solution[0], 0, solution[1] )
    else if dir.z isnt 0
      solution = numeric.round(numeric.solve(
            [[plate1[0].normal.x, plate1[0].normal.y],
            [plate2[0].normal.x, plate2[0].normal.y]],
            [-plate1[0].constant, -plate2[0].constant]))
      return new THREE.Vector3( solution[0], solution[1], 0 )
    else
      console.log "can't solve the linear system.."
      return false

  isOnLine = (linePoint1, dir, pointToTest) ->
    linePoint2 = new THREE.Vector3()
    linePoint2.addVectors(linePoint1, dir)

    #     |(p-p1) x (p-p2)|
    # d = ------------------
    #       |(p2-p1)|

    pp1 = new THREE.Vector3()
    pp1.subVectors(pointToTest, linePoint1)
    pp2 = new THREE.Vector3()
    pp2.subVectors(pointToTest, linePoint2)
    cross = new THREE.Vector3()
    cross.crossVectors(pp1, pp2)
    numerator = cross.length()

    p2p1 = new THREE.Vector3()
    p2p1.subVectors(linePoint2, linePoint1)
    denominator = p2p1.length()

    distance = numerator / denominator
    if distance is 0
      return true
    else
      return false

  checkForBoundaryEdge: (dir, point, plate1, plate2) ->
    # check distance of vertices to line. if distances 0 -> shared edge!
    pointsOnLine1 = []
    pointsOnLine2 = []

    p1 = new Plate( new Shape( plate1, plate1[0].normal ), plate1[0].thickness )
    p2 = new Plate( new Shape( plate2, plate2[0].normal ), plate2[0].thickness )
    onLineCounter1 = 0
    for edgeLoop in plate1
      for vertex in edgeLoop.vertices
        if isOnLine(vertex, dir, point)
          pointsOnLine1.push(vertex)
          onLineCounter1 = onLineCounter1 + 1

    onLineCounter2 = 0
    for edgeLoop in plate2
      for vertex in edgeLoop.vertices
        if isOnLine(vertex, dir, point)
          onLineCounter2 = onLineCounter2 + 1

    if onLineCounter1 >= 2 and onLineCounter2 >= 2
      console.log 'there is an intersection'
      material = new THREE.LineBasicMaterial( color: 0x0000ff )

      geometry = new THREE.Geometry()
      geometry.vertices.push( pointsOnLine1[0], pointsOnLine1[1] )

      line = new THREE.Line( geometry, material )
      @newSceneElements.push( line )
      console.log 'added line'
      @plateGraph.addNode(p1)
      @plateGraph.addNode(p2)
      connection = new Connection()
      #               n1 * n2
      # cos(alpha) = ---------
      #              |n1|*|n2| ( = 1 because normals are normalized )
      numerator = plate1[0].normal.dot(plate2[0].normal)
      angle = Math.acos( numerator ) / (Math.PI / 180)
      console.log "Added connection with angle: #{angle}"
      @plateGraph.addConnection(p1, p2, angle, null)
    else
      console.log 'not enough points on intersection'

  findIntersection: (plates) ->
    console.log 'calculations started'

    for plate in plates
      for edgeLoop in plate
        plane = @createPlane(
                            edgeLoop.vertices[0]
                            edgeLoop.vertices[1]
                            edgeLoop.vertices[2])
        edgeLoop.normal = plane.normal
        edgeLoop.constant = plane.constant

    if plates? and (plates.length >= 2)
      console.log 'intersections possible'
      for plate1, index in plates
        if index + 1 < plates.length
          for plate2 in plates[index + 1...plates.length]
            console.log "testing #{plate1[0].name} with #{plate2[0].name}"
            dir = new THREE.Vector3()
            # only care about main sides:
            dir.crossVectors(plate1[0].normal, plate2[0].normal)
            console.log "direction of possible intersection vector:
                   (#{dir.x}, #{dir.y}, #{dir.z})"
            point = @findPointOnBothPlanes(dir, plate1, plate2)
            if point isnt false
              console.log "point on plane: #{point}"
              @checkForBoundaryEdge(dir, point, plate1, plate2)
            else
              console.log 'There is no intersection'
    else
      console.log 'not enough plates for intersections'


module.exports = CreateGraph
