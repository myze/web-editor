Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'

Escape = require '../component/Escape'

module.exports = class AddEscapePoint extends AbsCommand
  
  AppendCoord: undefined
  
  constructor: (x, y)->
    @AppendCoord = arguments
    super()
  
  execute: (alterHistory = no)->
    Global.Escape = Escape.apply null, @AppendCoord
    Global.Mode = Global.SavedMode
    Global.CurrentCursor = Global.CursorSet.normal
    super alterHistory
  
  undo: ->
    @AppendCoord = [Global.Escape.attrs.cx, Global.Escape.attrs.cy]
    Global.Escape.remove()
    Global.Escape = null
    Global.Mode = Modes.ESCAPE
    super()