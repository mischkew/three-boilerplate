THREE = require 'three'
$ = require 'jquery'
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

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )

geometry = new THREE.BoxGeometry(1, 1, 1)
material = new THREE.MeshBasicMaterial({ color: 0x00ff00 })
cube = new THREE.Mesh(geometry, material)
scene.add(cube)

material = new THREE.MeshBasicMaterial( { color: 0xff0000 } )
cube2 = new THREE.Mesh( geometry, material )
scene.add( cube2 )

camera.position.z = 5

console.log(cube2)

cube2Translation = 0.05




render = ->
  requestAnimationFrame(render)

  cube.rotation.x += 0.1
  cube.rotation.y += 0.1

  cube2.rotation.x += 0.05
  cube2.rotation.y += 0.05

  if cube2.position.x > 2.0 or cube2.position.x < -2.0 or
  cube2.position.y > 2.0 or cube2.position.y < -2.0
    cube2Translation *= -1.0

  cube2.translateX(cube2Translation)
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
  $('#slider').slider({
    orientation: 'vertical'
    })
  render()
)
