mod TestPath {
    use Json.Path.apply;
    use Json.Path.{!!};
    use Json.Path.Path.Root;
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @Test
    pub def testPath01(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root;
        Assert.assertEq(expected = Some(JsonNull), apply(path, json))
    }

    @Test
    pub def testPath02(): Unit \ Assert = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "b";
        Assert.assertEq(expected = Some(JsonBool(false)), apply(path, json))
    }

    @Test
    pub def testPath03(): Unit \ Assert = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 1;
        Assert.assertEq(expected = Some(JsonBool(true)), apply(path, json))
    }

    @Test
    pub def testPath04(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root !! "b";
        Assert.assertEq(expected = None, apply(path, json))
    }

    @Test
    pub def testPath05(): Unit \ Assert = {
        let json = JsonNull;
        let path = Root !! 1;
        Assert.assertEq(expected = None, apply(path, json))
    }

    @Test
    pub def testPath06(): Unit \ Assert = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "c";
        Assert.assertEq(expected = None, apply(path, json))
    }

    @Test
    pub def testPath07(): Unit \ Assert = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 5;
        Assert.assertEq(expected = None, apply(path, json))
    }

    @Test
    pub def testPathToString(): Unit \ Assert = {
        let path = Root !! 5 !! "hello" !! "world" !! 42;
        Assert.assertEq(expected = "$[5][\"hello\"][\"world\"][42]", "${path}")
    }
}