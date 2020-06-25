require!{
  fs
  # "iconv-lite":iconv
  glob
  mkdirp
  path
  "font-carrier":fontCarrier
  # util
  'perf_hooks':{ performance }
  "function-threads": Thread
  # "./util":{ getAllText }
}

export extractor = (config) ->>
  start = performance.now()
  textArray = await Thread.run ->> 
    getAllText = require(global.threadData.mp).getAllText
    getAllText(global.threadData.config)
  ,{config,mp:path.join(__dirname,"./util")}
  
  # textArray = await getAllText config
  transFont = fontCarrier.transfer(config.font)
  font = fontCarrier.create()
  gs = transFont.getGlyph(config.preserved.concat textArray)
  font.setGlyph(gs)
  mkdirp.sync(path.dirname(config.output))
  font.output path: config.output
  dur = performance.now() - start
  console.log "collected: #{textArray} \nextraction takes:#{dur} milliseconds."
    
  