module.exports = ->
  tooltip = $('#tooltip')
  $('#menu > ul > li, #actions > ul > li').on 'mouseenter', (e) ->
    rect = @getBoundingClientRect()
    tooltip.html(@getAttribute 'data-title').show().css
      left: rect.left - (tooltip.outerWidth() / 2) + rect.width / 2
      top: rect.top - (tooltip.outerHeight() / 2) - rect.height / 2
  .on 'mouseleave', (e) -> tooltip.hide()