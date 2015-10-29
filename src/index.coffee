THREE = require 'three'
$ = require 'jquery'
#OrbitControls = require('three-orbit-controls')(THREE)
require('jquery-ui')
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


calcNormalizedNormal = (vertex1, vertex2, vertex3) ->
  vector1 = new THREE.Vector3()
  vector2 = new THREE.Vector3()
  vector1.subVectors(vertex2, vertex1)
  vector2.subVectors(vertex3, vertex1)

  crossProduct = new THREE.Vector3()
  crossProduct.crossVectors(vector1, vector2)
  normal = new THREE.Vector3()
  normal = crossProduct.divideScalar(crossProduct.length())
  return normal


btnFindIntersection = (event) ->
  event.preventDefault()

  console.log 'calculations started'

  if myObject? and (myObject.length >= 2)
    console.log 'intersections possible'
    for plate1, index in myObject
      if index + 1 < myObject.length
        for plate2 in myObject[index + 1...myObject.length]
          alert "testing #{plate1[0].name} with #{plate2[0].name}"
          normal = calcNormalizedNormal(
            plate1[0].vertices[0],
            plate1[0].vertices[1],
            plate1[0].vertices[2] )
          console.log "Normal of first plate:
            (#{normal.x},#{normal.y},#{normal.z})"
          normal2 = calcNormalizedNormal(
            plate2[0].vertices[0],
            plate2[0].vertices[1],
            plate2[0].vertices[2] )
          console.log "Normal of second plate:
            (#{normal2.x},#{normal2.y},#{normal2.z})"

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
    normal: null
    area: null # will be given but unimportant to me

  edgeLoop2 =
    vertices: [
      new THREE.Vector3(  3,  3, 0 )
      new THREE.Vector3(  3, -3, 0 )
      new THREE.Vector3(  4, -3, 0 )
      new THREE.Vector3(  4,  3, 0 )
    ]
    name: '2'
    thickness: 2
    hole: false
    normal: null
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
    .button().click(btnFindIntersection).text('Find inter sections')


  #controls = new OrbitControls( camera, renderer.domElement )
  #controls.addEventListener( 'change', render )

  render()
)
