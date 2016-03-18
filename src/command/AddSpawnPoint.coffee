Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'

Spawn = require '../component/Spawn'

module.exports = class AddSpawnPoint extends AbsCommand
  
  AppendCoord: undefined
  SavedMode: undefined
  
  constructor: (x, y)->
    @AppendCoord = arguments
    super()
  
  execute: (alterHistory = no)->
    Global.Spawn = Spawn.apply null, [@AppendCoord[0], @AppendCoord[1], '#80deea']
    Global.Spawn.syncArrow()
    Global.Mode = Global.SavedMode
    @SavedCursor = $('body').css 'cursor'
    Global.CurrentCursor = Global.CursorSet.normal
    super alterHistory
    
  undo: ->
    @AppendCoord = [
      Global.Spawn.attrs.x + Global.Spawn.attrs.width / 2
      Global.Spawn.attrs.y + Global.Spawn.attrs.height / 2
    ]
    Global.Spawn.arrow.remove()
    Global.Spawn.remove()
    Global.Spawn = null
    Global.Mode = Modes.SPAWN
    super()