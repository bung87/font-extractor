require! {
  fs
  path
  "fast-glob":glob
}
glob.sync './tests/**/*.ls' .forEach ( file ) ->
  require path.resolve file 
