THREE = require 'three'
$ = require 'jquery'
#OrbitControls = require('three-orbit-controls')(THREE)
require('jquery-ui')
numeric = require './numeric-1.2.6.js'
GraphCreator = require './CreateGraph'
Plate = require './Plate'
Shape = require './Shape'
EdgeLoop = require './EdgeLoop'

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

myObject = []

clearScene = ->
  sceneGraph.children = []


drawLines = ( object ) ->
  clearScene()

  material = new THREE.LineBasicMaterial( color: 0xAAAAAA )
  for plate in object
    for edgeLoop in plate.shape.edgeLoops
      geometry = new THREE.Geometry()
      for vertex in edgeLoop.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( edgeLoop.vertices[0] )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )


btnScene = ( event ) ->
  event.preventDefault()

  console.log 'you clicked for Scene'

  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -3, -3, 0 )
    new THREE.Vector3(  3, -3, 0 )
    new THREE.Vector3(  3,  3, 0 )
    new THREE.Vector3( -3,  3, 0 )
  ] )
  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3(  3,  3,  0 )
    new THREE.Vector3(  3, -3,  0 )
    new THREE.Vector3(  3, -3, -1 )
    new THREE.Vector3(  3,  3, -1 )
  ] )
  edgeLoop3 = new EdgeLoop( [
    new THREE.Vector3(  3,  3,  0 )
    new THREE.Vector3( -3,  3,  0 )
    new THREE.Vector3( -3,  3, -1 )
    new THREE.Vector3(  3,  3, -1 )
  ] )
  edgeLoop4 = new EdgeLoop( [
    new THREE.Vector3(  -3,  3,  0 )
    new THREE.Vector3(  -3, -3,  0 )
    new THREE.Vector3(  -3, -3, -1 )
    new THREE.Vector3(  -3,  3, -1 )
  ] )
  edgeLoop5 = new EdgeLoop( [
    new THREE.Vector3( -1.5, -1.5, 0 )
    new THREE.Vector3(  1.5, -1.5, 0 )
    new THREE.Vector3(  1.5,  1.5, 0 )
    new THREE.Vector3( -1.5,  1.5, 0 )
  ] )

  shape1 = new Shape( [ edgeLoop1, edgeLoop5 ], new THREE.Vector3())
  shape2 = new Shape( [ edgeLoop2 ], new THREE.Vector3() )
  shape3 = new Shape( [ edgeLoop3 ], new THREE.Vector3() )
  shape4 = new Shape( [ edgeLoop4 ], new THREE.Vector3() )

  plate1 = new Plate(shape1, 1, null)
  plate2 = new Plate(shape2, 1, null)
  plate3 = new Plate(shape3, 1, null)
  plate4 = new Plate(shape4, 1, null)

  myObject = [ plate1, plate2, plate3, plate4 ]

  drawLines( myObject )


btnCalculate = (event) ->
  event.preventDefault()
  reset()
  graphCreator = new GraphCreator()
  sceneElements = graphCreator.createGraph(myObject, null)
  for element in sceneElements
    sceneGraph.add( element )

reset = ->
  drawLines( myObject )

render = ->
  requestAnimationFrame( render )
  for child in sceneGraph.children
    child.rotation.x += 0.008
    child.rotation.y += 0.004
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
  $('#btnScene')
    .button().click( btnScene ).text('Click for Scene')
  $('#calculate')
    .button().click( btnCalculate ).text('calculate plateGraph')
  # $('#reset')
  #  .button().click( reset ).text('Reset Scene')


  #controls = new OrbitControls( camera, renderer.domElement )
  #controls.addEventListener( 'change', render )

  render()
)
