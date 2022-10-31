namespace TestJsonable {
    use Json.Jsonable
    use Json/Jsonable.fromJson
    use Json/Jsonable.toJson
    use Json.JsonElement.JsonString

    @test
    pub def testBool01(): Bool = testRoundTrip(true)

    @test
    pub def testBool02(): Bool = testRoundTrip(false)

    @test
    pub def testChar01(): Bool = testRoundTrip('a')

    @test
    pub def testFloat32_01(): Bool = testRoundTrip(0.123f32)

    @test
    pub def testFloat32_02(): Bool = testRoundTrip(Float32.positiveInfinity())

    @test
    pub def testFloat32_03(): Bool = testRoundTrip(Float32.negativeInfinity())

    // we don't use == for NaN since == is weird with it
    @test
    pub def testFloat32_04(): Bool = match (Float32.nan() |> toJson |> fromJson) {
        case Ok(x) => Float32.isNan(x)
        case Err(_) => false
    }

    @test
    pub def testFloat64_01(): Bool = testRoundTrip(0.123f64)

    @test
    pub def testFloat64_02(): Bool = testRoundTrip(Float64.positiveInfinity())

    @test
    pub def testFloat64_03(): Bool = testRoundTrip(Float64.negativeInfinity())

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

    def testRoundTrip(x: a): Bool with Jsonable[a], Eq[a] = {
        x |> toJson |> fromJson == Ok(x)
    }
}