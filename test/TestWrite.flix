namespace TestWrite {
    namespace Compact {
        import java.math.BigDecimal
        use Json/Write.toCompactString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        @test
        def testEmptyObject01(): Bool = toCompactString(JsonObject(Map#{})) == "{}"

        @test
        def testSingletonString01(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("value")})) == "{\"key\":\"value\"}"

        @test
        def testSingletonString02(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("\t")})) == "{\"key\":\"\\t\"}"

        @test
        def testSingletonString03(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("!")})) == "{\"key\":\"!\"}"

        @test
        def testDoubleString01(): Bool = 
            toCompactString(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})) == "{\"key1\":\"value1\",\"key2\":\"value2\"}"

        @test
        def testSingletonEmptyArray01(): Bool = toCompactString(JsonObject(Map#{"key" => JsonArray(Nil)})) == "{\"key\":[]}"

        @test
        def testSingletonSingletonArray01(): Bool = 
            toCompactString(JsonObject(Map#{"key" => JsonArray(JsonString("value") :: Nil)})) == "{\"key\":[\"value\"]}"

        @test 
        def testSingletonDoubleArray01(): Bool = 
            toCompactString(JsonObject(Map#{"key" => JsonArray(JsonString("v1") :: JsonString("v2") :: Nil)})) == "{\"key\":[\"v1\",\"v2\"]}"

        @test
        def testSingletonInt01(): Bool = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            toCompactString(JsonObject(Map#{"key" => JsonNumber(valueOf(1i64))})) == "{\"key\":1}"
        }

        @test
        def testSingletonFloat01(): Bool = {
            import static java.math.BigDecimal.valueOf(Float64): BigDecimal \ {};
            toCompactString(JsonObject(Map#{"key" => JsonNumber(valueOf(1.0))})) == "{\"key\":1.0}"
        }
    }

    namespace Pretty {
        import java.math.BigDecimal
        use Json/Write.toPrettyString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        @test
        def testEmptyObject01(): Bool = toPrettyString(2, JsonObject(Map#{})) == "{}"

        @test
        def testSingletonString01(): Bool = toPrettyString(2, JsonObject(Map#{"key" => JsonString("value")})) == "{\n  \"key\": \"value\"\n}"

        @test
        def testSingletonString02(): Bool = toPrettyString(2, JsonObject(Map#{"key" => JsonString("\t")})) == "{\n  \"key\": \"\\t\"\n}"

        @test
        def testSingletonString03(): Bool = toPrettyString(2, JsonObject(Map#{"key" => JsonString("!")})) == "{\n  \"key\": \"!\"\n}"

        @test
        def testDoubleString01(): Bool = 
            toPrettyString(2, JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})) == "{\n  \"key1\": \"value1\",\n  \"key2\": \"value2\"\n}"

        @test
        def testSingletonEmptyArray01(): Bool = toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Nil)})) == "{\n  \"key\": []\n}"

        @test
        def testSingletonSingletonArray01(): Bool = 
            toPrettyString(2, JsonObject(Map#{"key" => JsonArray(JsonString("value") :: Nil)})) == "{\n  \"key\": [\n    \"value\"\n  ]\n}"

        @test 
        def testSingletonDoubleArray01(): Bool = 
            toPrettyString(2, JsonObject(Map#{"key" => JsonArray(JsonString("v1") :: JsonString("v2") :: Nil)})) == "{\n  \"key\": [\n    \"v1\",\n    \"v2\"\n  ]\n}"

        @test
        def testSingletonInt01(): Bool = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(valueOf(1i64))})) == "{\n  \"key\": 1\n}"
        }

        @test
        def testSingletonFloat01(): Bool = {
            import static java.math.BigDecimal.valueOf(Float64): BigDecimal \ {};
            toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(valueOf(1.0))})) == "{\n  \"key\": 1.0\n}"
        }
    }
}