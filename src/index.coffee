require('jquery-ui')

THREE = require 'three'
OrbitControls = require('three-orbit-controls')(THREE)
$ = require 'jquery'
require('jquery-ui')
HoleDetection = require './holeDetection'
ShapeRotator = require './shapeRotator'
EdgeLoop = require './edgeLoop'
Shape = require './shape'
loader = require './loadModel'
ShapesFinder = require './findShapes'
CoplanarFaces = require './coplanarFaces'
HoleDetector = require './holeDetection'
meshlib = require 'meshlib'
Util = require './utilityFunctions'

### SCENE SETUP ###

# scene
scene = new THREE.Scene()

# renderer
renderer = new THREE.WebGLRenderer({ antialias: true })
renderer.setSize( window.innerWidth, window.innerHeight )

# camera
camera = new THREE.PerspectiveCamera(
  75
  window.innerWidth / window.innerHeight
  0.1
  1000
)
camera.position.z = 10

# boundingSphere = { radius: 0.866025, center: new THREE.Vector3(0, 0, 0) }
#
# # root object
# root = new THREE.Object3D()
# scene.add(root)
#
# # configure model loading
# _loadModel = loader.loadModel root, camera, scene
#
# # some scene objects
# geometry = new THREE.BoxGeometry(1, 1, 1)
# material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } )
#
# cube2 = new THREE.Mesh( geometry, material )
# cube2Translation = 0.05
#
# root.add( cube2 )
#
# loader.zoomTo boundingSphere, camera, scene


sceneGraph = new THREE.Object3D()
scene.add( sceneGraph )

myObject = null


clearScene = ->
  sceneGraph.children = []

btnPlanify = ->
  clearScene()

  rotator = new ShapeRotator()
  rotator.layIntoXYPlane( myObject )
  drawable = rotator.getDrawable()
  sceneGraph.add( drawable )

btnHolify = ->
  clearScene()

  detector = new HoleDetection()
  detector.detectHoles( myObject )
  drawable = detector.getDrawable()
  sceneGraph.add( drawable )


drawLines = ( object ) ->
  clearScene()

  material = new THREE.LineBasicMaterial( color: 0xAAAAAA )
  for shape in object
    for edgeLoop in shape.getEdgeLoops()
      geometry = new THREE.Geometry()
      for vertex in edgeLoop.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( edgeLoop.vertices[0] )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )


btnTest1 = ( event ) ->
  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -3, -3, 0 )
    new THREE.Vector3(  3, -3, 0 )
    new THREE.Vector3(  3,  3, 0 )
    new THREE.Vector3( -3,  3, 0 )
  ] )

  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3( -1, -1, 0 )
    new THREE.Vector3(  1, -1, 0 )
    new THREE.Vector3(  1,  1, 0 )
    new THREE.Vector3( -1,  1, 0 )
  ] )

  normal = new THREE.Vector3( 0, 0, 1 )

  shape1 = new Shape( [ edgeLoop1, edgeLoop2 ], normal )

  myObject = [ shape1 ]

  drawLines( myObject )


btnTest2 = ( event ) ->
  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -3, -3, 0 )
    new THREE.Vector3(  3, -3, 0 )
    new THREE.Vector3(  3,  3, 0 )
    new THREE.Vector3( -3,  3, 0 )
  ] )

  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3( -2, -2, 0 )
    new THREE.Vector3( -1, -2, 0 )
    new THREE.Vector3( -1, -0.5, 0 )
    new THREE.Vector3( -2, -0.5, 0 )
  ] )

  edgeLoop3 = new EdgeLoop( [
    new THREE.Vector3( 0, 0, 0 )
    new THREE.Vector3( 2.5, -0.7, 0 )
    new THREE.Vector3( 2.3, 0, 0 )
    new THREE.Vector3( 1, 2, 0 )
    new THREE.Vector3( -1, 1, 0 )
  ] )

  normal = new THREE.Vector3( 0, 0, 1 )

  shape1 = new Shape( [ edgeLoop1, edgeLoop2, edgeLoop3 ], normal )

  myObject = [ shape1 ]

  drawLines( myObject )


btnTest3 = ( event ) ->
  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -2.7, -2.5, 0.2 )
    new THREE.Vector3(  6, -2.5, -8.5 )
    new THREE.Vector3(  -0.5, 0.7, 1.2 )
  ] )

  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3( -3, -3, 0 )
    new THREE.Vector3(  9, -3, -12 )
    new THREE.Vector3(  -1, 1, 2 )
   ] )

  normal = new THREE.Vector3( 0.577350269, -0.577350269, 0.577350269 )

  shape1 = new Shape( [ edgeLoop1, edgeLoop2 ], normal )

  myObject = [ shape1 ]

  drawLines( myObject )


