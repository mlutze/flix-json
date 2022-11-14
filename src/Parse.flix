namespace Json/Parse {
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}
    use Json.JsonElement;
    use Option.flatMap;

    // Each main rule must start with a key character and consume trailing whitespace

    type alias ParseMonad[t] = Option[(t, List[Char])]


    ///
    /// Parses the given string into a JSON object.
    /// If the string does not represent an object, None is returned.
    ///
    pub def parse(obj: String): Option[JsonElement] = {
        let in = String.toList(obj);
        let* (_, tail) = whitespace(in);
        let* (o, tail1) = object_(tail);
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

    def object_(in: List[Char]): ParseMonad[JsonElement] = {
        let* (_, tail) = require('{', in);
        let* (_, tail1) = whitespace(tail);
        let* (keyVals, tail2) = keyVals(tail1);
        let* (_, tail3) = require('}', tail2);
        let* (_, tail4) = whitespace(tail3);
        let map = List.toMap(keyVals);
        Some(JsonObject(map), tail4)
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

    def array(in: List[Char]): ParseMonad[JsonElement] = {
        let* (_, tail) = require('[', in);
        let* (_, tail1) = whitespace(tail);
        let* (elems, tail2) = elements(tail1);
        let* (_, tail3) = require(']', tail2);
        Some(JsonArray(elems), tail3)
    }

    def elements(in: List[Char]): ParseMonad[List[JsonElement]] = match in {
        case ']' :: _ => Some(Nil, in)
        case _ =>
            let* (val, tail) = value(in);
            let* (_, tail1) = whitespace(tail);
            match tail1 {
                case ',' :: tail2 =>
                    let* (_, tail3) = whitespace(tail2);
                    let* (rest, tail4) = elements(tail3);
                    let list = val :: rest;
                    Some(list, tail4)
                case ']' :: _ =>
                    let list = val :: Nil;
                    Some(list, tail1)
                case _ => None
            }
    }

    def value(in: List[Char]): ParseMonad[JsonElement] = match in {
        case '{' :: _ => object_(in)
        case '[' :: _ => array(in)
        case '\"' :: _ => stringValue(in)
        case 't' :: 'r' :: 'u' :: 'e' :: tail => Some(JsonBool(true), tail)
        case 'f' :: 'a' :: 'l' :: 's' :: 'e' :: tail => Some(JsonBool(false), tail)
        case 'n' :: 'u' :: 'l' :: 'l' :: tail => Some(JsonNull, tail)
        case _ => number(in)
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

    def listToString(list: List[Char]): String = region r {
            let sb = StringBuilder.new(r);
            list |> List.forEach(c -> StringBuilder.append!(c, sb));
            StringBuilder.toString(sb)
    }

    def stringContents(in: List[Char]): ParseMonad[List[Char]] = match in {
        case '\"' :: _ => Some(Nil, in)

        case '\\' :: '\"' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\"' :: rest, tail2)

        case '\\' :: '\\' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\\' :: rest, tail2)

        case '\\' :: '/' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('/' :: rest, tail2)

        case '\\' :: 'b' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\u0008' :: rest, tail2)

        case '\\' :: 'f' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\u000C' :: rest, tail2)

        case '\\' :: 'n' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\n' :: rest, tail2)

        case '\\' :: 'r' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\r' :: rest, tail2)

        case '\\' :: 't' :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some('\t' :: rest, tail2)

        case '\\' :: 'u' :: c1 :: c2 :: c3 :: c4 :: tail =>
            let* (rest, tail2) = stringContents(tail);
            let string = listToString(c1 :: c2 :: c3 :: c4 :: Nil);
            let* intVal = hexToInt(string);
            let char = Char.fromInt32(intVal);
            Some(char :: rest, tail2)

        case c :: tail =>
            let* (rest, tail2) = stringContents(tail);
            Some(c :: rest, tail2)
        // unexpected EOI
        case Nil => None
    }

    def hexToInt(hex: String): Option[Int32] = {
        import static java.lang.Integer.parseInt(String, Int32): Int32 & Impure;
        try {
            Some(parseInt(hex, 16))
        } catch {
            case _: ##java.lang.NumberFormatException => None
        } as \ {}
    }

    def number(in: List[Char]): ParseMonad[JsonElement] = match in {
        case c :: tail if isNumberChar(c) =>
            let* (chars, tail1) = numberTail(tail);
            let string = listToString(c :: chars);
            let* bigDec = BigDecimal.fromString(string);
            let number = JsonNumber(bigDec);
            Some(number, tail1)
        case _ => None
    }

    def isNumberChar(c: Char): Bool = Char.isDigit(c) or c == '+' or c == '-' or c == 'e' or c == 'E' or c == '.'

    def numberTail(in: List[Char]): ParseMonad[List[Char]] = match in {
        case c :: tail if isNumberChar(c) =>
            let* (chars, tail1) = numberTail(tail);
            Some(c :: chars, tail1)
        case _ => Some(Nil, in)
    }

}