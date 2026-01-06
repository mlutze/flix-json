mod TestParse {
    use Json.Parse.parse
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @Test
    def testEmptyObject01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{})), parse("{}"))

    @Test
    def testEmptyObject02(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{})), parse("        {        }        "))

    @Test
    def testSingletonString01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonString("value")})), parse("{\"key\": \"value\"}"))

    @Test
    def testSingletonString02(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonString("\t")})), parse("{\"key\": \"\\t\"}"))

    @Test
    def testSingletonString03(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonString("!")})), parse("{\"key\": \"\\u0021\"}"))

    @Test
    def testDoubleString01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})), parse("{\"key1\": \"value1\", \"key2\": \"value2\"}"))

    @Test
    def testSingletonEmptyArray01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonArray(Vector#{})})), parse("{\"key\": []}"))

    @Test
    def testSingletonSingletonArray01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})})), parse("{\"key\": [\"value\"]}"))

    @Test
    def testSingletonDoubleArray01(): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})})), parse("{\"key\": [\"v1\", \"v2\"]}"))

    @Test
    def testSingletonInt01(): Unit \ Assert = {
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)})), parse("{\"key\": 1}"))
    }

    @Test
    def testSingletonFloat01(): Unit \ Assert = {
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)})), parse("{\"key\": 1.0}"))
    }

    @Test
    def testUnicode01(): Unit \ Assert = {
        Assert.assertEq(expected = Some(JsonObject(Map#{"key" => JsonString("ц")})), parse("{\"key\": \"\\u0446\"}"))
    }

    @Test
    def testEscape01(): Unit \ Assert = {
        Assert.assertEq(expected = None, parse("{\"key\": \"\\a\"}"))
    }

    def parseArrayCmp(str: String, expected: Vector[Json.JsonElement]): Unit \ Assert =
        Assert.assertEq(expected = Some(JsonArray(expected)), parse(str))

    @Test
    def testShortArray(): Unit \ Assert =
        parseArrayCmp("[1, 2, 3]", Vector#{JsonNumber(1ff), JsonNumber(2ff), JsonNumber(3ff)})

    @Test
    def testLongArray(): Unit \ Assert =
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