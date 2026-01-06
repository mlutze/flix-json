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
    pub def testBool01(): Bool = testRoundTrip(true)

    @Test
    pub def testBool02(): Bool = testRoundTrip(false)

    @Test
    pub def testChar01(): Bool = testRoundTrip('a')

    @Test
    pub def testFloat32_01(): Bool = testLawlessRoundTrip(0.123f32)

    @Test
    pub def testFloat32_02(): Bool = testLawlessRoundTrip(Float32.positiveInfinity())

    @Test
    pub def testFloat32_03(): Bool = testLawlessRoundTrip(Float32.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @Test
    pub def testFloat32_04(): Bool = match (Float32.nan() |> toJson |> fromJson) {
        case Ok(x) => Float32.isNan(x)
        case Err(_) => false
    }

    @Test
    pub def testFloat64_01(): Bool = testLawlessRoundTrip(0.123f64)

    @Test
    pub def testFloat64_02(): Bool = testLawlessRoundTrip(Float64.positiveInfinity())

    @Test
    pub def testFloat64_03(): Bool = testLawlessRoundTrip(Float64.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @Test
    pub def testFloat64_04(): Bool = match (Float64.nan() |> toJson |> fromJson) {
        case Ok(x) => Float64.isNan(x)
        case Err(_) => false
    }

    @Test
    pub def testBigDecimal01(): Bool = testRoundTrip(1.23ff)

    @Test
    pub def testInt8_01(): Bool = testRoundTrip(123i8)

    @Test
    pub def testInt16_01(): Bool = testRoundTrip(123i16)

    @Test
    pub def testInt32_01(): Bool = testRoundTrip(123i32)

    @Test
    pub def testInt64_01(): Bool = testRoundTrip(123i64)

    @Test
    pub def testBigInt01(): Bool = testRoundTrip(123ii)

    @Test
    pub def testString01(): Bool = testRoundTrip("hello")

    @Test
    pub def testList01(): Bool = testRoundTrip(1 :: 2 :: 3 :: Nil)

    @Test
    pub def testList02(): Bool = testRoundTrip((1 :: Nil) :: (2 :: 3 :: Nil) :: Nil)

    @Test
    pub def testMap01(): Bool = testRoundTrip(Map#{"hi there" => 1, "blah" => 99})

    @Test
    pub def testMap02(): Bool = testRoundTrip(Map#{"hi there" => Map#{"bye there" => 43i8}, "blah?" => Map#{"blah" => 99i8}})

    @Test
    pub def testOption01(): Bool = testRoundTrip((None: Option[String]))

    @Test
    pub def testOption02(): Bool = testRoundTrip(Some("hello"))

    @Test
    pub def testTuple01(): Bool = testRoundTrip(("asdf", 123))

    @Test
    pub def testTuple02(): Bool = testRoundTrip(("asdf", 123, 'c'))

    @Test
    pub def testTuple03(): Bool = testRoundTrip(("asdf", 123, 'c', 987ff))

    @Test
    pub def testJsonElement01(): Bool = testRoundTrip(JsonString("howdy"))

    @Test
    pub def testNullable01(): Bool = fromNullableJson(JsonNull) == Ok((None: Option[String]))

    @Test
    pub def testNullable02(): Bool = fromNullableJson(JsonString("hello")) == Ok(Some("hello"))

    enum Thing(String, Int32) with Eq

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
    pub def testThing01(): Bool = testRoundTrip(Thing.Thing("Hello", 123))

    enum Thing2(String, Option[Int32]) with Eq

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
    pub def testThing2_01(): Bool = testRoundTrip(Thing2.Thing2("Hello", None))

    @Test
    pub def testThing2_02(): Bool = testRoundTrip(Thing2.Thing2("Hello", Some(123)))

    @Test
    pub def testVector01(): Bool = testRoundTrip(Vector#{1, 2, 3})

    @Test
    pub def testVector02(): Bool = testRoundTrip(Vector#{"a", "b", "c"})

    def testRoundTrip(x: a): Bool with Jsonable[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }

    def testLawlessRoundTrip(x: a): Bool with FromJson[a], ToJson[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }
}
