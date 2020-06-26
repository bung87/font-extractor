require!{
  fs
  "iconv-lite":iconv
  "fast-glob":glob
  mkdirp
  path
  "./util":{ extract }
  util
  'perf_hooks':{ performance }
}

readFile = util.promisify(fs.readFile)

readText = (file, encoding = "utf-8") ->>
  encoding = encoding.toLowerCase!
  bin = await readFile file
  if encoding == "utf-8"
    if (bin[0] == 0xEF && bin[1] == 0xBB && bin[2] == 0xBF) 
      bin = bin.slice(3)
    content = bin.toString("utf-8")
  else if encoding == "gbk"
    content = iconv.decode(bin, "gbk")

  content.split("").filter (value, index, self) ->
    #   CJK Unified Ideographs
    self.indexOf(value) == index and value == /[\u4e00-\u9fa5]/
  

getAllText = (config) ->>
  options = 
    nodir: true
    matchBase: true
    ignore:["**/*.ttf","**/*.woff","**/*.woff2","**/*.eot","**/*.svg"]
  reduceFile = (p,c,i) ->>
    prev = await p
    prev ++ await readText(c, config.encoding)
  if typeof! config.source == "String"
    files = await glob config.source,options
    files.reduce reduceFile,Promise.resolve([])
  else if typeof! config.source == "Object"
    if typeof! config.source.ignore == "Array"
      options.ignore ++ config.source.ignore
    files = await glob config.source.path,options
    files.reduce reduceFile,Promise.resolve([])

export extractor = (config) ->>
  start = performance.now()
  textArray = await getAllText(config)
  words = config.preserved.concat textArray
  transFont = extract(config,words)
  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
  dur = performance.now() - start
  glyph = Object.keys(transFont.allGlyph()).length
  console.log "glyph size:#{glyph} collected size:#{words.length}\n #{words} \nextraction takes:#{dur} milliseconds."
    
  