btnTest4 = ( event ) ->
  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( -2, 0, -2 )
    new THREE.Vector3(  2, 0, -2 )
    new THREE.Vector3(  0, 0, 2 )
  ] )

  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3( -1, 0, -1 )
    new THREE.Vector3(  1, 0, -1 )
    new THREE.Vector3(  0, 0, 1 )
  ] )

  normal = new THREE.Vector3( 0, 1, 0 )

  shape1 = new Shape( [ edgeLoop1, edgeLoop2 ], normal )

  myObject = [ shape1 ]

  drawLines( myObject )


btnTest5 = ( event ) ->
  edgeLoop1 = new EdgeLoop( [
    new THREE.Vector3( 0, -2, -2 )
    new THREE.Vector3(  0, 2, -2 )
    new THREE.Vector3(  0, 0, 2 )
  ] )

  edgeLoop2 = new EdgeLoop( [
    new THREE.Vector3( 0, -1, -1 )
    new THREE.Vector3(  0, 1, -1 )
    new THREE.Vector3(  0, 0, 1 )
  ] )

  normal = new THREE.Vector3( 1, 0, 0 )

  shape1 = new Shape( [ edgeLoop1, edgeLoop2 ], normal )

  myObject = [ shape1 ]

  drawLines( myObject )




### HELPERS ###

render = ->
  requestAnimationFrame(render)

  # for child in root.children
  #   child.rotation.x += 0.02
  #   child.rotation.y += 0.01

  renderer.render(scene, camera)

setupRenderSize = (view3d) ->
  camera = new THREE.PerspectiveCamera(
    50
    view3d.width() / view3d.height()
    0.1
    1000
  )
  camera.position.z = 10
  renderer.setSize( view3d.width(), view3d.height() )
  # loader.zoomTo boundingSphere, camera, scene

stopEvent = (event) ->
  event.preventDefault()
  event.stopPropagation()

# clearScene = ->
#   while (root.children.length > 0)
#     root.remove root.children[0]

### INITIALIZATION ###
$(->
  # ui helpers
  $('#slider').slider({
    orientation: 'vertical'
  })

  $('#btnTest1').button().click( btnTest1 )
  $('#btnTest2').button().click( btnTest2 )
  $('#btnTest3').button().click( btnTest3 )
  $('#btnTest4').button().click( btnTest4 )
  $('#btnTest5').button().click( btnTest5 )
  $('#btnplanify').button().click( btnPlanify )
  $('#btnHolify').button().click( btnHolify )


  view3d = $ '#3d-view'
  # $('body')
  #   .on 'drop', (event) ->
  #     _loadModel event.originalEvent
  #       .then (obj) ->
  #         model = Util.centerModel(obj.model)
  #
  #         boundingSphere = obj.geometry.boundingSphere
  #         boundingSphere.center = new THREE.Vector3(0, 0, 0)
  #         setupRenderSize view3d
  #
  #         coplanarFaces = new CoplanarFaces()
  #         #coplanarFaces.setDebug true
  #         coplanarFaces.setThreshold 0.001
  #         faceSets = coplanarFaces.findCoplanarFaces model
  #
  #         shapesFinder = new ShapesFinder()
  #         shapes = shapesFinder.findShapesFromFaceSets faceSets
  #
  #         holeDetector = new HoleDetector()
  #         holeDetector.detectHoles(shapes)
  #
  #         clearScene()
  #         coplanarFaces.setupDrawable()
  #         root.add coplanarFaces.getDrawable().translateX(
  #           2 * boundingSphere.radius)
  #         root.add shapesFinder.getDrawable()
  #         root.add holeDetector.getDrawable().translateX(
  #           2 * -boundingSphere.radius)
  #         console.log 'END'
  #     stopEvent event
  #   .on 'dragenter', stopEvent
  #   .on 'dragleave', stopEvent
  #   .on 'dragover', stopEvent

  # rendering
  view3d.height '100%'
  setupRenderSize(view3d)
  $(window).resize ->
    setupRenderSize(view3d)
  view3d.append renderer.domElement


  controls = new OrbitControls( camera, renderer.domElement )
  controls.addEventListener( 'change', render )

  render()
)
