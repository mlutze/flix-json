mod TestJsonable {
    use Json.FromJson
    use Json.JsonElement
    use Json.JsonElement.JsonNull
    use Json.JsonElement.JsonObject
    use Json.JsonElement.JsonString
    use Json.JsonError
    use Json.Jsonable
    use Json.ToJson
    use Json.getAtKey;
    use Json.getAtKeyOpt;
    use Json.FromJson.fromJson
    use Json.FromJson.fromJsonAt
    use Json.FromJson.fromNullableJson
    use Json.Path.Path
    use Json.ToJson.toJson

    @Test
    pub def testBool01(): Unit \ Assert = testRoundTrip(true)

    @Test
    pub def testBool02(): Unit \ Assert = testRoundTrip(false)

    @Test
    pub def testChar01(): Unit \ Assert = testRoundTrip('a')

    @Test
    pub def testFloat32_01(): Unit \ Assert = testLawlessRoundTrip(0.123f32)

    @Test
    pub def testFloat32_02(): Unit \ Assert = testLawlessRoundTrip(Float32.positiveInfinity())

    @Test
    pub def testFloat32_03(): Unit \ Assert = testLawlessRoundTrip(Float32.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @Test
    pub def testFloat32_04(): Unit \ Assert = {
        match (Float32.nan() |> toJson |> fromJson) {
            case Ok(x) => Assert.assertTrue(Float32.isNan(x))
            case Err(_) => Assert.assertTrue(false)
        }
    }

    @Test
    pub def testFloat64_01(): Unit \ Assert = testLawlessRoundTrip(0.123f64)

    @Test
    pub def testFloat64_02(): Unit \ Assert = testLawlessRoundTrip(Float64.positiveInfinity())

    @Test
    pub def testFloat64_03(): Unit \ Assert = testLawlessRoundTrip(Float64.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @Test
    pub def testFloat64_04(): Unit \ Assert = {
        match (Float64.nan() |> toJson |> fromJson) {
            case Ok(x) => Assert.assertTrue(Float64.isNan(x))
            case Err(_) => Assert.assertTrue(false)
        }
    }

    @Test
    pub def testBigDecimal01(): Unit \ Assert = testRoundTrip(1.23ff)

    @Test
    pub def testInt8_01(): Unit \ Assert = testRoundTrip(123i8)

    @Test
    pub def testInt16_01(): Unit \ Assert = testRoundTrip(123i16)

    @Test
    pub def testInt32_01(): Unit \ Assert = testRoundTrip(123i32)

    @Test
    pub def testInt64_01(): Unit \ Assert = testRoundTrip(123i64)

    @Test
    pub def testBigInt01(): Unit \ Assert = testRoundTrip(123ii)

    @Test
    pub def testString01(): Unit \ Assert = testRoundTrip("hello")

    @Test
    pub def testList01(): Unit \ Assert = testRoundTrip(1 :: 2 :: 3 :: Nil)

    @Test
    pub def testList02(): Unit \ Assert = testRoundTrip((1 :: Nil) :: (2 :: 3 :: Nil) :: Nil)

    @Test
    pub def testMap01(): Unit \ Assert = testRoundTrip(Map#{"hi there" => 1, "blah" => 99})

    @Test
    pub def testMap02(): Unit \ Assert = testRoundTrip(Map#{"hi there" => Map#{"bye there" => 43i8}, "blah?" => Map#{"blah" => 99i8}})

    @Test
    pub def testOption01(): Unit \ Assert = testRoundTrip((None: Option[String]))

    @Test
    pub def testOption02(): Unit \ Assert = testRoundTrip(Some("hello"))

    @Test
    pub def testTuple01(): Unit \ Assert = testRoundTrip(("asdf", 123))

    @Test
    pub def testTuple02(): Unit \ Assert = testRoundTrip(("asdf", 123, 'c'))

    @Test
    pub def testTuple03(): Unit \ Assert = testRoundTrip(("asdf", 123, 'c', 987ff))

    @Test
    pub def testJsonElement01(): Unit \ Assert = testRoundTrip(JsonString("howdy"))

    @Test
    pub def testNullable01(): Unit \ Assert =
        Assert.assertEq(expected = Ok((None: Option[String])), fromNullableJson(JsonNull))

    @Test
    pub def testNullable02(): Unit \ Assert =
        Assert.assertEq(expected = Ok(Some("hello")), fromNullableJson(JsonString("hello")))

    enum Thing(String, Int32) with Eq, ToString

    instance ToJson[Thing] {
        pub def toJson(x: Thing): JsonElement = {
            let Thing.Thing(name, age) = x;
            JsonObject(Map#{"name" => toJson(name), "age" => toJson(age)})
        }
    }

    instance FromJson[Thing] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Thing] = {
            use Result.flatMap;
            forM (
                map <- fromJsonAt(p, x);
                name <- getAtKey(p, "name", map);
                age <- getAtKey(p, "age", map)
            ) yield {
                Thing.Thing(name, age)    
            }
        }
    }

    instance Jsonable[Thing]

    @Test
    pub def testThing01(): Unit \ Assert = testRoundTrip(Thing.Thing("Hello", 123))

    enum Thing2(String, Option[Int32]) with Eq, ToString

    instance ToJson[Thing2] {
        pub def toJson(x: Thing2): JsonElement = {
            let Thing2.Thing2(name, age) = x;
            let required = Map#{"name" => toJson(name)};
            let all = match age {
                case None => required
                case Some(a) => required |> Map.insert("age", toJson(a))
            };
            JsonObject(all)
        }
    }

    instance FromJson[Thing2] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Thing2] = {
            forM (
                obj <- fromJsonAt(p, x);
                name <- getAtKey(p, "name", obj);
                age <- getAtKeyOpt(p, "age", obj)
            ) yield {
                Thing2.Thing2(name, age)
            }
        }
    }

    instance Jsonable[Thing2]

    @Test
    pub def testThing2_01(): Unit \ Assert = testRoundTrip(Thing2.Thing2("Hello", None))

    @Test
    pub def testThing2_02(): Unit \ Assert = testRoundTrip(Thing2.Thing2("Hello", Some(123)))

    @Test
    pub def testVector01(): Unit \ Assert = testRoundTrip(Vector#{1, 2, 3})

    @Test
    pub def testVector02(): Unit \ Assert = testRoundTrip(Vector#{"a", "b", "c"})

    def testRoundTrip(x: a): Unit \ Assert with Jsonable[a], Eq[a], ToString[a] = {
        Assert.assertEq(expected = Ok(x), x |> toJson |> fromJson)
    }

    def testLawlessRoundTrip(x: a): Unit \ Assert with FromJson[a], ToJson[a], Eq[a], ToString[a] = {
        Assert.assertEq(expected = Ok(x), x |> toJson |> fromJson)
    }
}
