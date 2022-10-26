namespace TestPath {
    use Json/Path.apply;
    use Json/Path.atKey;
    use Json/Path.atIndex;
    use Json/Path.Path.Root;
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}

    @test
    pub def testPath01(): Bool = {
        let json = JsonNull;
        let path = Root;
        apply(path, json) == Some(JsonNull)
    }

    @test
    pub def testPath02(): Bool = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root `atKey` "b";
        apply(path, json) == Some(JsonBool(false))
    }

    @test
    pub def testPath03(): Bool = {
        let json = JsonArray(JsonNull :: JsonBool(true) :: JsonBool(false) :: Nil);
        let path = Root `atIndex` 1;
        apply(path, json) == Some(JsonBool(true))
    }

    @test
    pub def testPath04(): Bool = {
        let json = JsonNull;
        let path = Root `atKey` "b";
        apply(path, json) == None
    }

    @test
    pub def testPath05(): Bool = {
        let json = JsonNull;
        let path = Root `atIndex` 1;
        apply(path, json) == None
    }

    @test
    pub def testPath06(): Bool = {
        let json = JsonObject(Map#{"a" => JsonBool(true), "b" => JsonBool(false)});
        let path = Root `atKey` "c";
        apply(path, json) == None
    }

    @test
    pub def testPath07(): Bool = {
        let json = JsonArray(JsonNull :: JsonBool(true) :: JsonBool(false) :: Nil);
        let path = Root `atIndex` 5;
        apply(path, json) == None
    }

    @test
    pub def testPathToString(): Bool = {
        let path = Root `atIndex` 5 `atKey` "hello" `atKey` "world" `atIndex` 42;
        "${path}" == "$[5].hello.world[42]"
    }
}