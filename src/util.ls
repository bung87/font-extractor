require!{
  "font-carrier":fontCarrier
}

export extract = (config,textArray) ->
  parsedFontObject = fontCarrier.engine.parse(config.font)
  transFont = new fontCarrier.Font(parsedFontObject.options)
  transFont.setFontface(parsedFontObject.fontface)
  keys = config.preserved.concat textArray .map (key) ->  fontCarrier.helper.normalizeUnicode(key).toLowerCase!
  glyphs = parsedFontObject.glyphs
  for k in keys when k of glyphs
    glyph = glyphs[k]
    tmplGlyph = new fontCarrier.Glyph(glyph)
    tmplGlyph.__font = transFont
    transFont.setGlyph k,tmplGlyph
  return transFont