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
    @printGraph(@plateGraph)
    return @newSceneElements

  createPlane: (vertex1, vertex2, vertex3) ->
    plane = new THREE.Plane()
    plane.setFromCoplanarPoints(vertex1, vertex2, vertex3)
    return plane

  signOf: (vector)  ->
    sign = 1
    if vector.x < 0 or vector.y < 0 or vector.z < 0
      sign = -1
    return sign

  findPointOnBothPlanes: (dir, node1, node2, isMain) ->
    # solve underdetermined linear system (therefore set one value to 0)
    if( isMain )
      plate1Constant = node1.plateConstant
      plate2Constant = node2.plateConstant
    else
      sign1 = @signOf(node1.shape.normal)
      sign2 = @signOf(node2.shape.normal)
      plate1Constant = node1.plateConstant + ( node1.thickness * sign1 )
      plate2Constant = node2.plateConstant + ( node2.thickness * sign2 )

    if dir.x isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.y, node1.shape.normal.z],
            [node2.shape.normal.y, node2.shape.normal.z]],
            [-plate1Constant, -plate2Constant]))
      return new THREE.Vector3( 0, solution[0], solution[1] )
    else if dir.y isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.x, node1.shape.normal.z],
            [node2.shape.normal.x, node2.shape.normal.z]],
            [-plate1Constant, -plate2Constant]))
      return new THREE.Vector3( solution[0], 0, solution[1] )
    else if dir.z isnt 0
      solution = numeric.round(numeric.solve(
            [[node1.shape.normal.x, node1.shape.normal.y],
            [node2.shape.normal.x, node2.shape.normal.y]],
            [-plate1Constant, -plate2Constant]))
      return new THREE.Vector3( solution[0], solution[1], 0 )
    else
      # console.log "can't solve the linear system.."
      return false

  isOnLine = (linePoint1, dir, pointToTest) ->
    linePoint2 = new THREE.Vector3() # 2 points needed to define line
    linePoint2.addVectors(linePoint1, dir)

    # distance calculation:
    #     |(p-p1) x (p-p2)|     | pp1 x pp2 |
    # d = ------------------ = --------------
    #       |(p2-p1)|               p2p1

    pp1 = new THREE.Vector3()
    pp2 = new THREE.Vector3()
    p2p1 = new THREE.Vector3()
    cross = new THREE.Vector3()

    pp1.subVectors(pointToTest, linePoint1)
    pp2.subVectors(pointToTest, linePoint2)
    cross.crossVectors(pp1, pp2)
    p2p1.subVectors(linePoint2, linePoint1)

    numerator = cross.length()
    denominator = p2p1.length()
    distance = numerator / denominator

    if distance is 0
      return true
    else
      return false

  addLine: (point1, point2) ->
    material = new THREE.LineBasicMaterial( color: 0x0000ff )
    geometry = new THREE.Geometry()
    geometry.vertices.push( point1, point2 )
    line = new THREE.Line( geometry, material )
    @newSceneElements.push( line )

  addConnection: (node1, node2) ->
    # angle calculation:
    #               n1 * n2
    # cos(alpha) = ---------
    #              |n1|*|n2| ( = 1 because normals are normalized )
    numerator = node1.shape.normal.dot(node2.shape.normal)
    angle = Math.acos( numerator ) / (Math.PI / 180)
    # console.log "Added connection with angle: #{angle}"
    @plateGraph.addConnection(node1, node2, angle, null)

  isPointOnPlane: (vertex, node) ->
    normal = node.shape.normal
    sign = @signOf(normal)
    # check both: original and parallel plane
    factor1 = new THREE.Vector3()
    factor2 = new THREE.Vector3()
    supportVector = new THREE.Vector3()
    supportVector.copy( node.shape.edgeLoops[0].vertices[0] )
    factor1.subVectors( vertex, supportVector )
    factor2.subVectors( vertex, supportVector.addScalar(sign * node.thickness))
    distance1 = factor1.dot(normal)
    distance2 = factor2.dot(normal)
    return ( distance1 is 0 or distance2 is 0)

  getAllVerticesFor: (node) ->
    vertices = []
    for edgeLoop in node.shape.edgeLoops
      for vertex in edgeLoop.vertices
        vertices.push( vertex )
        translatedVertex = new THREE.Vector3()
        translation = new THREE.Vector3()

        # original vertices
        translatedVertex.copy( vertex )
        translation.copy( node.shape.normal )

        # parallel vertices
        vertices.push( translatedVertex.add(
          translation.multiplyScalar( node.thickness )
          ))

    return vertices

  checkForBoundaryEdge: (dir, point, node1, node2) ->
    # check distance of vertices to line. if distances 0 -> shared edge!

    # add original shape points and parallel points
    verticesToTest1 = @getAllVerticesFor(node1)
    verticesToTest2 = @getAllVerticesFor(node2)

    pointsOnLine1 = []
    for vertex in verticesToTest1
      if isOnLine(point, dir, vertex)
        pointsOnLine1.push(vertex)

    pointsOnLine2 = []
    for vertex in verticesToTest2
      if isOnLine(point, dir, vertex)
        pointsOnLine2.push(vertex)

    # lines match
    if pointsOnLine1.length >= 2 and pointsOnLine2.length >= 2
      @addLine( pointsOnLine1[0], pointsOnLine1[1] )
      line = new THREE.Line3()
      line.set( pointsOnLine1[0], pointsOnLine1[1] )
      @addConnection(node1, node2, line)

    # line lies somewhere in other plane
    else if pointsOnLine1.length >= 2
      if (
            @isPointOnPlane(pointsOnLine1[0], node2) and
            @isPointOnPlane(pointsOnLine1[1], node2)
          )
        @addLine(pointsOnLine1[0], pointsOnLine1[1])
        line = new THREE.Line3()
        line.set( pointsOnLine1[0], pointsOnLine1[1] )
        @addConnection(node1, node2, line)

    else if pointsOnLine2.length >= 2
      if (
            @isPointOnPlane(pointsOnLine2[0], node1) and
            @isPointOnPlane(pointsOnLine2[1], node1)
          )
        @addLine(pointsOnLine2[0], pointsOnLine2[1])
        line = new THREE.Line3()
        line.set( pointsOnLine2[0], pointsOnLine2[1] )
        @addConnection(node1, node2, line)
    else
      # console.log 'not enough points on intersection'

  findIntersection: (plates) ->
    for plate, index in plates
      # edgeLoop = plate.shape.getContour() # this works when holify has run
      edgeLoop = plate.shape.edgeLoops[0]
      plane = @createPlane(
                          edgeLoop.vertices[0]
                          edgeLoop.vertices[1]
                          edgeLoop.vertices[2])
      plate.shape.normal = plane.normal # will be given by Lucas
      plate.plateConstant = plane.constant # will be given by Lucas
      plate.name = index # just for nice output
      @plateGraph.addNode(plate)
    # console.log 'finished creating nodes'

    nodeList = @plateGraph.nodes
    if nodeList? and (nodeList.length >= 2)
      # console.log 'intersections possible'
      for node1, index in nodeList
        if index + 1 < nodeList.length
          for node2 in nodeList[index + 1...nodeList.length]
            dir = new THREE.Vector3()
            dir.crossVectors(node1.shape.normal, node2.shape.normal)
            # handle original(0) and parallel(1) main side:
            # find point as support vector for defining intersection line
            point1 = @findPointOnBothPlanes(dir, node1, node2, 0)
            point2 = @findPointOnBothPlanes(dir, node1, node2, 1)
            if point1 isnt false
              @checkForBoundaryEdge(dir, point1, node1, node2)
            else if point2 isnt false
              @checkForBoundaryEdge(dir, point2, node1, node2)
            else
              # console.log 'There is no intersection'
    else
      # console.log 'not enough plates for intersections'

  printGraph: (graph) ->
    nodeList = graph.nodes
    console.log "There are #{nodeList.length} nodes (i.e. plates)"
    for node, index in nodeList
      connections = node.connectionList
      console.log "Node #{index} has #{connections.length} connections"
      for connection in connections
        console.log "--- Node #{connection.node.name},
        angle: #{connection.parameters.angle}"


module.exports = CreateGraph
