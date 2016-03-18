Modes = require './Modes'

getRing = (color)->
  '<svg xmlns="http://www.w3.org/2000/svg" fill="' + color + '" width="16" height="' +
  '16" viewBox="0 0 24 24"><path d="M12 2C6.49 2 2 6.49 2 12s4.49 10 10 10 10-4.49 1' +
  '0-10S17.51 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm3-8c' +
  '0 1.66-1.34 3-3 3s-3-1.34-3-3 1.34-3 3-3 3 1.34 3 3z"/></svg>'

getPlus = (color)->
  '<svg xmlns="http://www.w3.org/2000/svg" fill="' + color + '" width="16" height="' +
  '16" viewBox="0 0 24 24"><path d="M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z"/></svg>'

Object.defineProperty Function.prototype, 'expose',
  writable: no
  configurable: no
  enumerable: no
  value: (name, prop) ->
    value = getter = setter = null
    if typeof prop is 'object' and prop? and (prop.get or prop.set)
      getter = prop.get if typeof prop.get is 'function'
      setter = prop.set if typeof prop.set is 'function'
    else
      value = prop
    # auto getter / setter
    if not getter?
      getter = -> value
    if not setter?
      setter = (v)-> value = v
    
    Object.defineProperty @prototype, name,
      get: getter
      set: setter
      configurable: no
      enumerable: yes

module.exports = new class Global
  # Read only #
  raphael = window.Raphael.ninja()
  @expose 'Raphael',
    get: -> raphael
  
  # Get / Set #
  @expose 'MapId', null
  
  # Get / Set #
  title = undefined
  @expose 'MapTitle',
    get: -> title
    set: (t)->
      title = t
      $('#map-name').val(title).trigger 'keydown'
  
  # Read only #
  @expose 'Canvas',
    get: -> $('#canvas')
  
  # Get / Set #
  @expose 'CanvasOffset', [0, 0]
  
  # Get / Set #
  @expose 'CanvasRect', undefined
  
  # Read only #
  @expose 'GridSize',
    get: -> 40
    
  # Read only #
  @expose 'DotSize',
    get: -> 5
  
  # Read only #
  @expose 'LineSize',
    get: -> 5
  
  # Read only #
  @expose 'SnapBuffer',
    get: -> 5
  
  # Read only #
  @expose 'SnapCursor',
    get: -> $('#cursor')
  
  # Read only #
  @expose 'CursorHalfSize',
    get: -> @SnapCursor.innerWidth() / 2
  
  # Get / Set #
  @expose 'CursorLocation', [0, 0]
  
  # Get / Set #
  @expose 'CursorSet',
    normal: getRing 'rgba(255,255,255,.8)'
    snapped: getRing '#69F0AE'
    placer: getPlus '#FF8A65'
  
  # Get / Set #
  @expose 'CurrentCursor', undefined
  
  # Get / Set #
  @expose 'WorkingPath', []
  
  # Get / Set #
  @expose 'Connections', {}
  
  # Get / Set #
  @expose 'Signs', []
  
  # Get / Set #
  @expose 'SignMsg', undefined
  
  # Get / Set #
  @expose 'Config',
    lighting: 6
    facing: 0
    texture:
      ground: null
      wall: null
      ceiling: null
  
  # Get / Set #
  mode = Modes.NONE
  @expose 'Mode',
    get: -> mode
    set: (m)->
      return if mode is Modes.INSPECT
      if -1 < [Modes.SPAWN, Modes.ESCAPE, Modes.SIGN].indexOf m
        @CurrentCursor = @CursorSet.placer
      mode = m
  
  # Get / Set #
  savedMode = mode
  @expose 'SavedMode',
    get: -> savedMode
    set: (m)-> savedMode = m
  
  # Get / Set #
  @expose 'Spawn', null
  
  # Get / Set #
  @expose 'Escape', null
  
  # Get / Set #
  @expose 'UndoStack', []
  
  # Get / Set #
  @expose 'RedoStack', []
