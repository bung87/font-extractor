require!{
  "puppeteer-cluster":{Cluster}
  mkdirp
  path
  "./util": { extract }
  "./helper": { compList }
}
importCwd = require('import-cwd')
puppeteer = importCwd('puppeteer')
# about networkidle
# https://github.com/puppeteer/puppeteer/issues/1552

getTextAndHref = (page,url,fontName,scrollElementSelector,timeWait) ->>
  await page.goto(url,waitUntil: 'networkidle2' )
  hasError = false
  if scrollElementSelector
    try 
      do 
        await page.waitFor scrollElementSelector,timeout:timeWait
        await page.$eval scrollElementSelector, (el) !-> 
          el.scrollTo(0, el.scrollHeight,behavior: 'auto')
        handle = await page.$(scrollElementSelector)
        scrollHeight = await page.evaluate( ( (e) -> e.scrollHeight) , handle)
        scrollTop = await page.evaluate( ( (e) -> e.scrollTop), handle)
        clientHeight = await page.evaluate( ( (e) -> e.clientHeight), handle)
      while scrollHeight - scrollTop != clientHeight
    catch e
      hasError = true
      console.info e,url,scrollElementSelector
  handle = new Function("eles","""
  return eles.filter((e)=> window.getComputedStyle(e).getPropertyValue("font-family")
  .split(",").map( (x) => x.trim() )
  .includes('#{fontName}'))
  .reduce( ( (p,c)=> p+= c.textContent ),"" )
  .split("")
  .filter( (v,i,s)=> s.indexOf(v) === i )
  """)
  if scrollElementSelector and !hasError
    await page.waitFor timeWait
  text = await page.$$eval("*",handle)
  hrefs = await page.$$eval("a",(l) -> l.map( (v) -> v.href))
  return [text,hrefs]

reqHandle = (req) ->
  if req.resourceType() == 'image' or req.resourceType() == 'font'
    req.abort()
  else
    req.continue()

getTextTask = ({page,data}) ->>
  await page.setRequestInterception(true)
  page.setDefaultTimeout(6000)
  # page.on('console', (msg) -> console.log('PAGE LOG:', msg.text()) if msg.text().includes("Failed to load resource") == false)
  page.on 'request' reqHandle
  await getTextAndHref(page,data.url,data.fontName,data.scrollElementSelector,data.timeWait)

export collect = (entry,fontName,scrollElement,timeWait,ppages) ->>
  preservedPages = compList(ppages).map((x) -> new URL(x) .toString!) if ppages
  cluster = await Cluster.launch(puppeteer:puppeteer,concurrency: Cluster.CONCURRENCY_CONTEXT,
        maxConcurrency: 4,puppeteerOptions:{args: ['--no-sandbox', '--disable-setuid-sandbox']} )
  await cluster.task getTextTask
  [text,hrefs] = await cluster.execute({url:entry,fontName,scrollElementSelector:scrollElement,timeWait}) 
  console.log hrefs
  hrefs ++= preservedPages if preservedPages
  entryURL = new URL(entry)
  entryNom = entryURL.toString!
  visited = [entryNom]
  pages = []
  filtered = hrefs.filter (x,i,s) -> x.startsWith("http") and s.indexOf(x) == i

  for href in filtered
    url = ""
    try
      url = new URL(href)
    catch
      continue
    urlS = url.toString!
    if visited.indexOf(urlS) == -1 and url.origin == entryURL.origin
      pages.push urlS
  pp = []
  while p = pages.shift!
    pp.push cluster.execute({url:p,fontName,scrollElementSelector:scrollElement,timeWait}) 
    visited.push p
  tt = await Promise.all pp
  for t in tt
    text = text ++ t[0]
  text = text.filter( (v,i,s)-> s.indexOf(v) === i )
  await cluster.idle()
  await cluster.close()
  return text

export extractor = (config) ->>
  textArray = await collect(config.entry,config.fname,config.ss,config.sw,config.pages)
  flat = config.preserved.reduce ((p,c,i) -> p ++ c.split('')),[]
    .filter (value, index, self) -> self.indexOf(value) == index
  words = flat.concat textArray
  console.log "collected size:#{textArray.length}\n #{textArray}"
  transFont = extract(config,words)
  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
