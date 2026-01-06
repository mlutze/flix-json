mod TestParse {
    use Json.Parse.parse
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @Test
    def testEmptyObject01(): Bool = parse("{}") == Some(JsonObject(Map#{}))

    @Test
    def testEmptyObject02(): Bool = parse("        {        }        ") == Some(JsonObject(Map#{}))

    @Test
    def testSingletonString01(): Bool = parse("{\"key\": \"value\"}") == Some(JsonObject(Map#{"key" => JsonString("value")}))

    @Test
    def testSingletonString02(): Bool = parse("{\"key\": \"\\t\"}") == Some(JsonObject(Map#{"key" => JsonString("\t")}))

    @Test
    def testSingletonString03(): Bool = parse("{\"key\": \"\\u0021\"}") == Some(JsonObject(Map#{"key" => JsonString("!")}))

    @Test
    def testDoubleString01(): Bool =
        parse("{\"key1\": \"value1\", \"key2\": \"value2\"}") == Some(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")}))

    @Test
    def testSingletonEmptyArray01(): Bool = parse("{\"key\": []}") == Some(JsonObject(Map#{"key" => JsonArray(Vector#{})}))

    @Test
    def testSingletonSingletonArray01(): Bool =
        parse("{\"key\": [\"value\"]}") == Some(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})}))

    @Test
    def testSingletonDoubleArray01(): Bool =
        parse("{\"key\": [\"v1\", \"v2\"]}") == Some(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})}))

    @Test
    def testSingletonInt01(): Bool = {
        parse("{\"key\": 1}") == Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)}))
    }

    @Test
    def testSingletonFloat01(): Bool = {
        parse("{\"key\": 1.0}") == Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)}))
    }

    @Test
    def testUnicode01(): Bool = {
        parse("{\"key\": \"\\u0446\"}") == Some(JsonObject(Map#{"key" => JsonString("ц")}))
    }

    @Test
    def testEscape01(): Bool = {
        parse("{\"key\": \"\\a\"}") == None
    }

    def parseArrayCmp(str: String, expected: Vector[Json.JsonElement]): Bool =
        parse(str) == Some(JsonArray(expected))

    @Test
    def testShortArray(): Bool =
        parseArrayCmp("[1, 2, 3]", Vector#{JsonNumber(1ff), JsonNumber(2ff), JsonNumber(3ff)})

    @Test
    def testLongArray(): Bool =
        region rc {
            let sb = StringBuilder.empty(rc);
            let lst = MutList.empty(rc);
            StringBuilder.append("[1", sb);
            MutList.push(JsonNumber(1ff), lst);
            let mx = 60000;
            //[1, 2, 3, 4, ... mx-1]  a string 408887 chars long
            def loop(n) =
                if (n >= mx) () else {
                    StringBuilder.append(", ${n}", sb);
                    MutList.push(JsonNumber(Int32.toBigDecimal(n)), lst);
                    loop(n+1)
                };
            loop(2);
            StringBuilder.append("]", sb);
            let txt = StringBuilder.toString(sb);
            parseArrayCmp(txt, MutList.toList(lst) |> List.toVector)
        }
}