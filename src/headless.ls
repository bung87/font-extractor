require!{
  "puppeteer-cluster":{Cluster}
  mkdirp
  path
  "./util": { extract }
}
importCwd = require('import-cwd')
puppeteer = importCwd('puppeteer')
# about networkidle
# https://github.com/puppeteer/puppeteer/issues/1552

getTextAndHref = (page,url,fontName,scrollElementSelector,timeWait) ->>
  await page.goto(url,waitUntil: 'networkidle2' )
  if scrollElementSelector
    try 
      await page.$eval scrollElementSelector, (e) !-> 
        neq = true
        do 
          e.scrollTo(0, e.scrollHeight,behavior: 'auto')
          neq := e.scrollHeight - e.scrollTop < e.offsetHeight
        while neq
  handle = new Function("eles","""
  return eles.filter((e)=> window.getComputedStyle(e).getPropertyValue("font-family")
  .split(",").map( (x) => x.trim() )
  .includes('#{fontName}'))
  .reduce( ( (p,c)=> p+= c.textContent ),"" )
  .split("")
  .filter( (v,i,s)=> s.indexOf(v) === i )
  """)
  if scrollElementSelector
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
  # page.on('console', (msg) -> console.log('PAGE LOG:', msg.text()))
  page.on 'request' reqHandle
  await getTextAndHref(page,data.url,data.fontName,data.scrollElementSelector,data.timeWait)

export collect = (entry,fontName,scrollElement,timeWait) ->>
  cluster = await Cluster.launch(puppeteer:puppeteer,concurrency: Cluster.CONCURRENCY_CONTEXT,
        maxConcurrency: 4,puppeteerOptions:{args: ['--no-sandbox', '--disable-setuid-sandbox']} )
  await cluster.task getTextTask
  [text,hrefs] = await cluster.execute({url:entry,fontName,scrollElementSelector:scrollElement,timeWait}) 
  entryURL = new URL(entry)
  entryNom = entryURL.toString!
  visited = [entryNom]
  pages = []
  filtered = hrefs.filter (x) -> x.startsWith("http")
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
  textArray = await collect(config.entry,config.fname,config.ss,config.sw)
  words = config.preserved.concat textArray
  console.log "collected size:#{textArray.length}\n #{textArray}"
  transFont = extract(config,words)
  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
