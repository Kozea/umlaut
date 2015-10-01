js_deps = [
  'bower_components/jquery/dist/jquery.min.js'
  'bower_components/d3/d3.min.js'
  'bower_components/mousetrap/mousetrap.min.js'
  'bower_components/lz-string/libs/lz-string.min.js'
  'bower_components/spectrum/spectrum.js'
]

css_deps = [
  'bower_components/bootstrap/dist/css/bootstrap.min.css'
  'bower_components/spectrum/spectrum.css'
]


js_test_deps = [
  'bower_components/jquery/dist/jquery.min.js'
  'bower_components/d3/d3.min.js'
  'bower_components/mousetrap/mousetrap.min.js'
  'bower_components/qunit/qunit/qunit.js'
]

css_test_deps = [
  'bower_components/qunit/qunit/qunit.css'
]

module.exports = (grunt) ->

  require('time-grunt') grunt
  require('load-grunt-tasks') grunt

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    fileExists: js_deps.concat js_test_deps.concat css_deps.concat css_test_deps

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
          'assets/deps.min.js': js_deps

      test:
        files:
          'test/deps.min.js': js_test_deps

    cssmin:
      options:
        banner: '/*! <%= pkg.name %>
           <%= grunt.template.today("yyyy-mm-dd") %> */\n'

      deps:
        files:
          'assets/deps.min.css': css_deps

      test:
        files:
          'test/deps.min.css': css_test_deps

    sass:
      umlaut:
        expand: true
        cwd: 'sass/'
        src: '*.sass'
        dest: 'assets/'
        ext: '.css'

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

  grunt.registerTask 'dev', [
    'coffeelint', 'coffee', 'sass', 'watch']
  grunt.registerTask 'css', ['sass', 'autoprefixer']
  grunt.registerTask 'default', [
    'coffeelint', 'coffee',
    'sass',
    'autoprefixer',
    'cssmin',
    'uglify']
  grunt.registerTask 'umlaut', [
    'connect', 'watch'
  ]
  grunt.registerTask 'test', [
    'connect', 'qunit'
  ]
