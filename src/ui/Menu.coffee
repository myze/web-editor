Global = require '../Global'
Modes = require '../Modes'
Toast = require './Toast'

module.exports = ->
  active = no
  $('header').on 'toggle', ->
    if active
      this.classList.remove 'show'
    else
      this.classList.add 'show'
    active = not active
  .mousedown (e)->
    return if not $(e.target).is '#handle'
    $(@).trigger 'toggle'
  
  $('#map-name').keyup ->
    Global.MapTitle = this.value
  .keydown (e)->
    if this.value.length > 25 and 0 > [8, 46].indexOf e.which
      e.preventDefault()
      return
    el = document.createElement 'div'
    el.innerHTML = this.value + String.fromCharCode e.which
    el.style.font = 'inherit'
    el.style.fontSize = '12pt'
    this.parentNode.appendChild el
    this.style.width = el.clientWidth + 'px'
    this.parentNode.removeChild el
  .trigger 'keydown'
  
  actionMap = {}
  actions = $('header .menu [data-action]')
  actions.each ->
    s = this.getAttribute 'data-shortcut'
    return if s is null
    actionMap[s] = this.getAttribute 'data-action'
  
  cmdDown = no
  shortcuts = Object.keys actionMap
  $(window).keydown (e)->
    if e.which is 91
      cmdDown = yes
      return
    key = (if e.ctrlKey or cmdDown then '+' else '') + e.which
    return if Global.Mode is Modes.MOVING or 0 > shortcuts.indexOf key
    e.preventDefault()
    $('header .menu [data-action="' + actionMap[key] + '"]').click()
  .keyup (e)->
    cmdDown = no if e.which is 91
  
  actions.click ->
    switch this.getAttribute 'data-action'
      when 'undo' then Editor.undo()
      when 'redo' then Editor.redo()
      when 'save' then Editor.uploadMap()
      when 'help' then Editor.startTutorial()
      when 'guides' then Global.Canvas.trigger 'toggleGuides'
      when 'settings' then $('#map-settings').toggleClass 'show hide'
      when 'add-spawn'
        if Global.Spawn?
          Toast.text('Spawn-point added already').show 2000
        else
          Global.SavedMode = Global.Mode
          Global.Mode = Modes.SPAWN
          Toast.text('Click on canvas anywhere to add spawn-point').show 3500
      when 'add-escape'
        if Global.Escape?
          Toast.text('Escape-point added already').show 2000
        else
          Global.SavedMode = Global.Mode
          Global.Mode = Modes.ESCAPE
          Toast.text('Click on canvas anywhere to add escape-point').show 3500
      when 'add-sign'
        msg = prompt('Enter sign message:').replace(/^\s+|\s+$/g, '')
        if msg.length
          Global.SavedMode = Global.Mode
          Global.Mode = Modes.SIGN
          Global.SignMsg = msg
          Toast.text('Click on canvas anywhere to place new sign').show 3500
    $('header').trigger 'toggle'
  