namespace TestParse {
    import java.math.BigDecimal
    use Json/Parse.parse
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
        import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
        parse("{\"key\": 1}") == Some(JsonObject(Map#{"key" => JsonNumber(valueOf(1i64))}))
    }

    @test
    def testSingletonFloat01(): Bool = {
        import static java.math.BigDecimal.valueOf(Float64): BigDecimal \ {};
        parse("{\"key\": 1.0}") == Some(JsonObject(Map#{"key" => JsonNumber(valueOf(1.0))}))
    }
}