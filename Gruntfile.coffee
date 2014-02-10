module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      app: ['*.coffee', 'routes/*.coffee']
      options:
        arrow_spacing:
          level: 'warn'
        line_endings:
          level: 'warn'
        max_line_length:
          level: 'warn'
        no_empty_param_list:
          level: 'warn'
    mochaTest:
      test:
        options:
          reporter: 'nyan'
          require: 'coffee-script'
        src: ['test/**/*.coffee']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'test', ['coffeelint', 'mochaTest']

