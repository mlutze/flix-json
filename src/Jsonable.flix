mod Json {
    use Json.Path.Path;
    use Json.Path.{!!};
    use JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}
    use JsonError.JsonError

    pub enum JsonError(Path, Set[String]) with Eq

    pub trait ToJson[a] {
        pub def toJson(x: a): JsonElement
    }

    pub trait FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, a]
        pub def fromJson(x: JsonElement): Result[JsonError, a] = Json.FromJson.fromJsonAt(Path.Root, x)
        pub def fromNullableJsonAt(p: Path, x: JsonElement): Result[JsonError, Option[a]] = match x {
            case JsonNull => Ok(None)
            case y => Json.FromJson.fromJsonAt(p, y)
                |> Result.mapErr(match JsonError(path, expected) -> JsonError(path, Set.insert("null", expected)))
                |> Result.map(Some)
        }
        pub def fromNullableJson(x: JsonElement): Result[JsonError, Option[a]] = Json.FromJson.fromNullableJsonAt(Path.Root, x)
    }

    pub lawful trait Jsonable[a] with ToJson[a], FromJson[a] {
        law inverse: forall (x: a) with Eq[a] {
            x |> Json.ToJson.toJson |> Json.FromJson.fromJson == Ok(x)
        }
    }

    instance ToJson[Bool] {
        pub def toJson(x: Bool): JsonElement = JsonBool(x)
    }

    instance FromJson[Bool] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Bool] = match x {
            case JsonBool(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"boolean value"}))
        }
    }

    instance Jsonable[Bool]

    instance ToJson[Char] {
        pub def toJson(x: Char): JsonElement = JsonString(Char.toString(x))
    }

    instance FromJson[Char] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Char] = match x {
            case JsonString(y) if String.length(y) > 0 => Ok(String.charAt(0, y))
            case _ => Err(JsonError(p, Set#{"singleton string"}))
        }
    }

    instance Jsonable[Char]

    instance ToJson[Float32] {
        pub def toJson(x: Float32): JsonElement = {
            match Float32.tryToBigDecimal(x) {
                case Some(num) => JsonNumber(num)
                case None =>
                    if (Float32.isInfinite(x)) {
                        if (x > 0.0f32) {
                            JsonString("Infinity")
                        } else {
                            JsonString("-Infinity")
                        }
                    } else if (Float32.isNan(x)) {
                        JsonString("NaN")
                    } else {
                        bug!("invalid Float32: ${x}")
                    }
            }
        }
    }

    instance FromJson[Float32] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Float32] = match x {
            case JsonNumber(y) => BigDecimal.tryToFloat32(y) |> Option.toOk(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
            case JsonString("Infinity") => Ok(Float32.positiveInfinity())
            case JsonString("-Infinity") => Ok(Float32.negativeInfinity())
            case JsonString("NaN") => Ok(Float32.nan())
            case _ => Err(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
        }
    }

    instance ToJson[Float64] {
        pub def toJson(x: Float64): JsonElement = {
            match Float64.tryToBigDecimal(x) {
                case Some(num) => JsonNumber(num)
                case None =>
                    if (Float64.isInfinite(x)) {
                        if (x > 0.0f64) {
                            JsonString("Infinity")
                        } else {
                            JsonString("-Infinity")
                        }
                    } else if (Float64.isNan(x)) {
                        JsonString("NaN")
                    } else {
                        bug!("invalid Float64: ${x}")
                    }
            }
        }
    }

    instance FromJson[Float64] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Float64] = match x {
            case JsonNumber(y) => BigDecimal.tryToFloat64(y) |> Option.toOk(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
            case JsonString("Infinity") => Ok(Float64.positiveInfinity())
            case JsonString("-Infinity") => Ok(Float64.negativeInfinity())
            case JsonString("NaN") => Ok(Float64.nan())
            case _ => Err(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
        }
    }

    instance ToJson[BigDecimal] {
        pub def toJson(x: BigDecimal): JsonElement = JsonNumber(x)
    }

    instance FromJson[BigDecimal] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, BigDecimal] = match x {
            case JsonNumber(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"floating-point number"}))
        }
    }

    instance Jsonable[BigDecimal]

    instance ToJson[Int8] {
        pub def toJson(x: Int8): JsonElement = {
            JsonNumber(Int8.toBigDecimal(x))
        }
    }

    instance FromJson[Int8] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int8] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt8(y) |> Option.toOk(JsonError(p, Set#{"8-bit integer"}))
            case _ => Err(JsonError(p, Set#{"8-bit integer"}))
        }
    }

    instance Jsonable[Int8]

    instance ToJson[Int16] {
        pub def toJson(x: Int16): JsonElement = {
            JsonNumber(Int16.toBigDecimal(x))
        }
    }

    instance FromJson[Int16] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int16] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt16(y) |> Option.toOk(JsonError(p, Set#{"16-bit integer"}))
            case _ => Err(JsonError(p, Set#{"16-bit integer"}))
        }
    }

    instance Jsonable[Int16]

    instance ToJson[Int32] {
        pub def toJson(x: Int32): JsonElement = {
            JsonNumber(Int32.toBigDecimal(x))
        }
    }

    instance FromJson[Int32] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int32] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt32(y) |> Option.toOk(JsonError(p, Set#{"32-bit integer"}))
            case _ => Err(JsonError(p, Set#{"32-bit integer"}))
        }
    }

    instance Jsonable[Int32]

    instance ToJson[Int64] {
        pub def toJson(x: Int64): JsonElement = {
            JsonNumber(Int64.toBigDecimal(x))
        }
    }

    instance FromJson[Int64] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int64] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt64(y) |> Option.toOk(JsonError(p, Set#{"64-bit integer"}))
            case _ => Err(JsonError(p, Set#{"64-bit integer"}))
        }
    }

    instance Jsonable[Int64]

    instance ToJson[BigInt] {
        pub def toJson(x: BigInt): JsonElement = {
            JsonNumber(BigInt.toBigDecimal(x))
        }
    }

    instance FromJson[BigInt] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, BigInt] = match x {
            case JsonNumber(y) => Ok(BigDecimal.toBigInt(y))
            case _ => Err(JsonError(p, Set#{"integer"}))
        }
    }

    instance Jsonable[BigInt]

    instance ToJson[String] {
        pub def toJson(x: String): JsonElement = JsonString(x)
    }

    instance FromJson[String] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, String] = match x {
            case JsonString(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"string"}))
        }
    }

    instance Jsonable[String]

    instance ToJson[List[a]] with ToJson[a] {
        pub def toJson(x: List[a]): JsonElement = {
            let elems = List.map(Json.ToJson.toJson, x);
            JsonArray(elems)
        }
    }

    instance FromJson[List[a]] with FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, List[a]] = match x {
            case JsonArray(l) => l |> List.zipWithIndex |> Result.traverse(match (i, val) -> Json.FromJson.fromJsonAt(p !! i, val))
            case _ => Err(JsonError(p, Set#{"array"}))
        }
    }

    instance Jsonable[List[a]] with Jsonable[a]

    instance ToJson[Map[k, v]] with ToString[k], ToJson[v] {
        pub def toJson(x: Map[k, v]): JsonElement = {
            let map = x
                |> Map.toList
                |> List.map(match (k, v) -> (ToString.toString(k), Json.ToJson.toJson(v)))
                |> List.toMap;
            JsonObject(map)
        }
    }

    instance FromJson[Map[k, v]] with FromString[k], Order[k], FromJson[v] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Map[k, v]] = match x {
            case JsonObject(m0) =>
                use Result.flatMap;
                let l0 = Map.toList(m0);
                forM (
                    l <- l0 |> Result.traverse(match (k0, v0) ->
                    forM (
                        k <- FromString.fromString(k0) |> Option.toOk(JsonError(p !! k0, Set#{"valid key"}));
                        v <- Json.FromJson.fromJsonAt(p !! k0, v0)
                    ) yield {
                        (k, v)
                    })
                ) yield {
                    List.toMap(l)
                }
            case _ => Err(JsonError(p, Set#{"object"}))
        }
    }

    instance Jsonable[Map[k, v]] with ToString[k], FromString[k], Order[k], ToJson[v], FromJson[v]

    instance ToJson[Option[a]] with ToJson[a] {
        pub def toJson(x: Option[a]): JsonElement = match x {
            case Some(y) => JsonArray(Json.ToJson.toJson(y) :: Nil)
            case None => JsonArray(Nil)
        }
    }

    instance FromJson[Option[a]] with FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Option[a]] = match x {
            case JsonArray(Nil) => Ok(None)
            case JsonArray(y0 :: Nil) =>
                forM (
                    y <- Json.FromJson.fromJsonAt(p, y0)
                ) yield {
                    Some(y)
                }
            case _ => Err(JsonError(p, Set#{"empty array", "singleton array"}))
        }
    }

    instance Jsonable[Option[a]] with FromJson[a], ToJson[a]

    instance ToJson[(a, b)] with ToJson[a], ToJson[b] {
        pub def toJson(x: (a, b)): JsonElement = {
            let (a, b) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            JsonArray(jsonA :: jsonB :: Nil)
        }
    }

    instance FromJson[(a, b)] with FromJson[a], FromJson[b] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b)] = {
            forM (
                l <- Json.FromJson.fromJsonAt(p, x);
                res <- match l {
                    case a :: b :: Nil =>
                        forM (
                            resA <- Json.FromJson.fromJsonAt(p !! 0, a);
                            resB <- Json.FromJson.fromJsonAt(p !! 1, b)
                        ) yield {
                            (resA, resB)
                        }
                    case _ =>
                        Err(JsonError(p, Set#{"2-ary array"}))
                }
            ) yield {
                res
            }
        }
    }

    instance Jsonable[(a, b)] with Jsonable[a], Jsonable[b]

    instance ToJson[(a, b, c)] with ToJson[a], ToJson[b], ToJson[c] {
        pub def toJson(x: (a, b, c)): JsonElement = {
            let (a, b, c) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            let jsonC = Json.ToJson.toJson(c);
            JsonArray(jsonA :: jsonB :: jsonC :: Nil)
        }
    }

    instance FromJson[(a, b, c)] with FromJson[a], FromJson[b], FromJson[c] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b, c)] = {
            forM (
                l <- Json.FromJson.fromJsonAt(p, x);
                res <- match l {
                    case a :: b :: c :: Nil =>
                        forM (
                            resA <- Json.FromJson.fromJsonAt(p !! 0, a);
                            resB <- Json.FromJson.fromJsonAt(p !! 1, b);
                            resC <- Json.FromJson.fromJsonAt(p !! 2, c)
                        ) yield {
                            (resA, resB, resC)
                        }
                    case _ =>
                        Err(JsonError(p, Set#{"3-ary array"}))
                }
            ) yield {
                res
            }
        }
    }

    instance Jsonable[(a, b, c)] with Jsonable[a], Jsonable[b], Jsonable[c]

    instance ToJson[(a, b, c, d)] with ToJson[a], ToJson[b], ToJson[c], ToJson[d] {
        pub def toJson(x: (a, b, c, d)): JsonElement = {
            let (a, b, c, d) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            let jsonC = Json.ToJson.toJson(c);
            let jsonD = Json.ToJson.toJson(d);
            JsonArray(jsonA :: jsonB :: jsonC :: jsonD :: Nil)
        }
    }

    instance FromJson[(a, b, c, d)] with FromJson[a], FromJson[b], FromJson[c], FromJson[d] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b, c, d)] = {
            forM (
                l <- Json.FromJson.fromJsonAt(p, x);
                res <- match l {
                    case a :: b :: c :: d :: Nil =>
                        forM (
                            resA <- Json.FromJson.fromJsonAt(p !! 0, a);
                            resB <- Json.FromJson.fromJsonAt(p !! 1, b);
                            resC <- Json.FromJson.fromJsonAt(p !! 2, c);
                            resD <- Json.FromJson.fromJsonAt(p !! 3, d)
                        ) yield {
                            (resA, resB, resC, resD)
                        }
                    case _ =>
                        Err(JsonError(p, Set#{"4-ary array"}))
                }
            ) yield {
                res
            }
        }
    }

    instance Jsonable[(a, b, c, d)] with Jsonable[a], Jsonable[b], Jsonable[c], Jsonable[d]

    instance ToJson[JsonElement] {
        pub def toJson(x: JsonElement): JsonElement = x
    }

    instance FromJson[JsonElement] {
        pub def fromJsonAt(_: Path, x: JsonElement): Result[JsonError, JsonElement] = Ok(x)
    }

    instance Jsonable[JsonElement]

    ///
    /// Returns the value associated with the given key in the given map.
    ///
    /// If the key is not present or has the wrong type,
    /// then returns an error associated with the given path.
    ///
    pub def getAtKey(p: Path, key: k, m: Map[String, JsonElement]): Result[JsonError, v] with ToString[k], FromJson[v] = {
        match Map.get("${key}", m) {
            case None => Err(JsonError(p, Set#{"object with key '${key}'"}))
            case Some(val) => Json.FromJson.fromJsonAt(p !! "${key}", val)
        }
    }

    ///
    /// Returns the value associated with the given key in the given map.
    ///
    /// If the key is not present, then returns None.
    /// If the key is present but has the wrong type,
    /// then returns an error associated with the given path.
    ///
    pub def getAtKeyOpt(p: Path, key: k, m: Map[String, JsonElement]): Result[JsonError, Option[v]] with ToString[k], FromJson[v] = {
        use Result.flatMap;
        match Map.get("${key}", m) {
            case None => Ok(None)
            case Some(val) =>
                forM (
                    res <- Json.FromJson.fromJsonAt(p !! "${key}", val)
                ) yield {
                    Some(res)
                }
        }
    }
}
