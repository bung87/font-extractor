require!{
  livescript:lsc
}

compList = (l) -> l.reduce ((p,c,i) -> p ++ eval lsc.compile c, {+bare} ),[]
export compList
