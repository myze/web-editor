Global = require '../Global'
Measuring = require '../util/Measuring'

module.exports = (appendX, appendY)->
  escape = Global.Paper.circle appendX, appendY, (Global.DotSize * 1.5 | 0)
  escape.attr
    'fill': 'rgba(240,98,146,.75)'
    'stroke': 'rgba(248,187,208,1)'
    'stroke-width': 1
  
  Measuring.EnableDrag escape
  escape