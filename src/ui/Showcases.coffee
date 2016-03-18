module.exports =
  
  menu: (callback)->
    rect = $('#menu')[0].getBoundingClientRect()
    introShowcase = @newShowcase(
      rect.left + rect.height / 2 + 6,
      rect.top + rect.height / 2 + 2,
      80,
      'Welcome to the Web Editor',
      'You can click the Menu button to expand the menu for all available features.',
      callback
    )
    
  shortcuts: (callback)->
    rect = $('#shortcuts')[0].getBoundingClientRect()
    introShowcase = @newShowcase(
      rect.left + rect.height / 2 + 14,
      rect.top + rect.height / 2,
      60,
      'Quick shortcuts',
      'Here is the some quick accessible shortcuts that help you build the map easier.',
      callback
    )
    
  settings: (callback)->
    rect = $('#menu > ul > li[data-item="ms"]')[0].getBoundingClientRect()
    introShowcase = @newShowcase(
      rect.left + rect.height / 2,
      rect.top + rect.height / 2,
      40,
      'Settings',
      'Customize your map by configuring stuffs here.',
      callback
    )
    
  spawnEscape: (callback)->
    rect = $('#menu > ul > li[data-item="ax"]')[0].getBoundingClientRect()
    introShowcase = @newShowcase(
      rect.left + rect.width + rect.width / 4,
      rect.top + rect.height / 2,
      80,
      'Adding spawn-point and escape-point',
      'Place the player initial spawn-point and the game escape-point.',
      callback
    )
    
  save: (callback)->
    rect = $('#menu > ul > li[data-item="sm"]')[0].getBoundingClientRect()
    introShowcase = @newShowcase(
      rect.left + rect.width / 2,
      rect.top + rect.height / 2,
      40,
      'Save your finished map',
      'Save the map in your account, then login into iOS / Android client to play it.',
      callback
    )
      
  newShowcase: (x, y, r, title, caption, callback)->
    showcase = require 'showcase.js'
    showcase
      .setBackground 'rgba(34,34,34,.75)'
      .setAccentColor '#81D4FA'
      .setRadius r
      .setLocation x, y
      .setTitle title
      .setCaption caption
      .setAction 'OK'
      .setCallback callback
      .build()