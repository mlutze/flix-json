pub mod Json.ToJson {
    use Json.JsonElement
    use Json.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool}

    pub trait ToJson[a] {
        pub def toJson(x: a): JsonElement
    }

    instance ToJson[Bool] {
        pub def toJson(x: Bool): JsonElement = JsonBool(x)
    }

    instance ToJson[Char] {
        pub def toJson(x: Char): JsonElement = JsonString(Char.toString(x))
    }

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

    instance ToJson[BigDecimal] {
        pub def toJson(x: BigDecimal): JsonElement = JsonNumber(x)
    }

    instance ToJson[Int8] {
        pub def toJson(x: Int8): JsonElement = {
            JsonNumber(Int8.toBigDecimal(x))
        }
    }

    instance ToJson[Int16] {
        pub def toJson(x: Int16): JsonElement = {
            JsonNumber(Int16.toBigDecimal(x))
        }
    }

    instance ToJson[Int32] {
        pub def toJson(x: Int32): JsonElement = {
            JsonNumber(Int32.toBigDecimal(x))
        }
    }

    instance ToJson[Int64] {
        pub def toJson(x: Int64): JsonElement = {
            JsonNumber(Int64.toBigDecimal(x))
        }
    }

    instance ToJson[BigInt] {
        pub def toJson(x: BigInt): JsonElement = {
            JsonNumber(BigInt.toBigDecimal(x))
        }
    }

    instance ToJson[String] {
        pub def toJson(x: String): JsonElement = JsonString(x)
    }

    instance ToJson[List[a]] with ToJson[a] {
        pub def toJson(x: List[a]): JsonElement = {
            let elems = List.map(Json.ToJson.toJson, x) |> List.toVector;
            JsonArray(elems)
        }
    }

    instance ToJson[Vector[a]] with ToJson[a] {
        pub def toJson(x: Vector[a]): JsonElement = {
            let elems = Vector.map(Json.ToJson.toJson, x);
            JsonArray(elems)
        }
    }

    instance ToJson[Map[k, v]] with ToString[k], ToJson[v] {
        pub def toJson(x: Map[k, v]): JsonElement = {
            let map = x
                |> Map.toList
                |> List.map(match (k, v) -> (ToString.toString(k), Json.ToJson.toJson(v)))
                |> List.toMap;
            JsonObject(map)
        }
    }

    instance ToJson[Option[a]] with ToJson[a] {
        pub def toJson(x: Option[a]): JsonElement = match x {
            case Some(y) => JsonArray(Vector#{Json.ToJson.toJson(y)})
            case None => JsonArray(Vector#{})
        }
    }

    instance ToJson[(a, b)] with ToJson[a], ToJson[b] {
        pub def toJson(x: (a, b)): JsonElement = {
            let (a, b) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            JsonArray(Vector#{jsonA, jsonB})
        }
    }

    instance ToJson[(a, b, c)] with ToJson[a], ToJson[b], ToJson[c] {
        pub def toJson(x: (a, b, c)): JsonElement = {
            let (a, b, c) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            let jsonC = Json.ToJson.toJson(c);
            JsonArray(Vector#{jsonA, jsonB, jsonC})
        }
    }

    instance ToJson[(a, b, c, d)] with ToJson[a], ToJson[b], ToJson[c], ToJson[d] {
        pub def toJson(x: (a, b, c, d)): JsonElement = {
            let (a, b, c, d) = x;
            let jsonA = Json.ToJson.toJson(a);
            let jsonB = Json.ToJson.toJson(b);
            let jsonC = Json.ToJson.toJson(c);
            let jsonD = Json.ToJson.toJson(d);
            JsonArray(Vector#{jsonA, jsonB, jsonC, jsonD})
        }
    }

    instance ToJson[JsonElement] {
        pub def toJson(x: JsonElement): JsonElement = x
    }
}
