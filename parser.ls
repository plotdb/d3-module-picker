require! <[fs]>

hash = {}
matcher = /d3-([^.]+)\.v([0-9.]+)\.min\.js/
files = fs.readdir-sync \d3js.org
  .map -> 
    ret = matcher.exec it
    if !ret => return null
    [name,v2] = [ret.1, ret.2]
    text = fs.read-file-sync "d3js.org/#it" .toString!
    ret1 = /var version = "(\d+\.\d+\.\d+)";/.exec text
    ret2 = /Version (\d+\.\d+\.\d+)/.exec text
    ret = [ret1, ret2].filter(->it).0
    if !ret => return [name, v2, v2]
    [name,v2,ret.1]
  .filter -> it
  .map -> 
    v = it.2.split \.
    if v.length < 3 =>
      it.2 += ".0"
      v.push 0
    idx = v.map((d,i)-> d * 10**i ).reduce(((a,b) -> a + b),0)
    {name: it.0, path-ver: it.1, detail-ver: it.2, index: idx}
  .forEach ->
    if !hash[it.name] => hash[it.name] = []
    hash[it.name].push([it.path-ver, it.detail-ver])
    #if !hash[it.0] or hash[it.0].1 < it.2 => hash[it.0] = [it.1, it.2]

for k,v of hash =>
  for item in v =>
    console.log "option(value='d3-#k/#{item.0}/min') d3-#k #{item.0}"

