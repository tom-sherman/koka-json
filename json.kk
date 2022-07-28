import std/text/parse
import std/num/float64

type json
  JSONFalse
  JSONTrue
  JSONNull
  JSONNumber(value: float64)
  JSONString(value: string)
  JSONArray(value: list<json>)
  JSONObject(value: list<(string, json)>)

// First let's define some punctuation parsers
fun json-comma()
  pstring(",")

fun json-colon()
  pstring(":")

fun json-left-bracket()
  pstring("[")

fun json-right-bracket()
  pstring("]")

fun json-left-brace()
  pstring("{")

fun json-right-brace()
  pstring("}")

fun json-quote()
  pstring("\"")

// Now for the good parts
fun json-null()
  pstring("null")
  JSONNull

fun json-true()
  pstring("true")
  JSONTrue

fun json-false()
  pstring("false")
  JSONFalse

fun json-number()
  val s = digits() ++ (optional("") { pstring(".") ++ digits() })
  JSONNumber(s.parse-float64.default(0.0))

// TODO: Support escaping
fun json-string()
  json-quote()
  val s = chars-are("", fn(c) c != '"')
  json-quote()
  JSONString(s.string)

fun json-key-value()
  val key = match json-string()
    JSONString(value) -> value
    _ -> fail("key must be a string")

  whitespace0()
  json-colon()
  whitespace0()
  val value = json-parse()
  (key, value)

// FIXME: Currently _requires_ trailing commas
fun json-object()
  json-left-brace()
  whitespace0()
  val kvs = many({
    whitespace0()
    val kv = json-key-value()
    whitespace0()
    json-comma()
    kv
  })
  whitespace0()
  json-right-brace()
  JSONObject(kvs)

fun json-array()
  json-left-bracket()
  whitespace0()
  val values = many({
    whitespace0()
    val value = json-parse()
    whitespace0()
    json-comma()
    value
  })
  whitespace0()
  json-right-bracket()
  JSONArray(values)

fun json-parse()
  choose([
    json-null,
    json-true,
    json-false,
    json-number,
    json-string,
    json-object,
    json-array
  ])

fun show-json(json: json) : <div|_e> string
  match json
    JSONFalse -> "false"
    JSONTrue -> "true"
    JSONNull -> "null"
    JSONString(value) -> "\"" ++ value ++ "\""
    JSONNumber(value) -> value.show-fixed
    JSONArray(value) -> value.show-list(show-json)
    JSONObject(kvs) -> "{" ++ kvs.map(fn((k, v)) "\"" ++ k ++ "\":" ++ show-json(v)).join(",") ++ "}"


fun test(s)
  match s.slice.parse-eof({ json-parse() }).either
    Left(e) -> "Left(" ++ e.show ++ ")"
    Right(v) -> "Right(" ++ v.show-json ++ ")"
