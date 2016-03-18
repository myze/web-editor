Global = require '../Global'
Measuring = require '../util/Measuring'

module.exports = (appendX, appendY, color)->
  spawnArrow = Global.Paper.path 'M 0,0 L 0,0'
  spawnArrow.attr
    'arrow-start': 'classic-wide-long'
    'fill': 'rgba(0,0,0,0)'
    'stroke': color
    'stroke-width': 3
  spawnArrow.isIndicator = yes
  
  arrowSize = spawnArrow.attrs['stroke-width'] * 5
  spawn = Global.Paper.rect appendX - arrowSize / 2, appendY - arrowSize / 2, arrowSize, arrowSize
  spawn.attr
    'fill': 'rgba(0,0,0,0)'
    'stroke-width': 0
  spawn.arrow = spawnArrow
  spawn.syncArrow = (degree = Global.Config.facing)->
    degree = (degree + 90) % 360
    x = @attrs.x + @attrs.width / 2
    y = @attrs.y + @attrs.height / 2
    @arrow.node.style.transform = "translate(#{x}px,#{y}px) rotate(#{degree}deg)"
  spawn.isSpawn = yes
  
  Measuring.EnableDrag spawn
  spawn