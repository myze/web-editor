Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'

module.exports = class DiscardPath extends AbsCommand

  WorkingPath: undefined
  
  constructor: -> super()
  
  execute: (alterHistory = no)->
    @WorkingPath = Global.WorkingPath
    @WorkingPath.forEach (stop)->
      stop.headOf.hide() if stop.headOf?
      stop.hide()
    Global.WorkingPath = []
    Global.Mode = Modes.NONE
    super alterHistory
  
  undo: ->
    Global.WorkingPath = @WorkingPath
    Global.WorkingPath.forEach (stop)->
      stop.headOf.show() if stop.headOf?
      stop.show()
    Global.Mode = Modes.DRAW
    super()