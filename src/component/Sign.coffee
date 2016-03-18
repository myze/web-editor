Global = require '../Global'
Measuring = require '../util/Measuring'

module.exports = (appendX, appendY, message)->
  sign = Global.Paper.rect(
    appendX - Global.DotSize
    appendY - Global.DotSize
    Global.DotSize * 2
    Global.DotSize * 2
  )
  sign.attr
    'fill': 'rgba(251,192,45,.5)'
    'stroke': 'rgba(251,192,45,1)'
    'stroke-width': 1
  
  tooltip = $('#tooltip')
  down = no
  showTooltip = ->
    return if down
    [x, y] = [sign.attrs.x + Global.CanvasRect.left, sign.attrs.y + Global.CanvasRect.top]
    ### +1 for stroke width ###
    tooltip.html(message).show().css
      left: x - (tooltip.outerWidth() / 2) + Global.DotSize / 2 + 1
      top: y - (tooltip.outerHeight() / 2) - Global.DotSize * 3 - 1
  
  ### prevent tooltip being shown while dragging ###
  sign.mousedown -> down = yes
  sign.mouseup ->
    down = no
    showTooltip()
  sign.hover showTooltip
  sign.mouseout -> tooltip.hide()
  sign.message = message
  
  Measuring.EnableDrag sign
  sign