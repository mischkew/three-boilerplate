THREE = require 'three'
$ = require 'jquery'

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

camera.position.z = 5

render = ->
  requestAnimationFrame(render)

  cube.rotation.x += 0.1
  cube.rotation.y += 0.1

  renderer.render(scene, camera)


# on load render
$(->
  document.body.appendChild( renderer.domElement )
  render()
)
