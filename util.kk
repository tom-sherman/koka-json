module util

import std/text/parse

pub fun sep-by(pDelim : parser<e, b>, p : parser<e, a>) : <parse|e> list<a>
  [p()].append(optional([]) {
    pDelim()
    sep-by(pDelim, p)
  })
