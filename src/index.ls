require!{
  fs
  "iconv-lite":iconv
  "fast-glob":glob
  mkdirp
  path
  "font-carrier":fontCarrier
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
  parsedFontObject = fontCarrier.engine.parse(config.font)
  transFont = new fontCarrier.Font(parsedFontObject.options)
  transFont.setFontface(parsedFontObject.fontface)
  keys = config.preserved.concat textArray .map (key) ->  fontCarrier.helper.normalizeUnicode(key).toLowerCase!
  glyphs = parsedFontObject.glyphs
  for k in keys
    glyph = glyphs[k] if k of glyphs
  # for k, glyph of parsedFontObject.glyphs when k in keys
    tmplGlyph = new fontCarrier.Glyph(glyph)
    tmplGlyph.__font = transFont
    transFont.__glyphs[k] = tmplGlyph

  # transFont = fontCarrier.transfer(config.font)
  # font = fontCarrier.create()
  # gs = transFont.getGlyph(config.preserved.concat textArray)
  # font.setGlyph(gs)

  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
  dur = performance.now() - start
  # Glyph count	38 on mac,glyph size:145 collected size:207
  glyph = Object.keys(transFont.allGlyph()).length
  console.log "glyph size:#{glyph} collected size:#{textArray.length}\n #{textArray} \nextraction takes:#{dur} milliseconds."
    
  