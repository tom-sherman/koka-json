module json

import std/text/parse
import std/num/float64
import util

pub type json
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
  val value = parse-json()
  (key, value)

fun json-object()
  json-left-brace()
  whitespace0()
  val kvs = sep-by(json-comma, {
    whitespace0()
    val kv = json-key-value()
    whitespace0()
    kv
  })
  whitespace0()
  json-right-brace()
  JSONObject(kvs)

fun json-array()
  json-left-bracket()
  val values = sep-by(json-comma, {
    whitespace0()
    val value = parse-json()
    whitespace0()
    value
  })
  json-right-bracket()
  JSONArray(values)

pub fun parse-json()
  choose([
    json-null,
    json-true,
    json-false,
    json-number,
    json-string,
    json-object,
    json-array
  ])

pub fun show(json: json) : div string
  match json
    JSONFalse -> "false"
    JSONTrue -> "true"
    JSONNull -> "null"
    JSONString(value) -> "\"" ++ value ++ "\""
    JSONNumber(value) -> value.show
    JSONArray(value) -> value.show-list(show)
    JSONObject(kvs) -> "{" ++ kvs.map(fn((k, v)) "\"" ++ k ++ "\":" ++ show(v)).join(",") ++ "}"

pub val stringify : json -> pure string = show
