class Util

  @isSameVec: (vector1, vector2) ->
    vector1.x is vector2.x and vector1.y is vector2.y and vector1.z is vector2.z

  @isSameFace: (face1, face2) ->
    @isSameVec(face1.vertices[0], face2.vertices[0]) and
    @isSameVec(face1.vertices[1], face2.vertices[1]) and
    @isSameVec(face1.vertices[2], face2.vertices[2]) and
    @isSameVec(face1.normal, face2.normal)

  @isSameEdge: (edge1, edge2) ->
    @isSameVec(edge1[0], edge2[0]) and @isSameVec(edge1[1], edge2[1]) or
    @isSameVec(edge1[0], edge2[1]) and @isSameVec(edge1[1], edge2[0])


module.exports = Util
