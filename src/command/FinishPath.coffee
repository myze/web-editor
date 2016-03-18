Global = require '../Global'
Modes = require '../Modes'
AbsCommand = require './AbsCommand'
DeleteGroup = require '../command/DeleteGroup'

ContextMenu = require '../ui/ContextMenu'
Line = require '../component/Line'

module.exports = class FinishPath extends AbsCommand
  
  # static context menu, only one menu displayed simultaneously
  @ContextMenu: null
  
  FinishId: undefined
  WorkingPath: undefined
  LineAdded: null
  GroupHandler: null

  constructor: (@CloseToStart = no)->
    @FinishId = +new Date
    super()

  execute: (alterHistory = no)->
    @WorkingPath = Global.WorkingPath
    if @CloseToStart and @WorkingPath.length > 2
      ### close to start ###
      tail = @WorkingPath[@WorkingPath.length - 1]
      head = @WorkingPath[0]
      @LineAdded = Line tail, head
    else
      ### close here ###
      head = @WorkingPath[@WorkingPath.length - 1]
      head.attr
        'fill': 'rgba(0,0,0,0)'
        'stroke': 'rgba(255,255,255,1)'

    connection = []
    group = Global.Paper.set()
    group.id = @FinishId
    @WorkingPath.forEach (stop)=>
      connection.push stop
      group.push stop
      if stop.tailOf
        group.push stop.tailOf
        stop.tailOf.group = group
    # add first stop to close the path
    connection.push @WorkingPath[0] if @WorkingPath.length > 2 and @CloseToStart
    Global.Connections[@FinishId] = connection
    
    # add right click menu for group
    if Global.Mode isnt Modes.INSPECT
      @GroupHandler = (e, x, y)=>
        return if e.button isnt 2
        e.preventDefault()
        e.stopPropagation()
        if not FinishPath.ContextMenu?
          # if no menu created, create one
          FinishPath.ContextMenu = new ContextMenu [{
            text: 'Delete group'
            click: =>
              new DeleteGroup @FinishId
              @removeContextMenu()
          }]
        # show the menu at the clicked location
        FinishPath.ContextMenu.showAt x, y
      $(window).off('.context').on 'mousedown.context', (e)=>
        return if not FinishPath.ContextMenu
        return if FinishPath.ContextMenu.isParentOf e.target
        @removeContextMenu()
      group.mousedown @GroupHandler
      
    Global.WorkingPath = []
    Global.Mode = Modes.NONE
    super alterHistory

  removeContextMenu: ->
    if FinishPath.ContextMenu?
      FinishPath.ContextMenu.remove()
      FinishPath.ContextMenu = null

  undo: ->
    ### remove context menu ###
    @WorkingPath[0].tailOf.group.unmousedown @GroupHandler
    @GroupHandler = null
    @removeContextMenu()
    
    ### remove the group ###
    @WorkingPath.forEach (stop)=>
      delete stop.tailOf.group if stop.tailOf?

    ### delete the closed path ###
    @LineAdded.remove() if @LineAdded?

    ###  revert changes to first and last   ###
    ###   tail (0)            head (n)      ###
    ###       v                   v         ###
    ###  (---)o---o----o----o-----o(---)    ###
    ###    ^                         ^      ###
    ###  tail.headOf            head.tailOf ###
    tail = @WorkingPath[0]
    head = @WorkingPath[@WorkingPath.length - 1]
    delete head.tailOf
    delete tail.headOf
    head.attr
      'fill': 'rgba(128,222,234,.5)'
      'stroke': 'rgba(128,222,234,1)'

    for lastProperty of Global.Connections then 0
    delete Global.Connections[lastProperty]
    Global.WorkingPath = @WorkingPath
    Global.Mode = Modes.DRAW
    super()