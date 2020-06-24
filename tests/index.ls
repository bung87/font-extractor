require! {
  fs
  path
  glob
}
glob.sync './tests/**/*.ls' .forEach ( file ) ->
  require path.resolve file 
