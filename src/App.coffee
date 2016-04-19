Global = require './Global'
Modes = require './Modes'
Toast = require './ui/Toast'

lzs = require 'lz-string'

window.Editor = new class WebEditor
  
  endpoint: 'https://myze.xyz'
  
  constructor: ->
    ### checkpoint for non-webkit browsers ###
    
    chrome = window.chrome and window.chrome.webstore
    opera = window.opera or window.opr
    safari = window.HTMLElement.toString().indexOf('struct') > 0
    
    if not (chrome or opera or safari)
      $('#nowebkit').show()
      return
    
    $('#nowebkit, script').remove() and $('main').show()
    
    ### setup prototype methods ###
    Object.defineProperty Element.prototype, 'centerOnScreen',
      writable: no
      configurable: no
      enumerable: no
      value: (w, h) ->
        @style.left = '50%'
        @style.margin = h / -2 + 'px ' + w / -2 + 'px'
        @style.position = 'absolute'
        @style.top = '50%'
        
    $.fn.insertAt = (index, element)->
      lastIndex = @children().size()
      if index < 0
        index = Math.max(0, lastIndex + 1 + index)
      @append element
      if index < lastIndex
        @children().eq(index).before @children().last()
      @
    
    Global.Paper = new Global.Raphael Global.Canvas[0], screen.width, screen.height
    Global.Paper.canvas.centerOnScreen Global.Paper.width, Global.Paper.height
    
    $(window).on 'resize', ->
      Global.CanvasRect = Global.Paper.canvas.getBoundingClientRect()
    .trigger 'resize'
    
    radius = Global.SnapCursor.innerWidth() / 2
    for cursor of Global.CursorSet
      blob = new Blob [Global.CursorSet[cursor]], { type: 'image/svg+xml' }
      Global.CursorSet[cursor] = 'url(' + URL.createObjectURL(blob) + ') ' + radius + ' ' + radius + ', none'
    Global.CurrentCursor = Global.CursorSet.normal
    
    Global.MapId = window.__map_id
    delete window.__map_id
    
    new Promise (resolve, reject)=>
      if Global.MapId?
        $.get "#{@endpoint}/maps/#{Global.MapId}", (data)->
          resolve JSON.parse lzs.decompressFromUTF16 data
      else resolve null
    .then (data)->
      addX = addY = 0
      if data?
        stringified = JSON.stringify data.coordinates
        maxX = Math.max.apply 0, stringified.match(/\[\d+/g).map (e)-> +e.slice 1
        maxY = Math.max.apply 0, stringified.match(/\d+\]/g).map (e)-> +e.slice 0, -1
        addX = window.innerWidth / 2 - maxX / 2 - Global.CanvasRect.left
        addY = window.innerHeight / 2 - maxY / 2 - Global.CanvasRect.top
      new Promise (resolve, reject)=>
        if not data
          resolve no
        else
          $('#mode-select [data-mode]').click ->
            $(@).closest('#mode-select').remove()
            switch @getAttribute 'data-mode'
              when 'inspect' then resolve yes
              when 'create' then resolve no
      .then (inspect)->
        if not inspect
          ### map editor ###
          require('./ui/SnapCursor')()
          require('./ui/Tooltip')()
          require('./ui/Menu')()
          require('./ui/SettingsPanel')()
          require('./ui/Canvas')()
          if data?
            Global.MapTitle = data.title
            require('./util/MapRestore') data, addX, addY
          else
            Global.MapTitle = 'Untitled'
        else
          Global.Mode = Modes.INSPECT
          require('./util/MapRestore') data, addX, addY
          $('header').remove()
          $('#cursor').remove()
          $('#map-settings').remove()
          $('#shortcuts').remove()
          $('#scale').remove()
          
          socket = require('socket.io-client') 'https://myze.xyz'
          Spawn = require './component/Spawn'
          players = {}
          playerHalfSize = undefined
          socket.on 'sync', (data)->
            console.log data
            data = JSON.parse data.toLowerCase()
            data.players.forEach (p)->
              if not players[p.id]
                players[p.id] = Spawn 0, 0, '#' + p.color.slice 0, 6
                playerHalfSize = players[p.id].attrs.width / 2 if not playerHalfSize
              players[p.id].attr
                'x': +p.position.x - playerHalfSize + addX
                'y': +p.position.z - playerHalfSize + addY
              players[p.id].syncArrow +p.eulerangles.y
        
    #@startTutorial()
    
  startTutorial: ->
    return if Global.Mode is Modes.INSPECT
    ###
    Showcases = require('./ui/Showcases')
    Showcases.menu ->
      @dispose() and Showcases.shortcuts ->
        @dispose() and $('#menu-switch').click() and Showcases.settings ->
          @dispose() and Showcases.spawnEscape ->
            @dispose() and Showcases.save ->
              @dispose() and $('#menu-switch').click()
    ###
    return
  
  undo: ->
    return if Global.Mode is Modes.INSPECT
    if Global.UndoStack.length < 1
      Toast.text('Nothing to undo.').show 1500
    else
      Global.UndoStack[Global.UndoStack.length - 1].undo()
    return
      
  redo: ->
    return if Global.Mode is Modes.INSPECT
    if Global.RedoStack.length < 1
      Toast.text('Nothing to redo.').show 1500
    else
      Global.RedoStack[Global.RedoStack.length - 1].redo()
    return
    
  uploadMap: ->
    return if Global.Mode is Modes.INSPECT
    if not Global.Spawn?
      Toast.text('No spawn-point added').show 2000
      return
    connections = Object.keys(Global.Connections).map (id)-> Global.Connections[id]
    if connections.length < 1
      Toast.text('No path is drawn').show 2000
      return
    Toast.text('Uploading...').show 2500
    coordinates = []
    connections.forEach (stops)->
      temp = []
      stops.forEach (stop)->
        temp.push [
          Math.round(stop.attrs.cx) - Global.CanvasOffset[0]
          Math.round(stop.attrs.cy) - Global.CanvasOffset[1]
        ]
      coordinates.push temp
    
    # coordinates
    stringified = JSON.stringify coordinates
    minX = Math.min.apply 0, stringified.match(/\[\d+/g).map (e)-> +e.slice 1
    minY = Math.min.apply 0, stringified.match(/\d+\]/g).map (e)-> +e.slice 0, -1
    coordinates = coordinates.map (stops)->
      stops.map (stop)->
          [stop[0] - minX, stop[1] - minY]
    # spawn
    spawnXY = [
      Math.round(Global.Spawn.attrs.x + Global.Spawn.attrs.width / 2) - Global.CanvasOffset[0] - minX
      Math.round(Global.Spawn.attrs.y + Global.Spawn.attrs.height / 2) - Global.CanvasOffset[1] - minY
    ]
    # escape
    escapeXY = if not Global.Escape? then null else [
      Math.round(Global.Escape.attrs.cx) - Global.CanvasOffset[0] - minX
      Math.round(Global.Escape.attrs.cy) - Global.CanvasOffset[1] - minY
    ]
    # signs
    signs = []
    Global.Signs.forEach (sign)->
      x = Math.round(sign.attrs.x + sign.attrs.width / 2) - Global.CanvasOffset[0] - minX
      y = Math.round(sign.attrs.y + sign.attrs.height / 2) - Global.CanvasOffset[1] - minY
      signs.push [x, y, sign.message]
    
    data = lzs.compressToUTF16 JSON.stringify 
      title: Global.MapTitle
      config:
        lighting: Global.Config.lighting
        spawn: spawnXY
        escape: escapeXY
        facing: Global.Config.facing
      texture: Global.Config.texture
      coordinates: coordinates
      signs: signs
      timestamp: +new Date
    
    ep = if Global.MapId? then "/#{Global.MapId}" else ''
    $.post "#{@endpoint}/maps#{ep}", { data: data }, (id)->
      if not id.length
        Toast.text('Unable to save map').show 2000
      else
        if location.host is 'myze.xyz'
          history.replaceState {}, document.title, "/editor?id=#{id}"
        Global.MapId = id
        Toast.text('Map uploaded successfully').show 2500