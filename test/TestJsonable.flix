namespace TestJsonable {
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
    use Json/FromJson.fromJson
    use Json/FromJson.fromJsonAt
    use Json/FromJson.fromNullableJson
    use Json/Path.Path
    use Json/ToJson.toJson

    @test
    pub def testBool01(): Bool = testRoundTrip(true)

    @test
    pub def testBool02(): Bool = testRoundTrip(false)

    @test
    pub def testChar01(): Bool = testRoundTrip('a')

    @test
    pub def testFloat32_01(): Bool = testLawlessRoundTrip(0.123f32)

    @test
    pub def testFloat32_02(): Bool = testLawlessRoundTrip(Float32.positiveInfinity())

    @test
    pub def testFloat32_03(): Bool = testLawlessRoundTrip(Float32.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @test
    pub def testFloat32_04(): Bool = match (Float32.nan() |> toJson |> fromJson) {
        case Ok(x) => Float32.isNan(x)
        case Err(_) => false
    }

    @test
    pub def testFloat64_01(): Bool = testLawlessRoundTrip(0.123f64)

    @test
    pub def testFloat64_02(): Bool = testLawlessRoundTrip(Float64.positiveInfinity())

    @test
    pub def testFloat64_03(): Bool = testLawlessRoundTrip(Float64.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @test
    pub def testFloat64_04(): Bool = match (Float64.nan() |> toJson |> fromJson) {
        case Ok(x) => Float64.isNan(x)
        case Err(_) => false
    }

    @test
    pub def testBigDecimal01(): Bool = testRoundTrip(1.23ff)

    @test
    pub def testInt8_01(): Bool = testRoundTrip(123i8)

    @test
    pub def testInt16_01(): Bool = testRoundTrip(123i16)

    @test
    pub def testInt32_01(): Bool = testRoundTrip(123i32)

    @test
    pub def testInt64_01(): Bool = testRoundTrip(123i64)

    @test
    pub def testBigInt01(): Bool = testRoundTrip(123ii)

    @test
    pub def testString01(): Bool = testRoundTrip("hello")

    @test
    pub def testList01(): Bool = testRoundTrip(1 :: 2 :: 3 :: Nil)

    @test
    pub def testList02(): Bool = testRoundTrip((1 :: Nil) :: (2 :: 3 :: Nil) :: Nil)

    @test
    pub def testMap01(): Bool = testRoundTrip(Map#{"hi there" => 1, "blah" => 99})

    @test
    pub def testMap02(): Bool = testRoundTrip(Map#{"hi there" => Map#{"bye there" => 43i8}, "blah?" => Map#{"blah" => 99i8}})

    @test
    pub def testOption01(): Bool = testRoundTrip(None: Option[String])

    @test
    pub def testOption02(): Bool = testRoundTrip(Some("hello"))

    @test
    pub def testTuple01(): Bool = testRoundTrip(("asdf", 123))

    @test
    pub def testTuple02(): Bool = testRoundTrip(("asdf", 123, 'c'))

    @test
    pub def testTuple03(): Bool = testRoundTrip(("asdf", 123, 'c', 987ff))

    @test
    pub def testJsonElement01(): Bool = testRoundTrip(JsonString("howdy"))

    @test
    pub def testNullable01(): Bool = fromNullableJson(JsonNull) == Ok(None: Option[String])

    @test
    pub def testNullable02(): Bool = fromNullableJson(JsonString("hello")) == Ok(Some("hello"))

    enum Thing(String, Int32) with Eq

    instance ToJson[Thing] {
        pub def toJson(x: Thing): JsonElement = {
            let Thing(name, age) = x;
            JsonObject(Map#{"name" => toJson(name), "age" => toJson(age)})
        }
    }

    instance FromJson[Thing] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Thing, JsonError] = {
            use Result.flatMap;
            let* map = fromJsonAt(p, x);
            let* name = getAtKey(p, "name", map);
            let* age = getAtKey(p, "age", map);
            Ok(Thing(name, age))
        }
    }

    instance Jsonable[Thing]

    @test
    pub def testThing01(): Bool = testRoundTrip(Thing("Hello", 123))

    enum Thing2(String, Option[Int32]) with Eq

    instance ToJson[Thing2] {
        pub def toJson(x: Thing2): JsonElement = {
            let Thing2(name, age) = x;
            let required = Map#{"name" => toJson(name)};
            let all = match age {
                case None => required
                case Some(a) => required |> Map.insert("age", toJson(a))
            };
            JsonObject(all)
        }
    }

    instance FromJson[Thing2] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Thing2, JsonError] = {
            use Result.flatMap;
            let* obj = fromJsonAt(p, x);
            let* name = getAtKey(p, "name", obj);
            let* age = getAtKeyOpt(p, "age", obj);
            Ok(Thing2(name, age))
        }
    }

    instance Jsonable[Thing2]

    @test
    pub def testThing2_01(): Bool = testRoundTrip(Thing2("Hello", None))

    @test
    pub def testThing2_02(): Bool = testRoundTrip(Thing2("Hello", Some(123)))

    def testRoundTrip(x: a): Bool with Jsonable[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }

    def testLawlessRoundTrip(x: a): Bool with FromJson[a], ToJson[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }
}