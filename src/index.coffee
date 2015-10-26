require('jquery-ui')

THREE = require 'three'
$ = require 'jquery'
loader = require './loadModel'
ShapesFinder = require './findShapes'
CoplanarFaces = require './coplanarFaces'
meshlib = require 'meshlib'


### SCENE SETUP ###

# scene
scene = new THREE.Scene()

# renderer
renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )

# camera
camera = new THREE.PerspectiveCamera(
  75
  window.innerWidth / window.innerHeight
  0.1
  1000
)
camera.position.z = 5

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


### HELPERS ###

render = ->
  requestAnimationFrame(render)

  # if (root.children.length > 0)
  #   root.children[0].rotation.x += 0.005
  #   root.children[0].rotation.y += 0.005

  for child in root.children
    child.rotation.x += 0.02
    child.rotation.y += 0.01

  cube2.rotation.x += 0.05
  cube2.rotation.y += 0.05

  if cube2.position.x > 2.0 or cube2.position.x < -2.0 or
  cube2.position.y > 2.0 or cube2.position.y < -2.0
    cube2Translation *= -1.0

  cube2.translateX(cube2Translation)
  renderer.render(scene, camera)

drawCoplanarMeshes = (drawable) ->
  while (root.children.length > 0)
    root.remove root.children[0]

  root.add drawable

setupRenderSize = (view3d) ->
  camera = new THREE.PerspectiveCamera(
    75
    view3d.width() / view3d.height()
    0.1
    1000
  )
  camera.position.z = 5
  renderer.setSize( view3d.width(), view3d.height() )


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

  view3d = $ '#3d-view'
  $('body')
    .on 'drop', (event) ->
      _loadModel event.originalEvent
        .then (obj) ->
          geo = obj.geometry
          model = obj.model
          loader.zoomTo geo.boundingSphere, camera, scene
          coplanarFaces = new CoplanarFaces()
          #coplanarFaces.setDebug true
          coplanarFaces.setThreshold 0.001
          faceSets = coplanarFaces.findCoplanarFaces model
          shapesFinder = new ShapesFinder()
          shapesFinder.findShapesFromFaceSets faceSets
          #shapesFinder.findShapesFromModel model
          #drawCoplanarMeshes coplanarFaces.getDrawable()
          clearScene()
          coplanarFaces.setupDrawable()
          root.add coplanarFaces.getDrawable()
          root.add shapesFinder.getDrawable()
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
