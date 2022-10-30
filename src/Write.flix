namespace Json/Write {
    use Json.JsonElement
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}
    use Json/Utils.escape

    ///
    /// Returns the string corresponding to the given JSON object, written without extraneous space.
    ///
    pub def toCompactString(json: JsonElement): String = match json {
        case JsonObject(map) =>
            let contents = map
                |> Map.joinWith((k, v) -> escape(k) + ":" + toCompactString(v), ",");
            "{" + contents + "}"
        case JsonArray(list) =>
            let contents = list |> List.joinWith(toCompactString, ",");
            "[" + contents + "]"
        case JsonString(s) => escape(s)
        case JsonNumber(n) => "${n}"
        case JsonBool(b) => "${b}"
        case JsonNull => "null"
    }

    ///
    /// Returns the string corresponding to the given JSON object, using `tab` spaces for indentation.
    ///
    pub def toPrettyString(tab: Int32, json: JsonElement): String = match json {
        case JsonObject(map) if Map.isEmpty(map) => "{}"
        case JsonObject(map) =>
            let contents = map
                |> Map.joinWith((k, v) -> escape(k) + ": " + toPrettyString(tab, v), ",\n");
            "{\n" + String.indent(tab, contents) + "}"
        case JsonArray(Nil) => "[]"
        case JsonArray(list) =>
            let contents = list |> List.joinWith(toPrettyString(tab), ",\n");
            "[\n" + String.indent(tab, contents) + "]"
        case JsonString(s) => escape(s)
        case JsonNumber(n) => "${n}"
        case JsonBool(b) => "${b}"
        case JsonNull => "null"
    }
}