Global = require '../Global'
AbsCommand = require './AbsCommand'

module.exports = class AdjustFacingDirection extends AbsCommand

  SavedFacing: undefined
  NewFacing: undefined

  constructor: (value)->
    @NewFacing = value
    super()
  
  execute: (alterHistory = no)->
    @SavedFacing = Global.Config.facing
    @update @NewFacing
    super alterHistory
  
  undo: ->
    @update @SavedFacing
    super()
    
  update: (facing)->
    Global.Config.facing = facing
    $('#facing-direction').val facing
    Global.Spawn.syncArrow() if Global.Spawn?
    Global.UndoStack.pop()