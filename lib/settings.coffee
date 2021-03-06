module.exports =
  init: (state) ->

    self = @

    # SET THEME
    self.setTheme atom.config.get('raischburn-ui.theme'), false

    # ADD COMMANDS TO ATOM
    atom.commands.add 'atom-workspace',
      "raischburn-ui:dark":   => @setTheme('dark')
      "raischburn-ui:darker": => @setTheme('darker')

    # WHEN UI THEME CHANGES
    atom.config.onDidChange 'raischburn-ui.theme', (value) ->
      self.setTheme value.newValue, value.oldValue

  # CHECKS IF A PACKAGE IS LOADED
  isLoaded: (which) ->
    return atom.packages.isPackageLoaded(which)

  # WHEN PACKAGE ACTIVATES
  onActivate: (which, cb) ->
    atom.packages.onDidActivatePackage (pkg) ->
      if pkg.name == which
        cb pkg

  # WHEN PACKAGE DEACTIVATES
  onDeactivate: (which, cb) ->
    atom.packages.onDidDeactivatePackage (pkg) ->
      if pkg.name == which
        cb pkg

  # GET INFO ABOUT OUR PACKAGE
  package: atom.packages.getLoadedPackage('raischburn-ui')

  # DETERMINE IF A SPECIFIC PACKAGE HAS BEEN LOADED
  packageInfo: (which) ->
    return atom.packages.getLoadedPackage which

  # RELOAD WHEN SETTINGS CHANGE
  refresh: ->
    self = @
    self.package.deactivate()
    setImmediate ->
      return self.package.activate()

  # SET THEME
  setTheme: (theme, previous) ->
    if theme == previous
      return null

    self = @
    fs = require('fs')
    pkg = @package
    themeData = '@user-background-color: @color-background-' + theme.toLowerCase() + ';\n'

    # SAVE TO ATOM CONFIG
    atom.config.set 'raischburn-ui.theme', theme

    # CHECK CURRENT THEME FILE
    fs.readFile pkg.path + '/styles/user.less', 'utf8', (err, fileData) ->
      # IF THEME IS DIFFERENT THAN IS USED TO BE
      if fileData != themeData
        # SAVE A NEW USER THEME FILE
        fs.writeFile pkg.path + '/styles/user.less', themeData, (err) ->
          # IF FILE WAS WRITTEN OK
          if !err
            # RELOAD THE VIEW
            self.refresh()
