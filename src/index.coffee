THREE = require 'three'
$ = require 'jquery'
loadModel = require './loadModel'


# SCENE SETUP

scene = new THREE.Scene()

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )

camera = new THREE.PerspectiveCamera(
  75
  window.innerWidth / window.innerHeight
  0.1
  1000
)
camera.position.z = 5

parent = new THREE.Object3D()
scene.add(parent)

# configure model loading
_loadModel = loadModel parent, camera, scene

# HELPERS

render = ->
  requestAnimationFrame(render)

  if (parent.children.length > 0)
    parent.children[0].rotation.x += 0.005
    parent.children[0].rotation.y += 0.005

  renderer.render(scene, camera)

# INIT DROP ZONE

$( ->
  $('#dropZone')
    .on('drop', (event) ->
      _loadModel event
      event.preventDefault()
      event.stopPropagation()
    )

  # start rendering
  document.body.appendChild( renderer.domElement )
  render()
)
