Global = require '../Global'
AbsCommand = require './AbsCommand'

Measuring = require '../util/Measuring'

module.exports = class NudgeGroup extends AbsCommand
  
  constructor: (@groupId, @dx, @dy)-> super()
  
  execute: (alterHistory = no)->
    conn = Global.Connections[@groupId]
    conn = Object.keys(conn).map (k)-> conn[k]
    Measuring.UpdateMoveOffset conn[0].tailOf.group, [@dx, @dy], no
    super alterHistory
  
  undo: ->
    conn = Global.Connections[@groupId]
    conn = Object.keys(conn).map (k)-> conn[k]
    Measuring.UpdateMoveOffset conn[0].tailOf.group, [-@dx, -@dy], no
    super()