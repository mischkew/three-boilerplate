require('jquery-ui')

THREE = require 'three'
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
SVG = require './svg'

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
camera.position.z = 5

boundingSphere = { radius: 0.866025, center: new THREE.Vector3(0, 0, 0) }

# root object
root = new THREE.Object3D()
scene.add(root)

# configure model loading
_loadModel = loader.loadModel root, camera, scene

# some scene objects
geometry = new THREE.BoxGeometry(1, 1, 1)
material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } )

cube2 = new THREE.Mesh( geometry, material )
cube2Translation = 0.05

root.add( cube2 )

loader.zoomTo boundingSphere, camera, scene


### HELPERS ###

render = ->
  requestAnimationFrame(render)

  for child in root.children
    child.rotation.x += 0.02
    child.rotation.y += 0.01

  renderer.render(scene, camera)

setupRenderSize = (view3d) ->
  camera = new THREE.PerspectiveCamera(
    50
    view3d.width() / view3d.height()
    0.1
    1000
  )
  camera.position.z = 5
  renderer.setSize( view3d.width(), view3d.height() )
  loader.zoomTo boundingSphere, camera, scene

stopEvent = (event) ->
  event.preventDefault()
  event.stopPropagation()

clearScene = ->
  while (root.children.length > 0)
    root.remove root.children[0]

### INITIALIZATION ###
$(->
  # ui helpers
  $('#slider').slider({
    orientation: 'vertical'
  })

  # ======= SVG test =========
  svg = new SVG(300, 400)
  svgEdgeLoop1 = new EdgeLoop([
    new THREE.Vector3( 20, 20, 0)
    new THREE.Vector3( 20, 50, 0)
    new THREE.Vector3( 50, 50, 0)
    new THREE.Vector3( 50, 20, 0)
  ])
  svgEdgeLoop2 = new EdgeLoop([
    new THREE.Vector3( 30, 30, 0)
    new THREE.Vector3( 30, 40, 0)
    new THREE.Vector3( 40, 40, 0)
    new THREE.Vector3( 40, 30, 0)
  ])
  svgShape = new Shape([svgEdgeLoop1, svgEdgeLoop2])
  svg.addShape svgShape
  url = svg.getObjectURL()
  svgDownload = $( '#svgDownload' )
  svgDownload.attr(
    'href'
    url
    )
  svgDownload.attr( 'download', 'test.svg' )
  # ======= SVG test =========

  view3d = $ '#3d-view'
  $('body')
    .on 'drop', (event) ->
      _loadModel event.originalEvent
        .then (obj) ->
          model = Util.centerModel(obj.model)

          boundingSphere = obj.geometry.boundingSphere
          boundingSphere.center = new THREE.Vector3(0, 0, 0)
          setupRenderSize view3d

          coplanarFaces = new CoplanarFaces()
          #coplanarFaces.setDebug true
          coplanarFaces.setThreshold 0.001
          faceSets = coplanarFaces.findCoplanarFaces model

          shapesFinder = new ShapesFinder()
          shapes = shapesFinder.findShapesFromFaceSets faceSets

          shapeRotator = new ShapeRotator()
          shapeRotator.layIntoXYPlane( shapes )

          holeDetector = new HoleDetector()
          holeDetector.detectHoles( shapes )

          clearScene()
          coplanarFaces.setupDrawable()
          root.add coplanarFaces.getDrawable().translateX(
            2 * boundingSphere.radius)
          root.add shapesFinder.getDrawable()
          root.add holeDetector.getDrawable().translateX(
            2 * -boundingSphere.radius)
          console.log 'END'
      stopEvent event
    .on 'dragenter', stopEvent
    .on 'dragleave', stopEvent
    .on 'dragover', stopEvent

  # rendering
  view3d.height '100%'
  setupRenderSize(view3d)
  $(window).resize ->
    setupRenderSize(view3d)
  view3d.append renderer.domElement

  render()
)
