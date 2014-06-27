module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    uglify:
      options:
        banner: '/*! <%= pkg.name %>
           <%= grunt.template.today("yyyy-mm-dd") %> */\n'
        sourceMap: true

      umlaut:
        options:
          mangle: false
        files:
          'assets/main.min.js': 'assets/main.js'

      deps:
        files:
          'assets/deps.min.js': [
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/d3/d3.min.js'
            'bower_components/mousetrap/mousetrap.min.js'
            'bower_components/lz-string/libs/lz-string-1.3.3-min.js'
            'bower_components/colpick/js/colpick.js'
          ]

      test:
        files:
          'test/deps.min.js': [
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/d3/d3.min.js'
            'bower_components/mousetrap/mousetrap.min.js'
            'bower_components/qunit/qunit/qunit.js'
          ]

    cssmin:
      options:
        banner: '/*! <%= pkg.name %>
           <%= grunt.template.today("yyyy-mm-dd") %> */\n'

      deps:
        files:
          'assets/deps.min.css': [
            'bower_components/bootstrap/dist/css/bootstrap.min.css'
            'bower_components/colpick/css/colpick.css'
          ]

      test:
        files:
          'test/deps.min.css': [
            'bower_components/qunit/qunit/qunit.css'
          ]

    sass:
      umlaut:
        expand: true
        cwd: 'scss/'
        src: '*.scss'
        dest: 'assets/'
        ext: '.css'

    sass_to_scss:
      umlaut:
        expand: true
        cwd: 'sass/'
        src: '*.sass'
        dest: 'scss/'
        ext: '.scss'

    autoprefixer:
      umlaut:
        files:
          'assets/main.css': 'assets/main.css'

    coffee:
      options:
        sourceMap: true
        bare: true

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

      test:
        files:
          'test/tests.js': 'test/*.coffee'

    coffeelint:
      umlaut: [
        'coffees/**/*.coffee'
        'coffees/*.coffee'
      ]

    connect:
      serve:
        options:
          port: 11111
          base: ''

    qunit:
      test:
        options:
          urls: [
            'http://localhost:11111/test/index.html'
          ]

    watch:
      options:
        livereload: true
      coffee:
        files: [
          'coffees/**/*.coffee'
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
  grunt.loadNpmTasks 'grunt-contrib-qunit'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-autoprefixer'
  grunt.loadNpmTasks 'grunt-sass'
  grunt.loadNpmTasks 'grunt-sass-to-scss'

  grunt.registerTask 'dev', [
    'coffeelint', 'coffee', 'sass_to_scss', 'sass', 'watch']
  grunt.registerTask 'css', ['sass_to_scss', 'sass', 'autoprefixer']
  grunt.registerTask 'default', [
    'coffeelint', 'coffee',
    'sass_to_scss', 'sass',
    'autoprefixer',
    'cssmin',
    'uglify']
  grunt.registerTask 'umlaut', [
    'connect', 'watch'
  ]
  grunt.registerTask 'test', [
    'connect', 'qunit'
  ]
