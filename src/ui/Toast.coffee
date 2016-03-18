module.exports = new ->
  
  @_timeout = undefined
  @_toast = null
  @string = null
  
  @text = (string) ->
    @string = string
    @
  
  @show = (duration) ->
    @_toast.remove() if @_toast?
    @_toast = $('<div class="toast"/>').css(
      bottom: '3em'
      height: 0
      position: 'fixed'
      textAlign: 'center'
      width: '100%'
      zIndex: 101).append($('<div/>').html(@string).css(
      background: '#444'
      borderRadius: 8964
      boxShadow: '0 2px 4px rgba(0,0,0,.25)'
      color: '#fff'
      display: 'inline-block'
      padding: '1em 1.5em'
      position: 'relative'
      top: '-6em')).appendTo('body')
    that = @
    if @_timeout
      clearTimeout @_timeout
    @_timeout = setTimeout ->
      that._toast.remove() if that._toast?
      that._toast = null
    , duration
  return