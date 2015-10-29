

class SVG

  conructor: ->
    @shapes = []

  addShape: ( shape ) ->
    @shapes.push shape

  addShapes: ( shapes ) ->
    @shapes.concat shapes

  getObjectURL: ->
    text = ['<svg xmlns="http://www.w3.org/2000/svg"\n
xmlns:xlink="http://www.w3.org/1999/xlink"\n
      xmlns:ev="http://www.w3.org/2001/xml-events"\n
      version="1.1" baseProfile="full"\n
      width="800mm" height="600mm"\n
      viewBox="0 0 800 600">\n']
    text.push '</svg>'
    blob = new Blob(text, { type: 'text/svg' })
    url = window.URL.createObjectURL(blob, { type: 'text/svg' })
    return url


module.exports = SVG
