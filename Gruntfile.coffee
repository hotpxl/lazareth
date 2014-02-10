module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      test:
        src: ['*.coffee', 'routes/*.coffee']
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
        src: ['test/**/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script'

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'test', ['coffeelint', 'mochaTest']

