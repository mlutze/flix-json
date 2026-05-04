pub mod Json.FromJson {
    use Json.JsonElement
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull}
    use Json.JsonError
    use Json.Path
    use Json.Path.{!!}

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

    instance FromJson[Bool] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Bool] = match x {
            case JsonBool(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"boolean value"}))
        }
    }

    instance FromJson[Char] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Char] = match x {
            case JsonString(y) if String.length(y) > 0 => Ok(String.charAt(0, y))
            case _ => Err(JsonError(p, Set#{"singleton string"}))
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

    instance FromJson[Float64] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Float64] = match x {
            case JsonNumber(y) => BigDecimal.tryToFloat64(y) |> Option.toOk(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
            case JsonString("Infinity") => Ok(Float64.positiveInfinity())
            case JsonString("-Infinity") => Ok(Float64.negativeInfinity())
            case JsonString("NaN") => Ok(Float64.nan())
            case _ => Err(JsonError(p, Set#{"floating-point number", "\"-Infinity\"", "\"Infinity\"", "\"NaN\""}))
        }
    }

    instance FromJson[BigDecimal] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, BigDecimal] = match x {
            case JsonNumber(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"floating-point number"}))
        }
    }

    instance FromJson[Int8] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int8] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt8(y) |> Option.toOk(JsonError(p, Set#{"8-bit integer"}))
            case _ => Err(JsonError(p, Set#{"8-bit integer"}))
        }
    }

    instance FromJson[Int16] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int16] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt16(y) |> Option.toOk(JsonError(p, Set#{"16-bit integer"}))
            case _ => Err(JsonError(p, Set#{"16-bit integer"}))
        }
    }

    instance FromJson[Int32] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int32] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt32(y) |> Option.toOk(JsonError(p, Set#{"32-bit integer"}))
            case _ => Err(JsonError(p, Set#{"32-bit integer"}))
        }
    }

    instance FromJson[Int64] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Int64] = match x {
            case JsonNumber(y) => BigDecimal.tryToInt64(y) |> Option.toOk(JsonError(p, Set#{"64-bit integer"}))
            case _ => Err(JsonError(p, Set#{"64-bit integer"}))
        }
    }

    instance FromJson[BigInt] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, BigInt] = match x {
            case JsonNumber(y) => Ok(BigDecimal.toBigInt(y))
            case _ => Err(JsonError(p, Set#{"integer"}))
        }
    }

    instance FromJson[String] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, String] = match x {
            case JsonString(y) => Ok(y)
            case _ => Err(JsonError(p, Set#{"string"}))
        }
    }

    instance FromJson[List[a]] with FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, List[a]] = match x {
            case JsonArray(v) => v |> Vector.toList |> List.zipWithIndex |> Result.traverse(match (i, val) -> Json.FromJson.fromJsonAt(p !! i, val))
            case _ => Err(JsonError(p, Set#{"array"}))
        }
    }

    instance FromJson[Vector[a]] with FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Vector[a]] = match x {
            case JsonArray(v) =>
                v |> Vector.toList |> List.zipWithIndex |> Result.traverse(match (i, val) -> Json.FromJson.fromJsonAt(p !! i, val)) |> Result.map(List.toVector)
            case _ => Err(JsonError(p, Set#{"array"}))
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

    instance FromJson[Option[a]] with FromJson[a] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Option[a]] = match x {
            case JsonArray(v) if Vector.length(v) == 0 => Ok(None)
            case JsonArray(v) if Vector.length(v) == 1 =>
                forM (
                    y <- Json.FromJson.fromJsonAt(p, Vector.get(0, v))
                ) yield {
                    Some(y)
                }
            case _ => Err(JsonError(p, Set#{"empty array", "singleton array"}))
        }
    }

    instance FromJson[(a, b)] with FromJson[a], FromJson[b] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b)] = match x {
            case JsonArray(v) if Vector.length(v) == 2 =>
                forM (
                    resA <- Json.FromJson.fromJsonAt(p !! 0, Vector.get(0, v));
                    resB <- Json.FromJson.fromJsonAt(p !! 1, Vector.get(1, v))
                ) yield {
                    (resA, resB)
                }
            case _ =>
                Err(JsonError(p, Set#{"2-ary array"}))
        }
    }

    instance FromJson[(a, b, c)] with FromJson[a], FromJson[b], FromJson[c] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b, c)] = match x {
            case JsonArray(v) if Vector.length(v) == 3 =>
                forM (
                    resA <- Json.FromJson.fromJsonAt(p !! 0, Vector.get(0, v));
                    resB <- Json.FromJson.fromJsonAt(p !! 1, Vector.get(1, v));
                    resC <- Json.FromJson.fromJsonAt(p !! 2, Vector.get(2, v))
                ) yield {
                    (resA, resB, resC)
                }
            case _ =>
                Err(JsonError(p, Set#{"3-ary array"}))
        }
    }

    instance FromJson[(a, b, c, d)] with FromJson[a], FromJson[b], FromJson[c], FromJson[d] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, (a, b, c, d)] = match x {
            case JsonArray(v) if Vector.length(v) == 4 =>
                forM (
                    resA <- Json.FromJson.fromJsonAt(p !! 0, Vector.get(0, v));
                    resB <- Json.FromJson.fromJsonAt(p !! 1, Vector.get(1, v));
                    resC <- Json.FromJson.fromJsonAt(p !! 2, Vector.get(2, v));
                    resD <- Json.FromJson.fromJsonAt(p !! 3, Vector.get(3, v))
                ) yield {
                    (resA, resB, resC, resD)
                }
            case _ =>
                Err(JsonError(p, Set#{"4-ary array"}))
        }
    }

    instance FromJson[JsonElement] {
        pub def fromJsonAt(_: Path, x: JsonElement): Result[JsonError, JsonElement] = Ok(x)
    }

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
