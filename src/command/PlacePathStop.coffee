Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'

Line = require '../component/Line'
Stop = require '../component/Stop'

module.exports = class PlacePathStop extends AbsCommand
  
  AppendCoord: undefined
  
  constructor: (x, y)->
    @AppendCoord = arguments
    super()

  execute: (alterHistory = no)->
    Global.Mode = Modes.DRAW
    stop = Stop.apply null, @AppendCoord
    Global.WorkingPath.push stop
    ### connects the last 2 stops ###
    if Global.WorkingPath.length > 1
      [tail, head] = Global.WorkingPath.slice -2
      #         tail  head
      #          v     v
      #  ---o----o-----o < last placed
      Line tail, head
    super alterHistory
  
  
  undo: ->
    stop = Global.WorkingPath.pop()
    ### update stored AppendCoord for redo before removal if stop dragged ###
    @AppendCoord = [stop.attrs.cx, stop.attrs.cy]
    if Global.WorkingPath.length > 0
      tailing = stop.headOf.tailNode
      delete tailing.tailOf
      stop.headOf.remove()
      tailing.attr
        'fill': 'rgba(128,222,234,.5)'
        'stroke': 'rgba(128,222,234,1)'
      Global.Mode = Modes.DRAW
    else
      Global.Mode = Modes.NONE
    stop.remove()
    super()