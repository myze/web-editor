Global = require '../Global'
Modes = require '../Modes'
Measuring = require '../util/Measuring'

PlacePathStop = require '../command/PlacePathStop'
AddSpawnPoint = require '../command/AddSpawnPoint'
AddEscapePoint = require '../command/AddEscapePoint'
PlaceSign = require '../command/PlaceSign'

### variable for canvas moving ####
_downCoord = [0, 0]
_adjusted = [0, 0]
_moved = [0, 0]
_prevSet = [0, 0]
_set = [0, 0]

_arrowKeyListener = (e)->
  adjustX = switch e.which
    when 37 then -1
    when 39 then 1
    else 0
  adjustY = switch e.which
    when 38 then -1
    when 40 then 1
    else 0
  _adjusted[0] += adjustX
  _adjusted[1] += adjustY
  _set = [
    _adjusted[0] + _moved[0] - Global.CanvasOffset[0]
    _adjusted[1] + _moved[1] - Global.CanvasOffset[1]
  ]
  Measuring.UpdateMoveOffset Global.Paper, _set

savedCursor = undefined

module.exports = ->
  Global.Canvas
  .on 'contextmenu', (e)-> e.preventDefault()
  .on 'mousedown', (e)->
    if e.which is 3 and Global.Mode isnt Modes.MOVING
      Global.SavedMode = Global.Mode
      Global.Mode = Modes.MOVING
      savedCursor = Global.CurrentCursor
      Global.CurrentCursor = 'move'
      _downCoord = [e.clientX, e.clientY]
      ### add event listener for arrow key adjust ###
      dx = Global.CanvasOffset[0] + _prevSet[0]
      dy = Global.CanvasOffset[1] + _prevSet[1]
      _moved = [-_prevSet[0] + dx, -_prevSet[1] + dy]
      _adjusted = [0, 0]
      $(window).on 'keydown', _arrowKeyListener
      Global.Canvas.css 'opacity', .4
    else if e.target.tagName.toLowerCase() is 'svg'
      appendX = Global.CursorLocation[0] - Global.CanvasRect.left + Global.CursorHalfSize
      appendY = Global.CursorLocation[1] - Global.CanvasRect.top + Global.CursorHalfSize
      
      if Global.Mode is Modes.SPAWN and not Global.Spawn?
        ### Place spawn point###
        new AddSpawnPoint appendX, appendY
      else if Global.Mode is Modes.ESCAPE and not Global.Escape?
        ### Place spawn point###
        new AddEscapePoint appendX, appendY
      else if (Global.Mode is Modes.DRAW) or (Global.Mode is Modes.NONE and not Global.WorkingPath.length)
        ### Place path stop ###
        new PlacePathStop appendX, appendY
      else if Global.Mode is Modes.SIGN
        msg = Global.SignMsg
        Global.SignMsg = undefined
        new PlaceSign appendX, appendY, msg
  .on 'mousemove', (e)->
    return if Global.Mode isnt Modes.MOVING
    movedX = e.clientX - _downCoord[0] - _prevSet[0]
    movedY = e.clientY - _downCoord[1] - _prevSet[1]
    _set = [
      movedX - Global.CanvasOffset[0] + _adjusted[0]
      movedY - Global.CanvasOffset[1] + _adjusted[1]
    ]
    Measuring.UpdateMoveOffset Global.Paper, _set
    _moved = [movedX, movedY]
  .on 'mouseup', (e)->
    return if Global.Mode isnt Modes.MOVING
    Global.Mode = Global.SavedMode
    Global.CurrentCursor = savedCursor
    _prevSet = [
      _set[0] - Global.CanvasOffset[0]
      _set[1] - Global.CanvasOffset[1]
    ]
    $(window).off 'keydown', _arrowKeyListener
    Global.Canvas.css 'opacity', 1
