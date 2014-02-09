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
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.registerTask 'default', ['coffeelint']

