mod TestParse {
    use Json.Parse.parse
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @test
    def testEmptyObject01(): Bool = parse("{}") == Some(JsonObject(Map#{}))

    @test
    def testEmptyObject02(): Bool = parse("        {        }        ") == Some(JsonObject(Map#{}))

    @test
    def testSingletonString01(): Bool = parse("{\"key\": \"value\"}") == Some(JsonObject(Map#{"key" => JsonString("value")}))

    @test
    def testSingletonString02(): Bool = parse("{\"key\": \"\\t\"}") == Some(JsonObject(Map#{"key" => JsonString("\t")}))

    @test
    def testSingletonString03(): Bool = parse("{\"key\": \"\\u0021\"}") == Some(JsonObject(Map#{"key" => JsonString("!")}))

    @test
    def testDoubleString01(): Bool =
        parse("{\"key1\": \"value1\", \"key2\": \"value2\"}") == Some(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")}))

    @test
    def testSingletonEmptyArray01(): Bool = parse("{\"key\": []}") == Some(JsonObject(Map#{"key" => JsonArray(Nil)}))

    @test
    def testSingletonSingletonArray01(): Bool =
        parse("{\"key\": [\"value\"]}") == Some(JsonObject(Map#{"key" => JsonArray(JsonString("value") :: Nil)}))

    @test
    def testSingletonDoubleArray01(): Bool =
        parse("{\"key\": [\"v1\", \"v2\"]}") == Some(JsonObject(Map#{"key" => JsonArray(JsonString("v1") :: JsonString("v2") :: Nil)}))

    @test
    def testSingletonInt01(): Bool = {
        parse("{\"key\": 1}") == Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)}))
    }

    @test
    def testSingletonFloat01(): Bool = {
        parse("{\"key\": 1.0}") == Some(JsonObject(Map#{"key" => JsonNumber(1.0ff)}))
    }

    @test
    def testUnicode01(): Bool = {
        parse("{\"key\": \"\\u0446\"}") == Some(JsonObject(Map#{"key" => JsonString("ц")}))
    }

    @test
    def testEscape01(): Bool = {
        parse("{\"key\": \"\\a\"}") == None
    }

    def toIntOpt(e:Json.JsonElement): Option[Int32] = match e {
        case JsonNumber(b) => BigDecimal.tryToInt32(b)
        case _ => None
    }

    def parseAndSum(str:String, len:Int32, result:Int32): Bool =
        match parse(str) {
            case Some(JsonArray(bigs)) =>
                let sumIsRight = match bigs |> List.traverse(toIntOpt) {
                    case Some(ints) => List.sum(ints) == result
                    case _ => false
                };
                List.length(bigs)==len and sumIsRight
            case _ => false
        }


    @test
    def testShortArray(): Bool = parseAndSum("[1, 2, 3]", 3, 6)

    @test
    def testLongArray(): Bool =
        region rc {
            let sb = StringBuilder.new(rc);
            StringBuilder.append!("[1", sb);
            let mx = 60000;
            //[1, 2, 3, 4, ... mx-1]  a string 408887 chars long
            def loop(n) =
                if (n >= mx) () else {
                    StringBuilder.append!(", ${n}", sb);
                    loop(n+1)
                };
            loop(2);
            StringBuilder.append!("]", sb);
            let txt = StringBuilder.toString(sb);
            parseAndSum(txt, mx-1, 1799970000)
        }
}