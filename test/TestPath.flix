mod TestPath {
    use Json.Path.apply;
    use Json.Path.{!!};
    use Json.Path.Path.Root;
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @Test
    pub def testPath01(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root;
        Assert.assertTrue(apply(path, json) == Some(JsonNull))
    }

    @Test
    pub def testPath02(): Unit \ Assert = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "b";
        Assert.assertTrue(apply(path, json) == Some(JsonBool(false)))
    }

    @Test
    pub def testPath03(): Unit \ Assert = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 1;
        Assert.assertTrue(apply(path, json) == Some(JsonBool(true)))
    }

    @Test
    pub def testPath04(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root !! "b";
        Assert.assertTrue(apply(path, json) == None)
    }

    @Test
    pub def testPath05(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root !! 1;
        Assert.assertTrue(apply(path, json) == None)
    }

    @Test
    pub def testPath06(): Unit \ Assert = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "c";
        Assert.assertTrue(apply(path, json) == None)
    }

    @Test
    pub def testPath07(): Unit \ Assert = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 5;
        Assert.assertTrue(apply(path, json) == None)
    }

    @Test
    pub def testPathToString(): Unit \ Assert = {
        let path = Root !! 5 !! "hello" !! "world" !! 42;
        Assert.assertTrue("${path}" == "$[5][\"hello\"][\"world\"][42]")
    }
}