import json
import std/core
import std/text/parse

fun main()
  assert("parses true", "true".json-parse-equals(JSONTrue))
  assert("parses false", "false".json-parse-equals(JSONFalse))
  assert("parses false", "null".json-parse-equals(JSONNull))
  assert("parses empty array", "[]".json-parse-equals(JSONArray([])))
  assert(
    "parses array with number values",
    "[1, 2]".json-parse-equals(JSONArray([JSONNumber(1.0), JSONNumber(2.0)]))
  )
  assert("parses empty object", "{}".json-parse-equals(JSONObject([])))
  assert(
    "parses object with string values",
    "{\"a\":\"b\",\"c\":\"d\"}".json-parse-equals(
      JSONObject([
        ("a", JSONString("b")),
        ("c", JSONString("d"))
      ])
    )
  )
  println("All tests passed")

fun json-parse-equals(s, json)
  s.slice.parse-eof(parse-json).either.maybe.unjust.equals(json)

pub fun equals(x, y) : pure bool
  match (x, y)
    (JSONFalse, JSONFalse) -> True
    (JSONTrue, JSONTrue) -> True
    (JSONNull, JSONNull) -> True
    (JSONNumber(n), JSONNumber(m)) -> n == m
    (JSONString(s), JSONString(ss)) -> s == ss
    (JSONArray(a), JSONArray(aa)) -> a.length == aa.length && a.zip(aa).all(fn((v1, v2)) equals(v1, v2))
    (JSONObject(o), JSONObject(oo)) -> o.zip(oo).all(fn(((k1, v1), (k2, v2))) (k1 == k2) && equals(v1, v2))
    _ -> False
