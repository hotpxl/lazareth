module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      app:
        src: [
          'bin/**/*.coffee',
          '*.coffee',
          'routes/**/*.coffee',
          'test/**/*.coffee',
          'data/**/*.coffee'
        ]
        options:
          arrow_spacing:
            level: 'error'
          colon_assignment_spacing:
            level: 'error'
            spacing:
              left: 0
              right: 1
          empty_constructor_needs_parens:
            level: 'error'
          line_endings:
            level: 'error'
          max_line_length:
            level: 'warn'
          no_empty_functions:
            level: 'error'
          no_empty_param_list:
            level: 'error'
          no_unnecessary_double_quotes:
            level: 'error'
          no_unnecessary_fat_arrows:
            level: 'error'
          prefer_english_operator:
            level: 'error'
          non_empty_constructor_needs_parens:
            level: 'error'
          space_operators:
            level: 'error'
    mochaTest:
      app:
        src: ['test/**/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          timeout: 60000

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['coffeelint', 'mochaTest']

