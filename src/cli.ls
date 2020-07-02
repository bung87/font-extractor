``#!/usr/bin/env node``
require!{
  path
  yargs
  fs
  "./index":{extractor}
}

statical = (yargs) ->
  yargs.option "source",
    alias: "s",
    desc: "source glob pattern"
  .option "ignore",
    alias: "i"
    desc: "ignore glob pattern"
  .option "font",
    alias: "f"
    desc: "font file path"
  .option "preserved",
    alias: "p"
    desc: "preserved words"
    type: "array"
    default: []
  .option "encoding",
    alias: "e"
    desc: "file encoding"
    type: "string"
    default: "utf-8"
  .option "output",
    alias: "o"
    desc: "output file path"
  .config 'c', "config file", (configPath) -> 
    JSON.parse fs.readFileSync(configPath, 'utf-8')
    
  .coerce(['font', 'output','config'], path.resolve)
  .demandOption(['source', 'font','output'], 'Please provide both source,font and output arguments to work with this tool')

headless = (yargs) ->
  yargs.config 'c', "config file", (configPath) -> 
    JSON.parse fs.readFileSync(configPath, 'utf-8')
  .option "entry",
    alias: "e"
    type: "string"
    desc:"entry url"
  .option "output",
    type: "string"
    alias: "o"
    desc: "output file path"
  .option "fontname",
    alias: "fname"
    desc: "font face name"
  .option "scroller",
    type: "string"
    alias: "ss"
    desc: "scroll element selector(querySelector)"
  .option "scrollwait",
    alias: "sw"
    desc: "time wait after scroll(ms)"
    default: 300
    type: "number"
  .option "font",
    type: "string"
    alias: "f"
    desc: "font file path"
  .option "preserved",
    alias: "p"
    desc: "preserved words"
    type: "array"
    default: []
  .option "pages",
    desc: "preserved pages(Array of ls expression)"
    type: "array"
    default: []
  .coerce(['font', 'output','config'], path.resolve)

yargs.scriptName "font-extractor"
  .command "static","collect text from files",statical,(argv) -> extractor argv
  .example "$0 static -f test/lib/handfont.ttf -s test/index.html -o test/fonts/handfont.ttf"
  .command "headless","collect text from website",headless,(argv) -> 
    require!{"./headless":{extractor:headlessExtractor}}
    headlessExtractor argv
  .example "$0 headless -e http://139.198.17.136:8080/book/46 -o ./a.ttf --fname zkkl --ss '.books-wrapper' -f ./src/assets/fonts/站酷快乐体.ttf"
  .help!
  .argv
