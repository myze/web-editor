Global = require '../Global'
Modes = require '../Modes'
Measuring = require '../util/Measuring'

module.exports = (tail, head)->
  line = Global.Paper.path Measuring.GetPath.apply null, arguments
  line.attr
    'stroke': 'rgba(128,128,128,1)'
    'stroke-width': Global.LineSize
    'stroke-linecap': 'round'

  tail.tailOf = line
  head.headOf = line
  line.tailNode = tail
  line.headNode = head
  line.toBack()
  tail.attr
    'fill': 'rgba(0,0,0,0)'
    'stroke': 'rgba(255,255,255,1)'

  Measuring.EnableDrag line
  line
