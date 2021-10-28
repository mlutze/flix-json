namespace Main { // TODO rename
  use Option.flatMap;
  pub enum JsonElement {
    case JsonObject(Map[String, JsonElement])
    case JsonArray(List[JsonElement])
    case JsonString(String)
    case JsonNumber(Float)
    case JsonBool(Bool)
    case JsonNull
  }

  type alias ParseMonad[t] = Option[(t, List[Char])]


  def _parse(obj: String): JsonElement = {
    object(String.toList(obj)) |> ???
  }

  def whitespace(in: List[Char]): ParseMonad[Unit] = match in {
    case ' ' :: tail => whitespace(tail)
    case '\t' :: tail => whitespace(tail)
    case '\r' :: tail => whitespace(tail)
    case '\n' :: tail => whitespace(tail)
    case _ => Some(((), in))
  }

  def object(in: List[Char]): ParseMonad[JsonElement] = match in {
    case '{' :: tail =>
      let* (keyVals, tail1) = keyVals(tail);
      let* (_, tail2) = require('}', tail1);
      let map = List.toMap(keyVals);
      Some((JsonObject(map), tail2))
    case _ => None
  }

  def keyVals(in: List[Char]): ParseMonad[List[(String, JsonElement)]] = match in {
    // Case 1: starting a keyval pair
    case '\"' :: _ =>
      let* (key, tail) = string(in);
      let* (_, tail1) = whitespace(tail);
      let* (_, tail2) = require(':', tail1);
      let* (_, tail3) = whitespace(tail2);
      let* (val, tail4) = value(tail3);
      let* (_, tail5) = whitespace(tail4);
      match tail5 {
        case ',' :: tail6 =>
          let* (_, tail7) = whitespace(tail6);
          let* (tailKeyVals, tail8) = keyVals(tail7);
          let list = (key, val) :: tailKeyVals;
          Some(list, tail8)
        case '}' :: _ =>
          let list = (key, val) :: Nil;
          Some(list, tail5)
        case _ => None
      }
    case _ => ???
  }

  def value(in: List[Char]): ParseMonad[JsonElement] = ???

  def require(char: Char, in: List[Char]): ParseMonad[Unit] = match in {
    case head :: tail if char == head => Some((), tail)
    case _ => None
  }

  def string(in: List[Char]): ParseMonad[String] = {
    let (_, tail) = require('\"', in);
    let (contents, tail2) = stringContents(tail);
    let (_, tail3) = require('\"', tail2);
    let str = List.toString()
  }

  def stringContents(in: List[Char]): ParseMonad[List[Char]] = ???

}