THREE = require 'three'
$ = require 'jquery'
require 'meshlib'

class ShapesFinder
  constructor: ->
    @shapes = []

  sameVec: (vec1, vec2) ->
    vec1.x is vec2.x and vec1.y is vec2.y and vec1.z is vec2.z

  sameEdge: (edge1, edge2) ->
    (@sameVec(edge1[0], edge2[0]) and @sameVec(edge1[1], edge2[1])) or
      (@sameVec(edge1[0], edge2[1]) and @sameVec(edge1[1], edge2[0]))

  haveSameVert: (edge1, edge2) ->
    (@sameVec(edge1[0], edge2[0]) or @sameVec(edge1[1], edge2[1])) or
    (@sameVec(edge1[0], edge2[1]) or @sameVec(edge1[1], edge2[0]))

  getEdges: (faces) ->
    edges = []
    for face in faces
      indexedFace = []
      for i in [0..2]
        j = i + 1
        if j > 2
          j = 0
        edge = [face.vertices[i], face.vertices[j]]
        found = no
        for existingEdge, i in edges.slice()
          if @sameEdge edge, existingEdge
            found = yes
            edges.splice(i, 1)
        if not found
          edges.push edge
    return edges

  mergeTwoEdges: (edge1, edge2) ->
    added = no
    newEdge = edge1
    if @sameVec( edge2[edge2.length - 1], edge1[0] )
      newEdge = edge2
      newEdge = newEdge.concat(edge1[1..])
      added = true
    if not added and @sameVec( edge1[edge1.length - 1], edge2[0] )
      newEdge = newEdge.concat(edge2[1..])
      added = true
    return { newEdge, added }

  mergeEdges: (inEdges) ->
    edges = [inEdges[0]]
    inEdges.splice(0, 1)
    merged = no
    for inEdge in inEdges
      added = no
      for edge, i in edges
        if not added
          addEdge = @mergeTwoEdges edge, inEdge
          edges[i] = addEdge.newEdge
          added = addEdge.added
      if not added
        edges.push inEdge
      else
        merged = yes
    return { edges, merged }

  getEdgeLoops: (edges) ->
    merged = yes
    while merged
      mergeEdges = @mergeEdges edges
      edges = mergeEdges.edges
      merged = mergeEdges.merged
    return edges


  findEdgeLoops: (faces) ->
    edges = @getEdges faces
    edgeLoops = @getEdgeLoops edges
    return edgeLoops

  findShapesFromModel: (model) ->
    shapes = []
    faces = model.model.getFaces()
    shape = @findEdgeLoops faces
    shapes.push shape
    @shapes = shapes
    return shapes

  findShapesFromFaceSets: ( faceSets ) ->
    shapes = []
    for faceSet in faceSets
      shape = @findEdgeLoops faceSet
      shapes.push shape
    @shapes = shapes
    return shapes

  getDrawable: ->
    drawable = new THREE.Object3D()
    for shape, i in @shapes
      switch (i % 6)
        when 0 then lineColor = 0xff0000 #red
        when 1 then lineColor = 0x00ff00 #green
        when 2 then lineColor = 0x0000ff #blue
        when 3 then lineColor = 0xffff00 #yellow
        when 4 then lineColor = 0xff00ff #magenta
        when 5 then lineColor = 0x00ffff #cyan
      for edgeLoop in shape
        material =
          new THREE.LineDashedMaterial(
            { color: lineColor, dashSize: 0.1, gapSize: 0.3 })
        geometry = new THREE.Geometry()
        for vertex in edgeLoop
          v = new THREE.Vector3(vertex.x, vertex.y, vertex.z)
          geometry.vertices.push v
        geometry.computeLineDistances()
        obj = new THREE.Line( geometry, material )
        drawable.add obj
    return drawable


module.exports = ShapesFinder
