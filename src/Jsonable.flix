namespace Json {
    use Json/Path.Path;
    use Json/Path.atIndex;
    use Json/Path.atKey;

    pub enum JsonError(Path, String) with Eq

    pub class Jsonable[a] {
        pub def toJson(x: a): JsonElement
        pub def fromJsonAt(p: Path, x: JsonElement): Result[a, JsonError]
        pub def fromJson(x: JsonElement): Result[a, JsonError] = Json/Jsonable.fromJsonAt(Path.Root, x)
    }

    instance Jsonable[Bool] {
        pub def toJson(x: Bool): JsonElement = JsonBool(x)

        pub def fromJsonAt(p: Path, x: JsonElement): Result[Bool, JsonError] = match x {
            case JsonBool(y) => Ok(y)
            case _ => Err(JsonError(p, "boolean value"))
        }
    }

    instance Jsonable[Char] {
        pub def toJson(x: Char): JsonElement = JsonString(Char.toString(x))
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Char, JsonError] = match x {
            case JsonString(y) if String.length(y) > 0 => Ok(String.charAt(0, y))
            case _ => Err(JsonError(p, "singleton string"))
        }
    }

    instance Jsonable[Float32] {
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
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Float32, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToFloat32(y) |> Option.toOk(JsonError(p, "floating-point number or \"-Infinity\" or \"Infinity\" or \"NaN\""))
            case JsonString("Infinity") => Ok(Float32.positiveInfinity())
            case JsonString("-Infinity") => Ok(Float32.negativeInfinity())
            case JsonString("NaN") => Ok(Float32.nan())
            case _ => Err(JsonError(p, "floating-point number or \"-Infinity\" or \"Infinity\" or \"NaN\""))
        }
    }

    instance Jsonable[Float64] {
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
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Float64, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToFloat64(y) |> Option.toOk(JsonError(p, "floating-point number or \"-Infinity\" or \"Infinity\" or \"NaN\""))
            case JsonString("Infinity") => Ok(Float64.positiveInfinity())
            case JsonString("-Infinity") => Ok(Float64.negativeInfinity())
            case JsonString("NaN") => Ok(Float64.nan())
            case _ => Err(JsonError(p, "floating-point number or \"-Infinity\" or \"Infinity\" or \"NaN\""))
        }
    }

    instance Jsonable[Int8] {
        pub def toJson(x: Int8): JsonElement = {
            JsonNumber(Int8.toBigDecimal(x))
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Int8, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt8(y) |> Option.toOk(JsonError(p, "8-bit integer"))
            case _ => Err(JsonError(p, "8-bit integer"))
        }
    }
    
    instance Jsonable[Int16] {
        pub def toJson(x: Int16): JsonElement = {
            JsonNumber(Int16.toBigDecimal(x))
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Int16, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt16(y) |> Option.toOk(JsonError(p, "16-bit integer"))
            case _ => Err(JsonError(p, "16-bit integer"))
        }
    }

    instance Jsonable[Int32] {
        pub def toJson(x: Int32): JsonElement = {
            JsonNumber(Int32.toBigDecimal(x))
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Int32, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt32(y) |> Option.toOk(JsonError(p, "32-bit integer"))
            case _ => Err(JsonError(p, "32-bit integer"))
        }
    }
    
    instance Jsonable[Int64] {
        pub def toJson(x: Int64): JsonElement = {
            JsonNumber(Int64.toBigDecimal(x))
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Int64, JsonError] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt64(y) |> Option.toOk(JsonError(p, "64-bit integer"))
            case _ => Err(JsonError(p, "64-bit integer"))
        }
    }

    instance Jsonable[BigInt] {
        pub def toJson(x: BigInt): JsonElement = {
            JsonNumber(BigInt.toBigDecimal(x))
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[BigInt, JsonError] = match x {
            case JsonNumber(y) => Ok(BigDecimal.toBigInt(y))
            case _ => Err(JsonError(p, "integer"))
        }
    }

    instance Jsonable[String] {
        pub def toJson(x: String): JsonElement = JsonString(x)

        pub def fromJsonAt(p: Path, x: JsonElement): Result[String, JsonError] = match x {
            case JsonString(y) => Ok(y)
            case _ => Err(JsonError(p, "string"))
        }

    }

    instance Jsonable[List[a]] with Jsonable[a] {
        pub def toJson(x: List[a]): JsonElement = {
            let elems = List.map(Json/Jsonable.toJson, x);
            JsonArray(elems)
        }

        pub def fromJsonAt(p: Path, x: JsonElement): Result[List[a], JsonError] = match x {
            case JsonArray(l) => l |> List.zipWithIndex |> Result.traverse(match (val, i) -> Json/Jsonable.fromJsonAt(p `atIndex` i, val))
            case _ => Err(JsonError(p, "array"))
        }
    }

    instance Jsonable[Map[k, v]] with ToString[k], FromString[k], Order[k], Jsonable[v] {
        pub def toJson(x: Map[k, v]): JsonElement = {
            let map = x
                |> Map.toList
                |> List.map(match (k, v) -> (ToString.toString(k), Json/Jsonable.toJson(v)))
                |> List.toMap;
            JsonObject(map)
        }

        pub def fromJsonAt(p: Path, x: JsonElement): Result[Map[k, v], JsonError] = match x {
            case JsonObject(m0) =>
                use Result.flatMap;
                let l0 = Map.toList(m0);
                let* l = l0 |> Result.traverse(match (k0, v0) -> 
                    let* k = FromString.fromString(k0) |> Option.toOk(JsonError(p `atKey` k0, "valid key"));
                    let* v = Json/Jsonable.fromJsonAt(p `atKey` k0, v0);
                    Ok(k, v)
                );
                Ok(List.toMap(l))
            case _ => Err(JsonError(p, "object"))
        }
    }

    instance Jsonable[Option[a]] with Jsonable[a] {
        pub def toJson(x: Option[a]): JsonElement = match x {
            case Some(y) => Json/Jsonable.toJson(y)
            case None => JsonNull
        }
    
        pub def fromJsonAt(p: Path, x: JsonElement): Result[Option[a], JsonError] = match x {
            case JsonNull => Ok(None)
            case json => {
                use Result.flatMap;
                let* y = Json/Jsonable.fromJsonAt(p, json);
                Ok(Some(y))
            }
        }
    }

    instance Jsonable[JsonElement] {
        pub def toJson(x: JsonElement): JsonElement = x

        pub def fromJsonAt(_: Path, x: JsonElement): Result[JsonElement, JsonError] = Ok(x)
    }
}