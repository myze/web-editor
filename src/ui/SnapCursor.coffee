Global = require '../Global'

module.exports = ->
  
  ####################
  #  reference dots  #
  ####################
  
  gridSize = Global.GridSize
  refRects = []
  xx = Math.ceil(screen.width / gridSize) + 2
  yy = Math.ceil(screen.height / gridSize) + 2
  
  size = [
    xx * gridSize
    yy * gridSize
  ]
  grid = $('<table id="grid"/>').prependTo('main').css
    height: size[1]
    opacity: .6
    width: size[0]
    zIndex: -1
  
  y = 0
  while y < yy
    row = grid.find('tr:eq(' + y + ')')
    
    ### create the row if not exists ###
    if not row.length
      row = $('<tr/>')
      grid.append row
    refRow = []
    
    x = 0
    while x < xx
      ref = $('<td class="ref"/>').css
        height: gridSize
        position: 'relative'
        width: gridSize
      .appendTo row
      refRow.push ref.get(0)
      x++
    refRects.push refRow
    y++

  ### minus one reference dot size ###
  grid.get(0).centerOnScreen size[0] + gridSize, size[1] + gridSize
  
  #####################
  #  snapping cursor  #
  #####################
  
  [firstVisibleRow, firstVisibleCol] = [undefined, undefined]
  
  $(window).on 'resize', ->
    gridRect = $('#grid').get(0).getBoundingClientRect()
    firstVisibleRow = gridRect.top / -Global.GridSize
    firstVisibleCol = gridRect.left / -Global.GridSize
  .trigger 'resize'

  ### init cursor icon ###
  Global.SnapCursor.css
    background: "#{Global.CursorSet.snapped.split(' ')[0]} transparent center no-repeat"
    backgroundSize: '100%'

  showGuides = no
  lineV = $('<i/>').appendTo 'main'
  lineH = $('<i/>').appendTo 'main'
  lineV.add(lineH).css
    background: 'rgba(0, 255, 255, .5)'
    display: 'none'
    left: 0
    position: 'absolute'
    top: 0
    zIndex: -1
  lineV.css
    height: '100%'
    width: 2
  lineH.css
    height: 2
    width: '100%'
  Global.Canvas.on 'toggleGuides', ->
    showGuides = not showGuides
    lineV.add(lineH).toggle()
    # sync guides with cursor
    lineV.css { left: Global.CursorLocation[0] + Global.CursorHalfSize  - 1 }
    lineH.css { top: Global.CursorLocation[1] + Global.CursorHalfSize - 1 }
    $('#scale').toggle()
    

  ### default snap cursor is hidden, but setting false in order to update real cursor ###
  cursorHidden = false
  $(document).mousemove (e) ->
    hoverRow = Math.floor e.pageY / Global.GridSize + firstVisibleRow
    hoverCol = Math.floor e.pageX / Global.GridSize + firstVisibleCol
    rect = refRects[hoverRow][hoverCol].getBoundingClientRect()
    xInGrid = e.pageX - rect.left
    yInGrid = e.pageY - rect.top
    inLT = undefined
    inRT = undefined
    inLB = undefined
    inRB = undefined
    [cursorX, cursorY] = [0, 0]
    
    if e.shiftKey and
      ((inLT = xInGrid <= Global.SnapBuffer and yInGrid <= Global.SnapBuffer) and
        (rect = refRects[hoverRow - 1][hoverCol - 1].getBoundingClientRect()) or
        
      (inRT = xInGrid > Global.GridSize - Global.SnapBuffer and yInGrid <= Global.SnapBuffer) and
        (rect = refRects[hoverRow - 1][hoverCol].getBoundingClientRect()) or
        
      (inLB = xInGrid <= Global.SnapBuffer and yInGrid > Global.GridSize - Global.SnapBuffer) and
        (rect = refRects[hoverRow][hoverCol - 1].getBoundingClientRect()) or
        
      (inRB = xInGrid > Global.GridSize - Global.SNAP_BUFFER and yInGrid > Global.GridSize - Global.SnapBuffer) and
        (rect = refRects[hoverRow][hoverCol].getBoundingClientRect()))
      
      if cursorHidden
        $('body').css 'cursor', 'none'
        Global.SnapCursor.css 'opacity', 1
        cursorHidden = false
      cursorX = rect.left + Global.GridSize - Global.CursorHalfSize | 0
      cursorY = rect.top + Global.GridSize - Global.CursorHalfSize | 0
    else
      cursorNeedUpdate = 0 > Global.CurrentCursor.indexOf $('body').css('cursor').split(',')[0]
      if not cursorHidden or cursorNeedUpdate
        # webkit bug, must refresh to built-in cursor first
        $('body').css 'cursor', 'none'
        $('body').css 'cursor', Global.CurrentCursor
        Global.SnapCursor.css 'opacity', 0
        cursorHidden = true
      cursorX = e.pageX - Global.CursorHalfSize | 0
      cursorY = e.pageY - Global.CursorHalfSize | 0
    
    coordX = cursorX + Global.CursorHalfSize
    coordY = cursorY + Global.CursorHalfSize
    if showGuides
      lineV.css { left: coordX - 1 }
      lineH.css { top: coordY - 1 }
    $('#scale > span').html (
      '&emsp;X: ' + (coordX - Global.CanvasOffset[0]) +
      ' Y: ' + (coordY - Global.CanvasOffset[1])
    )
    Global.CursorLocation = [cursorX, cursorY]
    Global.SnapCursor.css
      left: cursorX
      top: cursorY