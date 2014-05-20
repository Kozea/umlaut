module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    uglify:
      options:
        banner: '/*! <%= pkg.name %>
           <%= grunt.template.today("yyyy-mm-dd") %> */\n'
        sourceMap: true

      umlaut:
        files:
          'assets/main.min.js': 'assets/main.js'

    sass:
      umlaut:
        expand: true
        cwd: 'sass/'
        src: '*.sass'
        dest: 'assets/'
        ext: '.css'

    coffee:
      options:
        sourceMap: true

      umlaut:
        files:
          'assets/main.js': [
            'coffees/utils.coffee'
            'coffees/d3.ext.coffee'
            'coffees/diagrams/base.coffee'
            'coffees/svg/linking.coffee'
            'coffees/diagrams/markers.coffee'
            'coffees/diagrams/elements.coffee'
            'coffees/diagrams/links.coffee'
            'coffees/diagrams/diagram.coffee'
            'coffees/diagrams/commons.coffee'
            'coffees/diagrams/groups.coffee'
            'coffees/diagrams/flowchart.coffee'
            'coffees/diagrams/dot.coffee'
            'coffees/diagrams/usecase.coffee'
            'coffees/diagrams/electric.coffee'
            'coffees/diagrams/class.coffee'
            'coffees/ui/*.coffee'
            'coffees/svg/behavior.coffee'
            'coffees/svg/drawing.coffee'
            'coffees/svg.coffee'
            'coffees/storage/*.coffee'
            'coffees/lang/*.coffee'
            'coffees/init.coffee'
          ]

    coffeelint:
      umlaut:
        'coffees/*.coffee'

    connect:
      serve:
        options:
          port: 11111
          base: ''

    watch:
      options:
        livereload: true
      coffee:
        files: [
          'coffees/*.coffee'
          'Gruntfile.coffee'
        ]
        tasks: ['coffeelint', 'coffee']

      sass:
        files: [
          'sass/*.sass'
        ]
        tasks: ['sass']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-sass'
  grunt.loadNpmTasks 'grunt-sass-to-scss'

  grunt.registerTask 'dev', [
    'coffeelint', 'coffee', 'sass', 'watch']
  grunt.registerTask 'css', ['sass']
  grunt.registerTask 'default', [
    'coffeelint', 'coffee',
    'sass_to_scss', 'sass',
    'uglify']
  grunt.registerTask 'watchserve', [
    'connect', 'watch'
  ]
