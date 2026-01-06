mod TestPath {
    use Json.Path.apply;
    use Json.Path.{!!};
    use Json.Path.Path.Root;
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @Test
    pub def testPath01(): Bool = {
        let json = JsonNull;
        let path = Root;
        apply(path, json) == Some(JsonNull)
    }

    @Test
    pub def testPath02(): Bool = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "b";
        apply(path, json) == Some(JsonBool(false))
    }

    @Test
    pub def testPath03(): Bool = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 1;
        apply(path, json) == Some(JsonBool(true))
    }

    @Test
    pub def testPath04(): Bool = {
        let json = JsonNull;
        let path = Root !! "b";
        apply(path, json) == None
    }

    @Test
    pub def testPath05(): Bool = {
        let json = JsonNull;
        let path = Root !! 1;
        apply(path, json) == None
    }

    @Test
    pub def testPath06(): Bool = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root !! "c";
        apply(path, json) == None
    }

    @Test
    pub def testPath07(): Bool = {
        let json = JsonArray(Vector#{JsonNull, JsonBool(true), JsonBool(false)});
        let path = Root !! 5;
        apply(path, json) == None
    }

    @Test
    pub def testPathToString(): Bool = {
        let path = Root !! 5 !! "hello" !! "world" !! 42;
        "${path}" == "$[5][\"hello\"][\"world\"][42]"
    }
}