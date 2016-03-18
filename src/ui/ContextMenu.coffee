Global = require '../Global'

module.exports = class ContextMenu
  
  menu: null
  
  constructor: (actions)->
    @menu = $('<ul/>').css
      display: 'none'
      position: 'absolute'
    .addClass 'action-list'
    .appendTo 'body'
    _this = @ 
    actions.forEach (action)->
      $('<li/>').text action.text
      .click -> action.click.apply _this, []
      .appendTo _this.menu
      
  showAt: (x, y)->
    @menu.show().css
      left: x + 16
      top: y + 16
  
  isParentOf: (elem)->
    return ~~@menu.find(elem).length
  
  remove: ->
    @menu.remove()