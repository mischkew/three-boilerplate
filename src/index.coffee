THREE = require 'three'
$ = require 'jquery'
#OrbitControls = require('three-orbit-controls')(THREE)
require('jquery-ui')
numeric = require './numeric-1.2.6.js'
# see mdn Math for math functions

view3d = $( '#3d-view' )
view3d.height '100%'

console.log 'setup'

scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera(
  75
  window.innerWidth / window.innerHeight
  0.1
  1000
)

camera.position.z = 5

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )

sceneGraph = new THREE.Object3D()
scene.add( sceneGraph )

myObject = null

clearScene = ->
  sceneGraph.children = []


createPlane = (vertex1, vertex2, vertex3) ->
  plane = new THREE.Plane()
  plane.setFromCoplanarPoints(vertex1, vertex2, vertex3)
  return plane

findPointOnBothPlanes = (dir, plate1, plate2) ->
  # solve underdetermined (therefore set one value to 0) linear system
  if dir.x isnt 0
    solution = numeric.round(numeric.solve([[plate1[0].normal.y, plate1[0].normal.z],
           [plate2[0].normal.y, plate2[0].normal.z]],
           [-plate1[0].constant, -plate2[0].constant]))
    return new THREE.Vector3( 0, solution[0], solution[1] )
    # return [0, solution[0], solution[1]]
  else if dir.y isnt 0
    solution = numeric.round(numeric.solve([[plate1[0].normal.x, plate1[0].normal.z],
           [plate2[0].normal.x, plate2[0].normal.z]],
           [-plate1[0].constant, -plate2[0].constant]))
    # return [solution[0] , 0, solution[1]]
    return new THREE.Vector3( solution[0], 0, solution[1] )
  else if dir.z isnt 0
    solution = numeric.round(numeric.solve([[plate1[0].normal.x, plate1[0].normal.y],
           [plate2[0].normal.x, plate2[0].normal.y]],
           [-plate1[0].constant, -plate2[0].constant]))
    # return [solution[0], solution[1], 0]
    return new THREE.Vector3( solution[0], solution[1], 0 )
  else
    console.log "can't solve the linear system.."

isOnLine = (linePoint1, dir, pointToTest) ->
  console.log "dir: #{dir.x}, #{dir.y}, #{dir.z}
    x: #{pointToTest.x}, #{pointToTest.y}, #{pointToTest.z}
    vertex: #{linePoint1.x}, #{linePoint1.y}, #{linePoint1.z}"
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
  console.log distance
  if distance is 0
    return true
  else
    return false



checkForBoundaryEdge = (dir, point, plate1, plate2) ->
  # check distance of vertices to line. if distances 0 -> shared edge!
  for edgeLoop in plate1
    for vertex in edgeLoop.vertices
      console.log isOnLine(vertex, dir, point)

btnFindIntersection = (event) ->
  event.preventDefault()

  console.log 'calculations started'

  for plate in myObject
    for edgeLoop in plate
      plane = createPlane(
                          edgeLoop.vertices[0]
                          edgeLoop.vertices[1]
                          edgeLoop.vertices[2])
      edgeLoop.normal = plane.normal
      edgeLoop.constant = plane.constant

  if myObject? and (myObject.length >= 2)
    console.log 'intersections possible'
    for plate1, index in myObject
      if index + 1 < myObject.length
        for plate2 in myObject[index + 1...myObject.length]
          alert "testing #{plate1[0].name} with #{plate2[0].name}"
          dir = new THREE.Vector3()
          dir.crossVectors(plate1[0].normal, plate2[0].normal)
          console.log "direction of possible intersection vector:
                 (#{dir.x}, #{dir.y}, #{dir.z})"
          point = findPointOnBothPlanes(dir, plate1, plate2)
          console.log "point on plane: #{point}"
          checkForBoundaryEdge(dir, point, plate1, plate2)
  else
    console.log 'not enough plates for intersections'



drawLines = ( object ) ->
  clearScene()

  material = new THREE.LineBasicMaterial( color: 0xAAAAAA )
  for plate in object
    for edgeLoop in plate
      geometry = new THREE.Geometry()
      for vertex in edgeLoop.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( edgeLoop.vertices[0] )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )


btnScene1 = ( event ) ->
  event.preventDefault()

  edgeLoop1 =
    vertices: [
      new THREE.Vector3( -3, -3, 0 )
      new THREE.Vector3(  3, -3, 0 )
      new THREE.Vector3(  3,  3, 0 )
      new THREE.Vector3( -3,  3, 0 )
    ]
    name: '1'
    thickness: 2
    hole: false
    normal: new THREE.Vector3()
    area: null # will be given but unimportant to me

  edgeLoop2 =
    vertices: [
      # new THREE.Vector3(  3,  3, 0 )
      # new THREE.Vector3(  3, -3, 0 )
      # new THREE.Vector3(  4, -3, 0 )
      # new THREE.Vector3(  4,  3, 0 )
      new THREE.Vector3(  3,  3,  0 )
      new THREE.Vector3(  3, -3,  0 )
      new THREE.Vector3(  3, -3, -1 )
      new THREE.Vector3(  3,  3, -1 )
    ]
    name: '2'
    thickness: 2
    hole: false
    normal: new THREE.Vector3()
    area: null # will be given but unimportant to me

  plate1 = [ edgeLoop1 ]
  plate2 = [ edgeLoop2 ]

  myObject = [ plate1, plate2 ]

  drawLines( myObject )


render = ->
  requestAnimationFrame( render )
  renderer.render(scene, camera)


setupRenderSize = ->
  camera = new THREE.PerspectiveCamera(
    75
    view3d.width() / view3d.height()
    0.1
    1000
  )
  camera.position.z = 5
  renderer.setSize( view3d.width(), view3d.height() )


$(window).resize ->
  setupRenderSize()


# on load render
$(->
  view3d = $( '#3d-view' )
  view3d.height '100%'
  setupRenderSize()
  view3d.append $( renderer.domElement )
  $('#btnScene1')
    .button().click( btnScene1 ).text('Click for Scene')
  $('#btnFindIntersection')
    .button().click(btnFindIntersection).text('Find intersections')


  #controls = new OrbitControls( camera, renderer.domElement )
  #controls.addEventListener( 'change', render )

  render()
)
