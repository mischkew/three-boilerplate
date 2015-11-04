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

  findPointOnBothPlanes: (dir, node1, node2, isMain) ->
    # solve underdetermined linear system (therefore set one value to 0)

    if( isMain )
      plate1Constant = node1.plateConstant
      plate2Constant = node2.plateConstant
    else
      normal1 = node1.shape.normal
      factor1 = 1
      factor2 = 1
      normal2 = node2.shape.normal
      if normal1.x < 0 or normal1.y < 0 or normal1.z < 0
        factor1 = -1
      if normal2.x < 0 or normal2.y < 0 or normal2.z < 0
        factor2 = -1
      plate1Constant = node1.plateConstant + ( node1.thickness * factor1 )
      plate2Constant = node2.plateConstant + ( node2.thickness * factor2 )

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

    verticesToTest1 = []
    for edgeLoop in node1.shape.edgeLoops
      for vertex in edgeLoop.vertices
        verticesToTest1.push( vertex )
        translatedVertex = new THREE.Vector3()
        translatedVertex.copy( vertex )
        translation = new THREE.Vector3()
        translation.copy( node1.shape.normal )
        verticesToTest1.push( translatedVertex.add(
          translation.multiplyScalar( node1.thickness )
          ) )

    verticesToTest2 = []
    for edgeLoop in node2.shape.edgeLoops
      for vertex in edgeLoop.vertices
        verticesToTest2.push( vertex )
        translatedVertex = new THREE.Vector3()
        translatedVertex.copy( vertex )
        translation = new THREE.Vector3()
        translation.copy( node2.shape.normal )
        verticesToTest2.push( translatedVertex.add(
          translation.multiplyScalar( node2.thickness )
          ) )

    onLineCounter1 = 0
    for vertex in verticesToTest1
      if isOnLine(point, dir, vertex)
        # console.log "#{vertex.x}, #{vertex.y}, #{vertex.z} is onLine"
        pointsOnLine1.push(vertex)
        onLineCounter1 = onLineCounter1 + 1

    # console.log '_______________________________'

    onLineCounter2 = 0
    for vertex in verticesToTest2
      if isOnLine(point, dir, vertex)
        # console.log "#{vertex.x}, #{vertex.y}, #{vertex.z} is onLine"
        onLineCounter2 = onLineCounter2 + 1
    #
    # console.log "counter1: #{onLineCounter1}, counter2: #{onLineCounter2}"

    if onLineCounter1 >= 2 and onLineCounter2 >= 2
      # console.log 'found an intersection'
      material = new THREE.LineBasicMaterial( color: 0x0000ff )

      geometry = new THREE.Geometry()
      geometry.vertices.push( pointsOnLine1[0], pointsOnLine1[1] )

      line = new THREE.Line( geometry, material )
      @newSceneElements.push( line )
      # console.log 'added line'
      #               n1 * n2
      # cos(alpha) = ---------
      #              |n1|*|n2| ( = 1 because normals are normalized )
      numerator = node1.shape.normal.dot(node2.shape.normal)
      angle = Math.acos( numerator ) / (Math.PI / 180)
      # console.log "Added connection with angle: #{angle}"
      @plateGraph.addConnection(node1, node2, angle, null)
    else
      # console.log 'not enough points on intersection'

  findIntersection: (plates) ->
    # console.log 'calculations started'

    for plate, index in plates
      # edgeLoop = plate.shape.getContour() # this works when holify has run
      edgeLoop = plate.shape.edgeLoops[0]
      plane = @createPlane(
                          edgeLoop.vertices[0]
                          edgeLoop.vertices[1]
                          edgeLoop.vertices[2])
      plate.shape.normal = plane.normal # will be given by Lucas
      plate.plateConstant = plane.constant # will be given by Lucas
      plate.name = index
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
            # handle original main side:
            # find point as support vector for defining intersection line
            point1 = @findPointOnBothPlanes(dir, node1, node2, true)
            point2 = @findPointOnBothPlanes(dir, node1, node2, false)
            if point1 isnt false
              @checkForBoundaryEdge(dir, point1, node1, node2)
            # handle intersections with parallel main side:
            # find point as support vector for defining intersection line
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
