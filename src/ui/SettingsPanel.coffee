Global = require '../Global'
Toast = require './Toast'

SetTexture = require '../command/SetTexture'
AdjustFacingDirection = require '../command/AdjustFacingDirection'

module.exports = ->
  ### setup textures ###
  
  $('.panel > .close').click (e) -> $(@).parent().toggleClass 'show hide'
  $('#map-settings .filechooser').click (e)->
    $this = $(this)
    return if not $this.hasClass 'remove'
    input = $this.find 'input'
    type = input.attr('id').replace /^tx/, ''
    $.ajax
      url: "#{Editor.endpoint}/texture",
      data:
        data: Global.Config.texture[type]
      type: 'DELETE',
    .done =>
      Global.Config.texture[type] = null
      ### reset file input ###
      input.wrap('<form>').parent('form').trigger 'reset'
      input.unwrap()
      ### reset filename ###
      text = $this.closest('tr').find('th')
      text.html text.html().split('<br>')[0] + '<br>(PNG File, 128px × 128px)'
      $this.removeClass 'remove'
      Toast.text('Texture deleted successfully').show 2000
    .fail ->
      Toast.text('Unable to delete texture').show 2000
    
  $('#map-settings input[id^="tx"]').change (e) ->
    if @files.length < 1
      return
    file = @files[0]
    if file.type isnt 'image/png'
      Toast.text('Only PNG texture file supported').show 2500
      return
    type = @id.replace /^tx/, ''
    reader = new FileReader
    reader.onload = (e) ->
      img = new Image
      img.onload = ->
        if img.width isnt img.height or img.width != 128
          Toast.text('Texture must be 128px squared').show 2500
          return
        new SetTexture type, reader.result.replace /.+?,/, ''
      img.src = reader.result
    reader.readAsDataURL file
  
  defaultFacing = $('#facing-direction').val()
  defaultLighting = $('#lighting-level').val()
  $('#facing-direction').blur (e)->
    val = +@value
    if /^\d{1,3}$/.test(@value) and val >= 0 and val < 360
      return if Global.Config.facing is val
      new AdjustFacingDirection val
      @value = val
    else
      Toast.text('Invalid facing direction').show 2000
      @value = defaultFacing
  
  $('#lighting-level').blur (e)->
    val = +@value
    if /^\d{1,2}$/.test(@value) and val >= 1 and val <= 10
      return if Global.Config.lighting is val
      Global.Config.lighting = val
    else
      Toast.text('Invalid lighting level').show 2000
      val = defaultLighting
    @value = val
    $('#lightbulb').css 'opacity', val * .1