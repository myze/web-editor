Global = require '../Global'
Modes = require '../Modes'

module.exports = Measuring =

  UpdateMoveOffset: (container, distance)->
    if container instanceof Global.Raphael
      Global.CanvasOffset[0] += distance[0]
      Global.CanvasOffset[1] += distance[1]
    container.forEach (el)->
      if el.type is 'circle'
        el.attr
          'cx': el.attrs.cx + distance[0]
          'cy': el.attrs.cy + distance[1]
      else if el.type is 'path' and not el.isIndicator
        newXY1 = [
          el.attrs.path[0][1] + distance[0]
          el.attrs.path[0][2] + distance[1]
        ]
        newXY2 = [
          el.attrs.path[1][1] + distance[0]
          el.attrs.path[1][2] + distance[1]
        ]
        el.attr 'path', "M #{newXY1.join(',')} L #{newXY2.join(',')}"
      else if el.type is 'rect'
        el.attr
          'x': el.attrs.x + distance[0]
          'y': el.attrs.y + distance[1]
        el.syncArrow() if el.isSpawn


  GetPath: (c1, c2)->
    c1xy = [c1.attrs.cx, c1.attrs.cy]
    c2xy = [c2.attrs.cx, c2.attrs.cy]
    "M #{c1xy.join(',')} L #{c2xy.join(',')}"

  EnableDrag: (obj)->
    return if Global.Mode is Modes.INSPECT
    down = no
    savedCursor = Global.CursorSet.normal
    obj.drag (dx, dy, x, y, e)->
      ### ondrag ###
      return if e.button is 2
      # prevent dragging while moving
      return if Global.Mode is Modes.MOVING
      down = yes
      [plusX, plusY] = [dx - (@dx or 0), dy - (@dy or 0)]
      snapCoord =
        x: Global.CursorLocation[0] - Global.CanvasRect.left + Global.CursorHalfSize
        y: Global.CursorLocation[1] - Global.CanvasRect.top + Global.CursorHalfSize
      if @type is 'circle'
        @attr
          'cx': snapCoord.x
          'cy': snapCoord.y
        ### obj is dot and is head ###
        if obj.headOf
          obj.headOf.attr 'path', Measuring.GetPath(obj, obj.headOf.tailNode)
        ### obj is dot and is tail ###
        if obj.tailOf
          obj.tailOf.attr 'path', Measuring.GetPath(obj, obj.tailOf.headNode)
      else if @type is 'rect'
        @attr
          'x': snapCoord.x - @attrs.width / 2
          'y': snapCoord.y - @attrs.height / 2
        @syncArrow() if @isSpawn
      else if @type is 'path' and @group?
        Measuring.UpdateMoveOffset @group, [plusX, plusY], no
      @dx = dx
      @dy = dy
    , ->
      ### onstart ###
      @dx = 0
      @dy = 0
    , (e)->
      ### onend ###
      if @type is 'circle'
        @still = 0 is Math.abs @dx + @dy
      return if e.button is 2
      return if @type isnt 'path' or @type is 'path' and not @group?
      return if 0 is Math.abs @dx + @dy
      # restore dragged offset immediately first
      Measuring.UpdateMoveOffset @group, [-@dx, -@dy], no
      NudgeGroup = require '../command/NudgeGroup'
      new NudgeGroup @group.id, @dx, @dy
    obj.hover ->
      return if @type is 'path' and not @group?
      return if Global.Mode is Modes.MOVING
      savedCursor = Global.CurrentCursor if Global.CurrentCursor isnt 'pointer'
      Global.CurrentCursor = 'pointer'
    obj.mouseout ->
      return if @type is 'path' and not @group?
      return if Global.Mode is Modes.MOVING
      Global.CurrentCursor = savedCursor if not down
    obj.mouseup ->
      down = no