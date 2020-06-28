require!{
  "puppeteer-cluster":{Cluster}
  mkdirp
  path
  "./util": { extract }
}
importCwd = require('import-cwd')
puppeteer = importCwd('puppeteer')

getText = (page,url,fontName,scrollElementSelector,timeWait) ->>
  await page.goto(url,waitUntil: 'networkidle2' )
  if scrollElementSelector
    try 
      await page.$eval scrollElementSelector, (e) !-> 
        do 
          e.scrollBy(0, e.scrollHeight,behavior: 'auto')
        while e.scrollHeight - e.scrollTop != e.offsetHeight
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
    try
      await page.waitFor (e) -> 
        e.scrollHeight - e.scrollTop == e.offsetHeight
      ,scrollElementSelector 
  text = await page.$$eval("*",handle)
  return text

reqHandle = (req) ->
  if req.resourceType() == 'image' or req.resourceType() == 'font'
    req.abort()
  else
    req.continue()

getTextTask = ({page,data}) ->>
  await page.setRequestInterception(true)
  page.setDefaultTimeout(6000)
  page.on 'request' reqHandle
  await getText(page,data.url,data.fontName,data.scrollElementSelector,data.timeWait)

export collect = (entry,fontName,scrollElement,timeWait) ->>
  cluster = await Cluster.launch(puppeteer:puppeteer,concurrency: Cluster.CONCURRENCY_CONTEXT,
        maxConcurrency: 4,puppeteerOptions:{args: ['--no-sandbox', '--disable-setuid-sandbox']} )
  await cluster.task getTextTask
  text = await cluster.execute({url:entry,fontName,scrollElementSelector:scrollElement,timeWait}) 
  hrefs = await cluster.execute(entry,({page,data:url}) ->> 
    await page.setRequestInterception(true)
    page.on 'request' reqHandle
    await page.goto(url,waitUntil: 'networkidle2' )
    await page.$$eval("a",(l) -> l.map( (v) -> v.href)))

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
    # text = text ++ await getText(page,p,fontName)
    pp.push cluster.execute({url:p,fontName,scrollElementSelector:scrollElement,timeWait}) 
    visited.push p
  tt = await Promise.all pp
  for t in tt
    text = text ++ t
  text = text.filter( (v,i,s)-> s.indexOf(v) === i )
  console.log text
  await cluster.idle()
  await cluster.close()
  # await page.close()
  # await browser.close()
  return text

export extractor = (config) ->>
  textArray = await collect(config.entry,config.fname,config.ss,config.sw)
  words = config.preserved.concat textArray
  transFont = extract(config,words)
  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
