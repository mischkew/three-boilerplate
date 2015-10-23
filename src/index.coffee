THREE = require 'three'
$ = require 'jquery'
OrbitControls = require('three-orbit-controls')(THREE)
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


btnHolify = ->
  clearScene()

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
      sceneGraph.add( mesh )


drawLines = ( object ) ->
  clearScene()

  material = new THREE.LineBasicMaterial( color: 0xAAAAAA )
  for shape in object
    for sequence in shape
      geometry = new THREE.Geometry()
      for vertex in sequence.vertices
        geometry.vertices.push( vertex )

      geometry.vertices.push( sequence.vertices[0] )

      line = new THREE.Line( geometry, material )
      sceneGraph.add( line )


btnTest1 = ( event ) ->
  event.preventDefault()

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

  drawLines( myObject )


btnTest2 = ( event ) ->
  event.preventDefault()

  edgeSequence1 =
    vertices: [ new THREE.Vector3( -3, -3, 0 )
      new THREE.Vector3(  3, -3, 0 )
      new THREE.Vector3(  3,  3, 0 )
      new THREE.Vector3( -3,  3, 0 )
    ]
    area: null
    hole: null

  edgeSequence2 =
    vertices: [ new THREE.Vector3( -2, -2, 0 )
      new THREE.Vector3( -1, -2, 0 )
      new THREE.Vector3( -1, -0.5, 0 )
      new THREE.Vector3( -2, -0.5, 0 )
    ]
    area: null
    hole: null

  edgeSequence3 =
    vertices: [ new THREE.Vector3( 0, 0, 0 )
      new THREE.Vector3( 2.5, -0.7, 0 )
      new THREE.Vector3( 2.3, 0, 0 )
      new THREE.Vector3( 1, 2, 0 )
      new THREE.Vector3( -1, 1, 0 )
    ]
    area: null
    hole: null

  shape1 = [ edgeSequence1, edgeSequence2, edgeSequence3 ]

  myObject = [ shape1 ]

  drawLines( myObject )


btnTest3 = ( event ) ->
  event.preventDefault()

  edgeSequence1 =
    vertices: [ new THREE.Vector3( -2.7, -2.5, 0.2 )
      new THREE.Vector3(  6, -2.5, -8.5 )
      new THREE.Vector3(  -0.5, 0.7, 1.2 )
    ]
    area: null
    hole: null

  edgeSequence2 =
    vertices: [ new THREE.Vector3( -3, -3, 0 )
      new THREE.Vector3(  9, -3, -12 )
      new THREE.Vector3(  -1, 1, 2 )
    ]
    area: null
    hole: null

  shape1 = [ edgeSequence1, edgeSequence2 ]

  myObject = [ shape1 ]

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
  $('#btnTest1').button().click( btnTest1 )
  $('#btnTest2').button().click( btnTest2 )
  $('#btnTest3').button().click( btnTest3 )
  $('#btnHolify').button().click( btnHolify )

  controls = new OrbitControls( camera, renderer.domElement )
  controls.addEventListener( 'change', render )

  render()
)
