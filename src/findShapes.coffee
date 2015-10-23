THREE = require 'three'
$ = require 'jquery'
require 'meshlib'

ShapesFinder =

  sameVec: (vec1, vec2) ->
    vec1.x is vec2.x and vec1.y is vec2.y and vec1.z is vec2.z

  sameEdge: (edge1, edge2) ->
    (@sameVec(edge1[0], edge2[0]) and @sameVec(edge1[1], edge2[1])) or
      (@sameVec(edge1[0], edge2[1]) and @sameVec(edge1[1], edge2[0]))

  haveSameVert: (edge1, edge2) ->
    (@sameVec(edge1[0], edge2[0]) or @sameVec(edge1[1], edge2[1])) or
    (@sameVec(edge1[0], edge2[1]) or @sameVec(edge1[1], edge2[0]))

  getBoundaryEdges: (model) ->
    edges = []
    borderEdge = []
    for face in model.model.getFaces()
      indexedFace = []
      for i in [0..2]
        #console.log 'edge'
        j = i + 1
        if j > 2
          j = 0
        edge = [face.vertices[i], face.vertices[j]]
        found = no
        edgesCopy = edges.slice()
        i = 0
        while i < edges.length
          existingEdge = edges[i]
          if ShapesFinder.sameEdge edge, existingEdge
            #console.log 'same edge'
            found = yes
            edges.splice(i, 1)
          i++
        # for existingEdge, i in edgesCopy
        #   if ShapesFinder.sameEdge edge, existingEdge
        #     #console.log 'same edge'
        #     found = yes
        #     edges.splice(i, 1)
        if not found
          edges.push edge
    #result = edges
    #console.log edges
    return edges

  addEdge: (shape, edge) ->
    added = no
    newShape = shape
    if @sameVec edge[1], shape[0]
      newShape = [edge[0]]
      newShape = newShape.concat(shape)
      added = true
    if not added and @sameVec shape[shape.length - 1], edge[0]
      newShape = newShape.concat([edge[1]])
      added = true
    return { newShape, added }

  addShape: (shape1, shape2) ->
    added = no
    newShape = shape1
    if @sameVec( shape2[shape2.length - 1], shape1[0] )
      newShape = shape2
      newShape = newShape.concat(shape1[1..])
      console.log 's2 s1'
      console.log shape2
      console.log shape1
      console.log newShape
      added = true
    if not added and @sameVec( shape1[shape1.length - 1], shape2[0] )
      newShape = shape1
      newShape = newShape.concat(shape2[1..])
      console.log 's1 s2'
      console.log shape1
      console.log shape2
      console.log newShape
      added = true
    if not added
      console.log 'not added'
    return { newShape, added }

  mergeShapes: (inShapes) ->
    shapes = [inShapes[0]]
    inShapes.splice(0, 1)
    for inShape in inShapes
      added = no
      for shape, i in shapes
        if not added
          addShape = @addShape shape, inShape
          shapes[i] = addShape.newShape
          added = addShape.added
      if not added
        shapes.push [inShape[0], inShape[1]]
    return shapes

  getShapes: (boundaryEdges) ->
    shapes = @mergeShapes boundaryEdges
    console.log shapes
    #debugger
    # shapes = [[boundaryEdges[0][0], boundaryEdges[0][1]]]
    # boundaryEdges.splice(0, 1)
    # for edge in boundaryEdges
    #   added = no
    #   for shape, i in shapes
    #     if not added
    #       addEdge = @addEdge shape, edge
    #       shapes[i] = addEdge.newShape
    #       added = addEdge.added
    #   if not added
    #     shapes.push [edge[0], edge[1]]
    return shapes


  findShapes: (model) ->
    boundaryEdges = @getBoundaryEdges model
    console.log boundaryEdges
    shapes = @getShapes boundaryEdges.slice()
    console.log shapes
    return shapes
    #debugger
    #shapes = @getShapes(boundaryEdges)
    #console.log shapes

  randomNum: ( max, min = 0 ) ->
    return Math.floor(Math.random() * (max - min) + min)

  getShapesOjects: (model, scene) ->
    while (scene.children.length > 0)
      scene.remove scene.children[0]
    objects3d = []
    shapes = @findShapes model
    for shape, i in shapes
      lineColor = @randomNum(0xffffff, 0)
      switch (i % 6)
        when 0 then lineColor = 0xff0000 #red
        when 1 then lineColor = 0x00ff00 #green
        when 2 then lineColor = 0x0000ff #blue
        when 3 then lineColor = 0xffff00 #yellow
        when 4 then lineColor = 0xff00ff #magenta
        when 5 then lineColor = 0x00ffff #cyan
      #console.log 'lineColor = ' + lineColor
      material = new THREE.LineBasicMaterial({ color: lineColor })
      geometry = new THREE.Geometry()
      #material.color = 0xffff00
      for vertex in shape
        geometry.vertices.push vertex#edge[0]
        #geometry.vertices.push edge[1]
      obj = new THREE.Line( geometry, material )
      objects3d.push obj
      scene.add( obj )
    return objects3d

module.exports = ShapesFinder
