namespace Json/Utils {

    ///
    /// Converts the given string into a JSON string, including surrounding quotes.
    ///
    pub def escape(s: String): String = {
        let contents = s
            |> String.toList
            |> List.map(char -> Map.getWithDefault(char, "${char}", escapes()))
            |> List.join("");
        "\"" + contents + "\""
    }

    def escapes(): Map[Char, String] = Map.union(specialEscapes(), controlCharacters())

    def specialEscapes(): Map[Char, String] = Map#{
        '\\' => "\\\\",
        '\"' => "\\\""
    }

    /// A mapping from control characters to their JSON representation.
    def controlCharacters(): Map[Char, String] = Map#{
        '\u0000' => "\\u0000",
        '\u0001' => "\\u0001",
        '\u0002' => "\\u0002",
        '\u0003' => "\\u0003",
        '\u0004' => "\\u0004",
        '\u0005' => "\\u0005",
        '\u0006' => "\\u0006",
        '\u0007' => "\\u0007",
        '\u0008' => "\\b",      // backspace
        '\u0009' => "\\t",      // tab
        '\u000A' => "\\n",      // line feed
        '\u000B' => "\\u000B",
        '\u000C' => "\\f",      // form feed
        '\u000D' => "\\r",      // carriage return
        '\u000E' => "\\u000E",
        '\u000F' => "\\u000F",
        '\u0010' => "\\u0010",
        '\u0011' => "\\u0011",
        '\u0012' => "\\u0012",
        '\u0013' => "\\u0013",
        '\u0014' => "\\u0014",
        '\u0015' => "\\u0015",
        '\u0016' => "\\u0016",
        '\u0017' => "\\u0017",
        '\u0018' => "\\u0018",
        '\u0019' => "\\u0019",
        '\u001A' => "\\u001A",
        '\u001B' => "\\u001B",
        '\u001C' => "\\u001C",
        '\u001D' => "\\u001D",
        '\u001E' => "\\u001E",
        '\u001F' => "\\u001F"
    }
}