namespace Main { // TODO rename

  /// Each main rule must start with a key character and consume trailing whitespace

  use Option.flatMap;
  pub enum JsonElement with Eq {
    case JsonObject(Map[String, JsonElement])
    case JsonArray(List[JsonElement])
    case JsonString(String)
    case JsonNumber(Float)
    case JsonBool(Bool)
    case JsonNull
  }

  type alias ParseMonad[t] = Option[(t, List[Char])]


  pub def parse(obj: String): Option[JsonElement] = {
    let in = String.toList(obj);
    let* (_, tail) = whitespace(in);
    let* (o, tail1) = object(tail);
    match tail1 {
      case Nil => Some(o)
      case _ :: _ => None
    }
  }

  def whitespace(in: List[Char]): ParseMonad[Unit] = match in {
    case ' ' :: tail => whitespace(tail)
    case '\t' :: tail => whitespace(tail)
    case '\r' :: tail => whitespace(tail)
    case '\n' :: tail => whitespace(tail)
    case _ => Some((), in)
  }

  def object(in: List[Char]): ParseMonad[JsonElement] = match in {
    case '{' :: tail =>
      let* (_, tail1) = whitespace(tail);
      let* (keyVals, tail2) = keyVals(tail1);
      let* (_, tail3) = require('}', tail2);
      let* (_, tail4) = whitespace(tail3);
      let map = List.toMap(keyVals);
      Some(JsonObject(map), tail4)
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

    // Case 2: end of list
    case '}' :: _ => Some(Nil, in)

    // Case 3: anything else is an error
    case _ => None
  }

  def value(in: List[Char]): ParseMonad[JsonElement] = match in {
    case '{' :: _ => object(in)
    case '\"' :: _ => stringValue(in)
    case 't' :: 'r' :: 'u' :: 'e' :: tail => Some(JsonBool(true), tail)
    case 'f' :: 'a' :: 'l' :: 's' :: 'e' :: tail => Some(JsonBool(false), tail)
    case 'n' :: 'u' :: 'l' :: 'l' :: tail => Some(JsonNull, tail)
    case _ => None
  }

  def require(char: Char, in: List[Char]): ParseMonad[Unit] = match in {
    case head :: tail if char == head => Some((), tail)
    case _ => None
  }

  def stringValue(in: List[Char]): ParseMonad[JsonElement] = {
    let* (str, tail) = string(in);
    Some(JsonString(str), tail)
  }

  def string(in: List[Char]): ParseMonad[String] = {
    let* (_, tail) = require('\"', in);
    let* (contents, tail2) = stringContents(tail);
    let* (_, tail3) = require('\"', tail2);
    let str = listToString(contents);
    Some(str, tail3)
  }

  def listToString(list: List[Char]): String = {
    {
      let sb = StringBuilder.new();
      list |> List.foreach(c -> StringBuilder.appendChar!(sb, c));
      StringBuilder.toString(sb)
    } as & Pure
  }

  def stringContents(in: List[Char]): ParseMonad[List[Char]] = match in {
    case '\"' :: _ => Some(Nil, in)
    // TODO handle escapes
    case c :: tail =>
      let* (rest, tail2) = stringContents(tail);
      Some(c :: rest, tail2)
    // unexpected EOI
    case Nil => None
  }
}