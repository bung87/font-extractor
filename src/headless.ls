require!{
  puppeteer
  mkdirp
  path
  "font-carrier":fontCarrier
}

getText = (page,url,fontName,scrollElementSelector) ->>
  await page.goto(url,waitUntil: 'networkidle2' )
  if scrollElementSelector
    try 
      await page.$eval scrollElementSelector (e) !-> 
        do 
          e.scrollBy(0, e.scrollHeight,behavior: 'auto')
        while e.scrollHeight - e.scrollTop != e.offsetHeight
  handle = new Function("eles","""
  return eles.filter((e)=> window.getComputedStyle(e).getPropertyValue("font-family").includes('#{fontName}')).reduce( ( (p,c)=> p+= c.textContent ),"" ).split("").filter( (v,i,s)=> s.indexOf(v) === i )
  """)
  if scrollElementSelector
    await page.waitFor 100
    try
      await page.waitFor (e) -> 
          e.scrollHeight - e.scrollTop == e.offsetHeight
      ,scrollElementSelector 
  text = await page.$$eval("*",handle)
  return text

export collect = (entry,fontName,scrollElement) ->>
  browser = await puppeteer.launch()
  page = await browser.newPage()
  await page.setRequestInterception(true)
  page.setDefaultTimeout(6000)
  page.on 'request' (req) ->
    if req.resourceType() == 'image' or req.resourceType() == 'font'
      req.abort()
    else
      req.continue()
  text = await getText(page,entry,fontName,scrollElement)
  hrefs = await page.$$eval("a",(l) -> l.map( (v) -> v.href))
  entryURL = new URL(entry)
  entryNom = entryURL.toString!
  visited = [entryNom]
  pages = []
  filtered = hrefs.filter (x) -> x.startsWith("http")
  for href in filtered
    url = new URL(href)
    urlS = url.toString!
    if visited.indexOf(urlS) == -1 and url.origin == entryURL.origin
        pages.push urlS
  while p = pages.shift!
    text = text ++ await getText(page,p,fontName)
    visited.push p
  text = text.filter( (v,i,s)-> s.indexOf(v) === i )#.join("")
  console.log text
  await page.close()
  await browser.close()
  return text

export extractor = (config) ->>
  textArray = await collect(config.entry,config.fname,config.ss)
  transFont = fontCarrier.transfer(config.font)
  font = fontCarrier.create()
  gs = transFont.getGlyph(config.preserved.concat textArray)
  font.setGlyph(gs)
  mkdirp.sync(path.dirname(config.output))
  font.output path: config.output
