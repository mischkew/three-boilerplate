THREE = require 'three'
$ = require 'jquery'
#OrbitControls = require('three-orbit-controls')(THREE)
require('jquery-ui')
numeric = require './numeric-1.2.6.js'
Graph = require './CreateGraph'

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
    constant: null
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
    constant: null
    area: null # will be given but unimportant to me

  edgeLoop3 =
    vertices: [
      new THREE.Vector3(  3,  3,  0 )
      new THREE.Vector3( -3,  3,  0 )
      new THREE.Vector3( -3,  3, -1 )
      new THREE.Vector3(  3,  3, -1 )
    ]
    name: '3'
    thickness: 2
    hole: false
    normal: new THREE.Vector3()
    constant: null
    area: null # will be given but unimportant to me

  edgeLoop4 =
    vertices: [
      new THREE.Vector3(  -3,  3,  0 )
      new THREE.Vector3(  -3, -3,  0 )
      new THREE.Vector3(  -3, -3, -1 )
      new THREE.Vector3(  -3,  3, -1 )
    ]
    name: '4'
    thickness: 2
    hole: false
    normal: new THREE.Vector3()
    constant: null
    area: null # will be given but unimportant to me

  edgeLoop5 =
    vertices: [
      new THREE.Vector3( -1.5, -1.5, 0 )
      new THREE.Vector3(  1.5, -1.5, 0 )
      new THREE.Vector3(  1.5,  1.5, 0 )
      new THREE.Vector3( -1.5,  1.5, 0 )
    ]
    name: '5'
    thickness: 2
    hole: true
    normal: new THREE.Vector3()
    constant: null
    area: null # will be given but unimportant to me


  plate1 = [ edgeLoop1, edgeLoop5 ]
  plate2 = [ edgeLoop2 ]
  plate3 = [ edgeLoop3 ]
  plate4 = [ edgeLoop4 ]

  myObject = [ plate1, plate2, plate3, plate4 ]
  # myObject = [ plate1, plate2 ]

  drawLines( myObject )
  graphCreator = new Graph()
  sceneElements = graphCreator.createGraph(myObject, null)
  for element in sceneElements
    sceneGraph.add( element )

reset = ->
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
  $('#reset')
   .button().click( reset ).text('Reset Scene')


  #controls = new OrbitControls( camera, renderer.domElement )
  #controls.addEventListener( 'change', render )

  render()
)
