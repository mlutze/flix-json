namespace TestJsonable {
    use Json.FromJson
    use Json.JsonElement.JsonNull
    use Json.JsonElement.JsonString
    use Json.Jsonable
    use Json.ToJson
    use Json/FromJson.fromJson
    use Json/FromJson.fromNullableJson
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
    pub def testJsonElement01(): Bool = testRoundTrip(JsonString("howdy"))

    @test
    pub def testNullable01(): Bool = fromNullableJson(JsonNull) == Ok(None: Option[String])

    @test
    pub def testNullable02(): Bool = fromNullableJson(JsonString("hello")) == Ok(Some("hello"))

    def testRoundTrip(x: a): Bool with Jsonable[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }

    def testLawlessRoundTrip(x: a): Bool with FromJson[a], ToJson[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }
}