Showcase = require 'showcase.js'

module.exports =
  
  intro: (callback)->
    rect = $('header > #handle')[0].getBoundingClientRect()
    @newShowcase(
      rect.left + rect.height / 2,
      rect.top + rect.height / 2,
      80,
      'Welcome to the Web Editor',
      'You can click the Menu button to expand the Main Menu for all available features.',
      callback)
    
  draw: (callback)->
    @newShowcase(
      null, null, null,
      'Drawing paths',
      'Left click on the canvas anywhere to draw paths.<br><br>' +
        '- Click the first dot placed to close the path.<br>' +
        '- Click the last dot placed to finish the path.<br><br>' +
        'Right click on the path group to delete the paths.<br>',
      callback)
    
  move: (callback)->
    @newShowcase(
      null, null, null,
      'Moving the canvas',
      'Right click and drag to move the canvas, you can press arrow keys while holding the mouse right button in order to fine tuning.',
      callback)
      
  snap: (callback)->
    @newShowcase(
      window.innerWidth - 240,
      240,
      160,
      'Snapping feature',
      'You can snap your mouse cursor to the anchors on the background grids by holding Shift key.',
      callback)
      
  done: (callback)->
    @newShowcase(
      null, null, null,
      'All done!',
      'You can now experience the Web Editor by following the tutorial.<br>' +
        'The tutorial could be opened anytime from the Help tab under Main Menu.',
      callback)
      
  newShowcase: (x, y, r, title, caption, callback)->
    console.log arguments
    showcase = new Showcase
    showcase
      .setBackground 'rgba(34,34,34,.8)'
      .setAccentColor '#81D4FA'
    if x and y and r
      showcase
        .setRadius r
        .setLocation x, y
    showcase
      .setTitle title
      .setCaption caption
      .setAction 'OK'
      .setCallback callback
      .build()