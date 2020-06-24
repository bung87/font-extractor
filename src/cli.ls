#!/usr/bin/env node
require!{
  path
  process
  yargs
  glob
  util
  fs
  "./index":{extractor}
}

argv = yargs.scriptName "font-extractor"
  ..usage "$0 -f test/lib/handfont.ttf -s test/index.html -o test/fonts/handfont.ttf"
  ..option "source",
    alias: "s",
    desc: "source glob pattern"
  ..option "ignore",
    alias: "i"
    desc: "ignore glob pattern"
  ..option "font",
    alias: "f"
    desc: "font file path"
  ..option "preserved",
    alias: "p"
    desc: "preserved words"
    type: "array"
    default: []
  ..option "encoding",
    alias: "e"
    desc: "file encoding"
    type: "string"
    default: "utf-8"
  ..option "output",
    alias: "o"
    desc: "output file path"
  ..config('c', "config file", (configPath) -> 
     JSON.parse fs.readFileSync(configPath, 'utf-8')
  )
  ..coerce(['font', 'output','config'], path.resolve)
#   ..check (argv, options) ->
  ..demandOption(['source', 'font','output'], 'Please provide both run and path arguments to work with this tool')
  ..help!
  ..argv
extractor argv.parsed.argv