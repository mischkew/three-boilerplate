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




edgeSequence1 =
  vertices: [ new THREE.Vector3( -3, -3, 0 )
    new THREE.Vector3(  3, -3, 0 )
    new THREE.Vector3(  3,  3, 0 )
    new THREE.Vector3( -3,  3, 0 )
  ]
  area: null
  hole: null

edgeSequence2 =
  vertices: [ new THREE.Vector3( -1, -1, 0 )
    new THREE.Vector3(  1, -1, 0 )
    new THREE.Vector3(  1,  1, 0 )
    new THREE.Vector3( -1,  1, 0 )
  ]
  area: null
  hole: null

shape1 = [ edgeSequence1, edgeSequence2 ]

myObject = [ shape1 ]

for shape in myObject
  maximumIndex = null

  for sequence, sequenceIndex in shape
    sequence.area += vertex.x *
      sequence.vertices[ ( i + 1 ) %% sequence.vertices.length ].y -
      sequence.vertices[ ( i + 1 ) %% sequence.vertices.length ].x *
      vertex.y for vertex, i in sequence.vertices
    sequence.area *= 0.5
    maximumIndex = sequenceIndex if not shape[maximumIndex]? or
      shape[maximumIndex]?.area < sequence.area
    sequence.hole = true

  shape[ maximumIndex ]?.hole = false




for shape, shapeInd in myObject
  console.log "shape #{shapeInd}"
  for sequence, sequenceInd in shape
    console.log "sequence #{sequenceInd}"
    console.log "area = #{sequence.area}"
    console.log "hole = #{sequence.hole}"



for shape in myObject

  for sequence in shape
    geometry = new THREE.Geometry()

    for vertex, vertexInd in sequence.vertices
      geometry.vertices.push( vertex )

      if vertexInd >= 2
        face = new THREE.Face3( 0, vertexInd - 1, vertexInd )
        geometry.faces.push( face )

    material = new THREE.MeshBasicMaterial(
      color: if sequence.hole then 0xff0000 else 0x00ff00 )
    mesh = new THREE.Mesh( geometry, material )
    scene.add( mesh )


camera.position.z = 5


render = ->
  requestAnimationFrame(render)
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
