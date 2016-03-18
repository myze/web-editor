Global = require '../Global'
Modes = require '../Modes'

PlacePathStop = require '../command/PlacePathStop'
FinishPath = require '../command/FinishPath'
AddSpawnPoint = require '../command/AddSpawnPoint'
AddEscapePoint = require '../command/AddEscapePoint'
AdjustFacingDirection = require '../command/AdjustFacingDirection'
PlaceSign = require '../command/PlaceSign'

module.exports = (map, addX, addY)->
  
  if Global.Mode isnt Modes.INSPECT
    # textures
    for type of map.texture
      continue if not map.texture[type]?
      that = $('#map-settings input#tx' + type)
      that.parent().addClass 'remove'
      text = that.closest('tr').find('th')
      text.html text.html().split('<br>')[0] + "<br>Update texture"
      Global.Config.texture.ground = map.texture[type]
    
    # lighting
    Global.Config.lighting = map.config.lighting
    $('#lighting-level').val Global.Config.lighting
    $('#lightbulb').css 'opacity', Global.Config.lighting * .1
  
  # coordinates
  map.coordinates = map.coordinates.map (stops)->
    stops.map (stop)->
        [stop[0] + addX, stop[1] + addY]
  for group in map.coordinates
    for i of group
      closeToStart = group[0].toString() is group[i].toString()
      if +i is group.length - 1
        ### not close to start, need to create the last dot to finish ###
        ### (for close-at-here, single line) ###
        if group.length >= 2 and not closeToStart
          new (Function.prototype.bind.apply PlacePathStop, [null].concat group[i])
        new FinishPath if group.length > 2 then closeToStart else yes
      else
        new (Function.prototype.bind.apply PlacePathStop, [null].concat group[i])
        
  # signs
  for sign in map.signs
    sign[0] += addX
    sign[1] += addY
    new (Function.prototype.bind.apply PlaceSign, [null].concat sign)
  
  if Global.Mode isnt Modes.INSPECT
    # spawn + facing & escape
    map.config.spawn[0] += addX
    map.config.spawn[1] += addY
    new (Function.prototype.bind.apply AddSpawnPoint, [null].concat map.config.spawn)
    
    if map.config.facing isnt Global.Config.facing
      new AdjustFacingDirection map.config.facing

  if null isnt map.config.escape
    map.config.escape[0] += addX
    map.config.escape[1] += addY
    new (Function.prototype.bind.apply AddEscapePoint, [null].concat map.config.escape)

  ### empty undo / redo stack ###
  Global.UndoStack = []
  Global.RedoStack = []