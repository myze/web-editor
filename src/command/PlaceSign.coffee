Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'

Sign = require '../component/Sign'

module.exports = class PlaceSign extends AbsCommand
  
  AppendCoord: undefined
  Message: undefined
  
  constructor: (x, y, msg)->
    @AppendCoord = [x, y]
    @Message = msg
    super()

  execute: (alterHistory = no)->
    Global.Mode = Global.SavedMode if Global.Mode
    sign = Sign.apply null, @AppendCoord.concat [@Message]
    Global.Signs.push sign
    Global.CurrentCursor = Global.CursorSet.normal
    super alterHistory
  
  
  undo: ->
    sign = Global.Signs.pop()
    sign.remove()
    ### also ensure the tooltip hidden ###
    $('#tooltip').hide()
    Global.Mode = Modes.SIGN
    super()