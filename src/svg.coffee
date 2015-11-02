

class SVG

  constructor: (width, height) ->
    @shapes = []
    @width = width
    @height = height

  addShape: ( shape ) ->
    @shapes.push( shape )

  addShapes: ( shapes ) ->
    @shapes.concat shapes

  getObjectURL: ->
    text = ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
      \t<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"
      \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n
      \n
      \t<svg xmlns=\"http://www.w3.org/2000/svg\"\n
      \t\txmlns:xlink=\"http://www.w3.org/1999/xlink\"\n
      \t\txmlns:ev=\"http://www.w3.org/2001/xml-events\"\n
      \t\tversion=\"1.1\" baseProfile=\"full\"\n
      \t\twidth=\"#{@width}mm\" height=\"#{@height}mm\"\n
      \t\tviewBox=\"0 0 #{@width} #{@height}\">\n"]

    text.push '\t\t\t<rect\n
         \t\t\t\tstyle="fill:#ddddff;fill-rule:evenodd;
         stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"\n
         \t\t\t\tid="rect3336"\n
         \t\t\t\twidth="100%"\n
         \t\t\t\theight="100%"\n
         \t\t\t\tx="0"\n
         \t\t\t\ty="0" />
         \n'
    console.log @shapes
    for shape in @shapes
      text.push '\t\t\t\t<path
        style="fill:none;
        stroke:#ff0000;
        stroke-width:1pt"\n
        \t\t\t\t\td="'
      for edgeLoop in shape.getEdgeLoops()
        text.push 'M '
        for vertex in edgeLoop.vertices
          text.push "#{vertex.x},#{vertex.y} "
        text.push 'z\n\t\t\t\t\t'
      text.push '"/>\n'
    text.push '</svg>'
    blob = new Blob(text, { type: 'text/svg' })
    url = window.URL.createObjectURL(blob, { type: 'text/svg' })
    return url


module.exports = SVG
