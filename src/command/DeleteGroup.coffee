Global = require '../Global'
AbsCommand = require './AbsCommand'

module.exports = class DeleteGroup extends AbsCommand
  
  connection: undefined
  
  constructor: (@GroupId)-> super()
  
  execute: (alterHistory = no)->
    @connection = Global.Connections[@GroupId]
    delete Global.Connections[@GroupId]
    @connection[0].tailOf.group.hide()
    super alterHistory
  
  undo: ->
    @connection[0].tailOf.group.show()
    Global.Connections[@GroupId] = @connection
    Global.UndoStack.pop()
    super()