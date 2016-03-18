Global = require '../Global'
Modes = require '../Modes'
Toast = require '../ui/Toast'
AbsCommand = require './AbsCommand'

module.exports = class SetTexture extends AbsCommand
  
  constructor: (@Type, @Data)-> super()
  
  execute: (alterHistory = no)->
    $.ajax
      url: "#{Editor.endpoint}/texture",
      data:
        data: @Data
      type: 'PUT',
    .done (link)=>
      Global.Config.texture[@Type] = link
      that = $('#map-settings input#tx' + @Type)
      that.parent().addClass 'remove'
      text = $(that).closest('tr').find('th')
      text.html text.html().split('<br>')[0] + '<br>Update texture'
      Toast.text('Texture uploaded successfully').show 2000
      super alterHistory
    .fail ->
      Toast.text('Unable to upload texture').show 2000
  
  undo: ->
    $.ajax
      url: "#{Editor.endpoint}/texture",
      data:
        data: Global.Config.texture[@Type]
      type: 'DELETE',
    .done =>
      Global.Config.texture[@Type] = null
      Toast.text('Texture deleted successfully').show 2000
      super()
    .fail ->
      Toast.text('Unable to delete texture').show 2000
    