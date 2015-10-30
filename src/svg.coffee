

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
      <!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"
      \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n
      \n
      <svg xmlns=\"http://www.w3.org/2000/svg\"\n
      xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n
      xmlns:ev=\"http://www.w3.org/2001/xml-events\"\n
      version=\"1.1\" baseProfile=\"full\"\n
      width=\"#{@width}mm\" height=\"#{@height}mm\"\n
      viewBox=\"0 0 #{@width} #{@height}\">"]

    text.push '<rect\n
         style="fill:#ddddff;fill-rule:evenodd;
         stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"\n
         id="rect3336"\n
         width="100%"\n
         height="100%"\n
         x="0"\n
         y="0" />
         \n'
    console.log @shapes
    for shape in @shapes
      for edgeLoop in shape.getEdgeLoops()
        text.push '<polygon
          style="fill:none;
          stroke:#ff0000;
          stroke-width:1pt"
          points="'
        for vertex in edgeLoop.vertices
          text.push " #{vertex.x} #{vertex.y}"
        text.push '"/>\n'
    text.push '</svg>'
    blob = new Blob(text, { type: 'text/svg' })
    url = window.URL.createObjectURL(blob, { type: 'text/svg' })
    return url


module.exports = SVG
