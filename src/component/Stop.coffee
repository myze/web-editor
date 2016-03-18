Global = require '../Global'
Modes = require '../Modes'
Toast = require '../ui/Toast'
Measuring = require '../util/Measuring'

DiscardPath = require '../command/DiscardPath'
FinishPath = require '../command/FinishPath'

module.exports = (appendX, appendY)->
  stop = Global.Paper.circle appendX, appendY, Global.DotSize
  if Global.Mode is Modes.INSPECT
    stop.attr
      'stroke-width': 0
  else
    stop.attr
      'fill': 'rgba(128,222,234,.5)'
      'stroke': 'rgba(128,222,234,1)'
      'stroke-width': 2
  
  ### setup stop click listener for closing path ###
  stop.click ->
    # prevent running this function when stop being dragged
    return if not @still
    
    if Global.WorkingPath.length < 2
      Toast.text('Cannot finish path due to no line was drawn').show 3000
      return
    if this is Global.WorkingPath[0]
      ### clicked first stop, close to start ###
      new FinishPath yes
    else if this is Global.WorkingPath[Global.WorkingPath.length - 1]
      ### clicked last stop, close at here ###
      new FinishPath no
  
  $(window).off('.nsstop').on 'keydown.nsstop', (e)->
    return if 0 > [8, 46].indexOf e.which
    return if not Global.WorkingPath.length
    e.preventDefault()
    new DiscardPath
  
  Measuring.EnableDrag stop
  stop