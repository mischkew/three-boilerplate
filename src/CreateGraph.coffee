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

  findPointOnBothPlanes: (dir, node1, node2) ->
    # solve underdetermined linear system (therefore set one value to 0)
    if dir.x isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.y, node1.shape.normal.z],
            [node2.shape.normal.y, node2.shape.normal.z]],
            [-node1.plateConstant, -node2.plateConstant]))
      return new THREE.Vector3( 0, solution[0], solution[1] )
    else if dir.y isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.x, node1.shape.normal.z],
            [node2.shape.normal.x, node2.shape.normal.z]],
            [-node1.plateConstant, -node2.plateConstant]))
      return new THREE.Vector3( solution[0], 0, solution[1] )
    else if dir.z isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.x, node1.shape.normal.y],
            [node2.shape.normal.x, node2.shape.normal.y]],
            [-node1.plateConstant, -node2.plateConstant]))
      return new THREE.Vector3( solution[0], solution[1], 0 )
    else
      console.log "can't solve the linear system.."
      return false

  isOnLine = (linePoint1, dir, pointToTest) ->
    linePoint2 = new THREE.Vector3() # 2 points needed to define line
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

  checkForBoundaryEdge: (dir, point, node1, node2) ->
    # check distance of vertices to line. if distances 0 -> shared edge!
    pointsOnLine1 = []
    pointsOnLine2 = []

    onLineCounter1 = 0
    for edgeLoop in node1.shape.edgeLoops
      for vertex in edgeLoop.vertices
        if isOnLine(vertex, dir, point)
          pointsOnLine1.push(vertex)
          onLineCounter1 = onLineCounter1 + 1

    onLineCounter2 = 0
    for edgeLoop in node2.shape.edgeLoops
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
      #               n1 * n2
      # cos(alpha) = ---------
      #              |n1|*|n2| ( = 1 because normals are normalized )
      numerator = node1.shape.normal.dot(node2.shape.normal)
      angle = Math.acos( numerator ) / (Math.PI / 180)
      console.log "Added connection with angle: #{angle}"
      @plateGraph.addConnection(node1, node2, angle, null)
    else
      console.log 'not enough points on intersection'

  findIntersection: (plates) ->
    console.log 'calculations started'

    for plate in plates
      # edgeLoop = plate.shape.getContour() # this works when holify has run #
      edgeLoop = plate.shape.edgeLoops[0]
      plane = @createPlane(
                          edgeLoop.vertices[0]
                          edgeLoop.vertices[1]
                          edgeLoop.vertices[2])
      plate.shape.normal = plane.normal
      plate.plateConstant = plane.constant
      @plateGraph.addNode(plate)
    console.log 'finished creating nodes'

    nodeList = @plateGraph.nodes
    if nodeList? and (nodeList.length >= 2)
      console.log 'intersections possible'
      for node1, index in nodeList
        if index + 1 < nodeList.length
          for node2 in nodeList[index + 1...nodeList.length]
            # console.log "testing #{plate1[0].name} with #{plate2[0].name}"
            dir = new THREE.Vector3()
            # only care about main sides:
            dir.crossVectors(node1.shape.normal, node2.shape.normal)
            console.log "direction of possible intersection vector:
                   (#{dir.x}, #{dir.y}, #{dir.z})"
            point = @findPointOnBothPlanes(dir, node1, node2)
            if point isnt false
              console.log "point on plane: #{point}"
              @checkForBoundaryEdge(dir, point, node1, node2)
            else
              console.log 'There is no intersection'
    else
      console.log 'not enough plates for intersections'


module.exports = CreateGraph
