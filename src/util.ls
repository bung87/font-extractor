require!{
  fs
  "iconv-lite":iconv
  glob
  path
  util
  "function-threads": Thread
}
aglob = util.promisify glob
readFile = util.promisify(fs.readFile)

readText = (file = global.threadData.file, encoding = global.threadData.encoding or "utf-8") ->>
  require!{
    fs
    "iconv-lite":iconv
    util
  }
  readFile = util.promisify(fs.readFile)
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
  

export getAllText = (config = global.threadData) ->>
  options = 
    nodir: true
    matchBase: true
    ignore:["**/*.ttf","**/*.woff","**/*.woff2","**/*.eot","**/*.svg"]
  reduceFile = (p,c,i) ->>
    prev = await p
    prev += await Thread.run readText,{file:c,encoding: config.encoding}
  if typeof! config.source == "String"
    files = await Thread.run ->>
      require!{ glob,util }
      aglob = util.promisify glob
      aglob global.threadData.source,global.threadData.options
    ,{source:config.source,options}
    files.reduce reduceFile,Promise.resolve("")
  else if typeof! config.source == "Object"
    if typeof! config.source.ignore == "Array"
      options.ignore ++ config.source.ignore
    files = await Thread.run ->>
      require!{ glob,util }
      aglob = util.promisify glob
      aglob global.threadData.source,global.threadData.options
    ,{source:config.source.path,options}
    # files = await aglob config.source.path,options
    files.reduce reduceFile,Promise.resolve("")
