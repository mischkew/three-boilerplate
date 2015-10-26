THREE = require 'three'
$ = require 'jquery'
#OrbitControls = require('three-orbit-controls')(THREE)
require('jquery-ui')

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



btnFindIntersection = (event) ->
  event.preventDefault()

  console.log 'calculations started'

  if myObject? and (myObject.length is 2)
    console.log 'intersections possible'
    for plate1 in myObject
      for plate2 in myObject
            alert "testing #{plate1[0].name} with #{plate2[0].name}"
  else
    console.log 'not enough plates for intersections'



drawLines = ( object ) ->
  clearScene()

  material = new THREE.LineBasicMaterial( color: 0xAAAAAA )
  for plate in object
    for sequence in plate
      geometry = new THREE.Geometry()
      for vertex in sequence.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( sequence.vertices[0] )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )


btnScene1 = ( event ) ->
  event.preventDefault()

  edgeSequence1 =
    vertices: [
      new THREE.Vector3( -3, -3, 0 )
      new THREE.Vector3(  3, -3, 0 )
      new THREE.Vector3(  3,  3, 0 )
      new THREE.Vector3( -3,  3, 0 )
    ]
    name: '1'
    thickness: 2
    hole: false
    area: true

  edgeSequence2 =
    vertices: [
      new THREE.Vector3(  3,  3, 0 )
      new THREE.Vector3(  3, -3, 0 )
      new THREE.Vector3(  4, -3, 0 )
      new THREE.Vector3(  4,  3, 0 )
    ]
    name: '2'
    thickness: 2
    hole: false
    area: true

  plate1 = [ edgeSequence1 ]
  plate2 = [ edgeSequence2 ]

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
