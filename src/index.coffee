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
    edgeLoop = plate.shape.edgeLoops[0]
    plane = new THREE.Plane()
    plane.setFromCoplanarPoints(
                        edgeLoop.vertices[0]
                        edgeLoop.vertices[1]
                        edgeLoop.vertices[2])
    plate.shape.normal = plane.normal
    for edgeLoop in plate.shape.edgeLoops
      geometry = new THREE.Geometry()
      for vertex in edgeLoop.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( edgeLoop.vertices[0] )
      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )

drawParallelLines = (object) ->
  material = new THREE.LineBasicMaterial( color: 0xff0000 )
  material2 = new THREE.LineBasicMaterial( color: 0x00ff00 )
  for plate in object
    translationVector = plate.shape.normal
    translationVector.multiplyScalar( plate.thickness )
    for edgeLoop in plate.shape.edgeLoops
      geometry = new THREE.Geometry()
      for vertex in edgeLoop.vertices
        geometry2 = new THREE.Geometry()
        translatedVertex = new THREE.Vector3()
        translatedVertex.addVectors(vertex, translationVector)
        geometry.vertices.push( translatedVertex )
        geometry2.vertices.push( vertex, translatedVertex )
        line2 = new THREE.Line( geometry2, material2 )
        sceneGraph.add( line2 )
      translatedFirstVertex = new THREE.Vector3()
      translatedFirstVertex.addVectors(edgeLoop.vertices[0], translationVector )
      geometry.vertices.push( translatedFirstVertex )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )

btnScene = ( event ) ->
  event.preventDefault()

  # console.log 'you clicked for Scene'
  thickness = 0.1

  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -2, -2, 0 - thickness )
    new THREE.Vector3(  2, -2, 0 - thickness )
    new THREE.Vector3(  2,  2, 0 - thickness )
    new THREE.Vector3( -2,  2, 0 - thickness )
  ] )
  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3(  2,  2,  0 )
    new THREE.Vector3(  2, -2,  0 )
    new THREE.Vector3(  2, -2, -1 )
    new THREE.Vector3(  2,  2, -1 )
  ] )
  edgeLoop3 = new EdgeLoop( [
    new THREE.Vector3(  3,  2 + thickness,  0 )
    new THREE.Vector3( -2,  2 + thickness,  0 )
    new THREE.Vector3( -2,  2 + thickness, -1 )
    new THREE.Vector3(  3,  2 + thickness, -1 )
  ] )
  edgeLoop4 = new EdgeLoop( [
    new THREE.Vector3(  -2 - thickness,  2,  0 )
    new THREE.Vector3(  -2 - thickness, -2,  0 )
    new THREE.Vector3(  -2 - thickness, -2, -2 )
    new THREE.Vector3(  -2 - thickness,  2, -2 )
  ] )
  edgeLoop5 = new EdgeLoop( [
    new THREE.Vector3( -1, -1, 0 - thickness )
    new THREE.Vector3(  1, -1, 0 - thickness )
    new THREE.Vector3(  1,  1, 0 - thickness )
    new THREE.Vector3( -1,  1, 0 - thickness )
  ] )
  edgeLoop6 = new EdgeLoop( [
    new THREE.Vector3(  -2 - thickness, -2.5,  -0.5 )
    new THREE.Vector3(  -2 - thickness, -2.5,  0 )
    new THREE.Vector3(  -1 - thickness, -2.5,  0 )
    new THREE.Vector3(  -1 - thickness, -2.5,  -0.5 )
  ] )

  shape1 = new Shape( [ edgeLoop1, edgeLoop5 ], new THREE.Vector3())
  shape2 = new Shape( [ edgeLoop2 ], new THREE.Vector3() )
  shape3 = new Shape( [ edgeLoop3 ], new THREE.Vector3() )
  shape4 = new Shape( [ edgeLoop4 ], new THREE.Vector3() )
  shape5 = new Shape( [ edgeLoop6 ], new THREE.Vector3() )

  plate1 = new Plate(shape1, thickness, null, null)
  plate2 = new Plate(shape2, thickness, null, null)
  plate3 = new Plate(shape3, thickness, null, null)
  plate4 = new Plate(shape4, thickness, null, null)
  plate5 = new Plate(shape5, thickness, null, null)

  myObject = [ plate1, plate2, plate3, plate4, plate5 ]

  drawLines( myObject )
  drawParallelLines( myObject )


btnCalculate = (event) ->
  event.preventDefault()
  reset()
  graphCreator = new GraphCreator()
  sceneElements = graphCreator.createGraph(myObject, null)
  for element in sceneElements
    sceneGraph.add( element )

reset = ->
  drawLines( myObject )
  drawParallelLines( myObject )

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
