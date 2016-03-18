Global = require '../Global'
Modes = require '../Modes'

module.exports = class AbsCommand

  constructor: ->
    @execute()
    ### new command added, clear redo stack ###
    Global.RedoStack = []
    Global.UndoStack.push @

  execute: (alterHistory = no)->
    if alterHistory
      Global.RedoStack.pop()
      Global.UndoStack.push @
  
  undo: ->
    Global.UndoStack.pop()
    Global.RedoStack.push @
  
  redo: -> @execute yes