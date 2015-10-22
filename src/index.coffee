require('jquery-ui')

THREE = require 'three'
$ = require 'jquery'
loader = require './loadModel'
coplanarFaces = require './coplanarFaces'
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
    child.rotation.x += 0.01# * Math.random()
    child.rotation.y += 0.01# * Math.random()

  cube2.rotation.x += 0.05
  cube2.rotation.y += 0.05

  if cube2.position.x > 2.0 or cube2.position.x < -2.0 or
  cube2.position.y > 2.0 or cube2.position.y < -2.0
    cube2Translation *= -1.0

  cube2.translateX(cube2Translation)
  renderer.render(scene, camera)

drawCoplanarMeshes = (models) ->
  while (root.children.length > 0)
    root.remove root.children[0]

  #for pm in models
  #  console.log coplanarFaces.calculateSurfaceArea pm[0].vertices

  geoms = []

  #console.log models

  for model in models
    geometry = new THREE.Geometry()
    for face in model
      for i in [0..2]
        geometry.vertices.push(new THREE.Vector3(
          face.vertices[i].x,
          face.vertices[i].y,
          face.vertices[i].z))
      len = geometry.vertices.length
      geometry.faces.push(new THREE.Face3(len - 3, len - 2, len - 1))
    geoms.push geometry

  #console.log '-----'

  #for ge in geoms
  #  console.log (coplanarFaces.calculateSurfaceArea ge.vertices)

  #console.log '-----'

  meshes = []

  for geom in geoms
    #console.log geom.vertices[0]
    mesh = new THREE.Mesh(geom)
    mesh.material.side = 2
    meshes.push(mesh)
    root.add mesh

  #for me in meshes
  #  console.log (coplanarFaces.calculateSurfaceArea me.geometry.vertices)

  #console.log root
  #console.log meshes

  #render()

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


### INITIALIZATION ###

$(->
  # ui helpers
  $('#slider').slider({
    orientation: 'vertical'
  })
  $('body')
    .on 'drop', (event) ->
      _loadModel event.originalEvent
        .then (obj) ->
          geo = obj.geometry
          model = obj.model
          #console.log model
          loader.zoomTo geo.boundingSphere, camera, scene
          models = coplanarFaces.findCoplanarFaces model
          # console.log models.length
          # console.log 'AAAAA'
          # console.log models[0]
          drawCoplanarMeshes(models)
          console.log 'END'
      stopEvent event
    .on 'dragenter', stopEvent
    .on 'dragleave', stopEvent
    .on 'dragover', stopEvent

  # rendering
  view3d = $ '#3d-view'
  view3d.height '100%'
  setupRenderSize(view3d)
  $(window).resize ->
    setupRenderSize(view3d)
  view3d.append renderer.domElement

  render()
)
