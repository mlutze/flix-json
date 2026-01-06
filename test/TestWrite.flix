mod TestWrite {
    mod Compact {
        use Json.Write.toCompactString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        @Test
        def testEmptyObject01(): Bool = toCompactString(JsonObject(Map#{})) == "{}"

        @Test
        def testSingletonString01(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("value")})) == "{\"key\":\"value\"}"

        @Test
        def testSingletonString02(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("\t")})) == "{\"key\":\"\\t\"}"

        @Test
        def testSingletonString03(): Bool = toCompactString(JsonObject(Map#{"key" => JsonString("!")})) == "{\"key\":\"!\"}"

        @Test
        def testDoubleString01(): Bool = 
            toCompactString(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})) == "{\"key1\":\"value1\",\"key2\":\"value2\"}"

        @Test
        def testSingletonEmptyArray01(): Bool = toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{})})) == "{\"key\":[]}"

        @Test
        def testSingletonSingletonArray01(): Bool =
            toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})})) == "{\"key\":[\"value\"]}"

        @Test
        def testSingletonDoubleArray01(): Bool =
            toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})})) == "{\"key\":[\"v1\",\"v2\"]}"

        @Test
        def testSingletonInt01(): Bool = {
            toCompactString(JsonObject(Map#{"key" => JsonNumber(Int32.toBigDecimal(1))})) == "{\"key\":1}"
        }

        @Test
        def testSingletonFloat01(): Bool = {
            toCompactString(JsonObject(Map#{"key" => JsonNumber(1.0ff)})) == "{\"key\":1.0}"
        }
    }

    mod Pretty {
        use Json.Write.toPrettyString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        def getLineSeparator(): String \ IO = Env.handle(Env.getLineSeparator)()

        @Test
        def testEmptyObject01(): Bool = toPrettyString(2, JsonObject(Map#{})) == "{}"

        @Test
        def testSingletonString01(): Bool \ IO = toPrettyString(2, JsonObject(Map#{"key" => JsonString("value")})) == String.intercalate(getLineSeparator(), List#{
            "{",
             "  \"key\": \"value\"",
             "}"
        })

        @Test
        def testSingletonString02(): Bool \ IO = toPrettyString(2, JsonObject(Map#{"key" => JsonString("\t")})) == String.intercalate(getLineSeparator(), List#{
            "{",
            "  \"key\": \"\\t\"",
            "}"
        })

        @Test
        def testSingletonString03(): Bool \ IO = toPrettyString(2, JsonObject(Map#{"key" => JsonString("!")})) == String.intercalate(getLineSeparator(), List#{
            "{",
            "  \"key\": \"!\"",
            "}"
        })

        @Test
        def testDoubleString01(): Bool \ IO = 
            toPrettyString(2, JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})) == String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key1\": \"value1\",",
                "  \"key2\": \"value2\"", 
                "}"
            })

        @Test
        def testSingletonEmptyArray01(): Bool \ IO = toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{})})) == String.intercalate(getLineSeparator(), List#{
            "{",
            "  \"key\": []",
            "}"
        })


        @Test
        def testSingletonSingletonArray01(): Bool \ IO =
            toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})})) == String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": [",
                "    \"value\"",
                "  ]",
                "}"
            })

        @Test
        def testSingletonDoubleArray01(): Bool \ IO =
            toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})})) == String.intercalate(getLineSeparator(), List#{
                "{",
                 "  \"key\": [",
                 "    \"v1\",",
                 "    \"v2\"",
                 "  ]",
                 "}"
            })

        @Test
        def testSingletonInt01(): Bool \ IO = {
            toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(Int32.toBigDecimal(1))})) == String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": 1",
                "}"
            })
        }

        @Test
        def testSingletonFloat01(): Bool \ IO = {
            toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(1.0ff)})) == String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": 1.0",
                "}"
            })
        }
    }
}