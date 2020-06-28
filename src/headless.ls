require!{
  
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

export collect = (entry,fontName,scrollElement,timeWait) ->>
  browser = await puppeteer.launch( args: ['--no-sandbox', '--disable-setuid-sandbox'])
  page = await browser.newPage()
  await page.setRequestInterception(true)
  page.setDefaultTimeout(6000)
  page.on 'request' (req) ->
    if req.resourceType() == 'image' or req.resourceType() == 'font'
      req.abort()
    else
      req.continue()
  text = await getText(page,entry,fontName,scrollElement,timeWait)
  hrefs = await page.$$eval("a",(l) -> l.map( (v) -> v.href))
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
  while p = pages.shift!
    text = text ++ await getText(page,p,fontName)
    visited.push p
  text = text.filter( (v,i,s)-> s.indexOf(v) === i )
  console.log text
  await page.close()
  await browser.close()
  return text

export extractor = (config) ->>
  textArray = await collect(config.entry,config.fname,config.ss,config.sw)
  words = config.preserved.concat textArray
  transFont = extract(config,words)
  mkdirp.sync(path.dirname(config.output))
  transFont.output path: config.output
