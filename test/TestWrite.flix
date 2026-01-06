mod TestWrite {
    mod Compact {
        use Json.Write.toCompactString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        @Test
        def testEmptyObject01(): Unit \ Assert =
            Assert.assertEq(expected = "{}", toCompactString(JsonObject(Map#{})))

        @Test
        def testSingletonString01(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":\"value\"}", toCompactString(JsonObject(Map#{"key" => JsonString("value")})))

        @Test
        def testSingletonString02(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":\"\\t\"}", toCompactString(JsonObject(Map#{"key" => JsonString("\t")})))

        @Test
        def testSingletonString03(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":\"!\"}", toCompactString(JsonObject(Map#{"key" => JsonString("!")})))

        @Test
        def testDoubleString01(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key1\":\"value1\",\"key2\":\"value2\"}", toCompactString(JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})))

        @Test
        def testSingletonEmptyArray01(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":[]}", toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{})})))

        @Test
        def testSingletonSingletonArray01(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":[\"value\"]}", toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})})))

        @Test
        def testSingletonDoubleArray01(): Unit \ Assert =
            Assert.assertEq(expected = "{\"key\":[\"v1\",\"v2\"]}", toCompactString(JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})})))

        @Test
        def testSingletonInt01(): Unit \ Assert = {
            Assert.assertEq(expected = "{\"key\":1}", toCompactString(JsonObject(Map#{"key" => JsonNumber(Int32.toBigDecimal(1))})))
        }

        @Test
        def testSingletonFloat01(): Unit \ Assert = {
            Assert.assertEq(expected = "{\"key\":1.0}", toCompactString(JsonObject(Map#{"key" => JsonNumber(1.0ff)})))
        }
    }

    mod Pretty {
        use Json.Write.toPrettyString
        use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

        def getLineSeparator(): String \ IO = Env.handle(Env.getLineSeparator)()

        @Test
        def testEmptyObject01(): Unit \ Assert =
            Assert.assertEq(expected = "{}", toPrettyString(2, JsonObject(Map#{})))

        @Test
        def testSingletonString01(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                 "  \"key\": \"value\"",
                 "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonString("value")})))

        @Test
        def testSingletonString02(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": \"\\t\"",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonString("\t")})))

        @Test
        def testSingletonString03(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": \"!\"",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonString("!")})))

        @Test
        def testDoubleString01(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key1\": \"value1\",",
                "  \"key2\": \"value2\"",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key1" => JsonString("value1"), "key2" => JsonString("value2")})))

        @Test
        def testSingletonEmptyArray01(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": []",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{})})))


        @Test
        def testSingletonSingletonArray01(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": [",
                "    \"value\"",
                "  ]",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("value")})})))

        @Test
        def testSingletonDoubleArray01(): Unit \ {Assert, IO} =
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                 "  \"key\": [",
                 "    \"v1\",",
                 "    \"v2\"",
                 "  ]",
                 "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonArray(Vector#{JsonString("v1"), JsonString("v2")})})))

        @Test
        def testSingletonInt01(): Unit \ {Assert, IO} = {
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": 1",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(Int32.toBigDecimal(1))})))
        }

        @Test
        def testSingletonFloat01(): Unit \ {Assert, IO} = {
            Assert.assertEq(expected = String.intercalate(getLineSeparator(), List#{
                "{",
                "  \"key\": 1.0",
                "}"
            }), toPrettyString(2, JsonObject(Map#{"key" => JsonNumber(1.0ff)})))
        }
    }
}