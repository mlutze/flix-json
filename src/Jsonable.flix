namespace Json {
    import java.math.BigDecimal

    pub class Jsonable[a] {
        pub def toJson(x: a): JsonElement
        pub def fromJson(x: JsonElement): Option[a]
    }

    instance Jsonable[Bool] {
        pub def toJson(x: Bool): JsonElement = JsonBool(x)

        pub def fromJson(x: JsonElement): Option[Bool] = match x {
            case JsonBool(y) => Some(y)
            case _ => None
        }
    }

    instance Jsonable[Char] {
        pub def toJson(x: Char): JsonElement = JsonString(Char.toString(x))
    
        pub def fromJson(x: JsonElement): Option[Char] = match x {
            case JsonString(y) if String.length(y) > 0 => Some(String.charAt(0, y))
            case _ => None
        }
    }

    instance Jsonable[Float32] {
        pub def toJson(x: Float32): JsonElement = {
            import static java.math.BigDecimal.valueOf(Float64): BigDecimal \ {};
            let y = valueOf(Float32.toFloat64(x));
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Float32] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.floatValue(): Float32 \ {};
                Some(floatValue(y))
            case _ => None
        }
    }

    instance Jsonable[Float64] {
    
        pub def toJson(x: Float64): JsonElement = {
            import static java.math.BigDecimal.valueOf(Float64): BigDecimal \ {};
            let y = valueOf(x);
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Float64] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.doubleValue(): Float64 \ {};
                Some(doubleValue(y))
            case _ => None
        }
    
    }

    instance Jsonable[Int8] {
        pub def toJson(x: Int8): JsonElement = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            let y = valueOf(Int8.toInt64(x));
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Int8] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.byteValueExact(): Int8 \ {};
                try {
                    Some(byteValueExact(y))
                } catch {
                    case _: ##java.lang.ArithmeticException => None
                }
            case _ => None
        }
    }
    
    instance Jsonable[Int16] {
        pub def toJson(x: Int16): JsonElement = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            let y = valueOf(Int16.toInt64(x));
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Int16] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.shortValueExact(): Int16 \ {};
                try {
                    Some(shortValueExact(y))
                } catch {
                    case _: ##java.lang.ArithmeticException => None
                }
            case _ => None
        }
    }

    instance Jsonable[Int32] {
        pub def toJson(x: Int32): JsonElement = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            let y = valueOf(Int32.toInt64(x));
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Int32] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.intValueExact(): Int32 \ {};
                try {
                    Some(intValueExact(y))
                } catch {
                    case _: ##java.lang.ArithmeticException => None
                }
            case _ => None
        }
    }
    
    instance Jsonable[Int64] {
        pub def toJson(x: Int64): JsonElement = {
            import static java.math.BigDecimal.valueOf(Int64): BigDecimal \ {};
            let y = valueOf(x);
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[Int64] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.longValueExact(): Int64 \ {};
                try {
                    Some(longValueExact(y))
                } catch {
                    case _: ##java.lang.ArithmeticException => None
                }
            case _ => None
        }
    }

    instance Jsonable[BigInt] {
        pub def toJson(x: BigInt): JsonElement = {
            import new java.math.BigDecimal(BigInt): BigDecimal \ {} as valueOf;
            let y = valueOf(x);
            JsonNumber(y)
        }
    
        pub def fromJson(x: JsonElement): Option[BigInt] = match x {
            case JsonNumber(y) =>
                import java.math.BigDecimal.toBigIntegerExact(): BigInt \ {};
                try {
                    Some(toBigIntegerExact(y))
                } catch {
                    case _: ##java.lang.ArithmeticException => None
                }
            case _ => None
        }
    }

    instance Jsonable[String] {
        pub def toJson(x: String): JsonElement = JsonString(x)

        pub def fromJson(x: JsonElement): Option[String] = match x {
            case JsonString(y) => Some(y)
            case _ => None
        }

    }

    instance Jsonable[List[a]] with Jsonable[a] {
        pub def toJson(x: List[a]): JsonElement = {
            let elems = List.map(Json/Jsonable.toJson, x);
            JsonArray(elems)
        }

        pub def fromJson(x: JsonElement): Option[List[a]] = match x {
            case JsonArray(l) => Option.traverse(Json/Jsonable.fromJson, l)
            case _ => None
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

        pub def fromJson(x: JsonElement): Option[Map[k, v]] = match x {
            case JsonObject(m0) =>
                use Option.flatMap;
                let l0 = Map.toList(m0);
                let* l = l0 |> Option.traverse(match (k0, v0) -> 
                    let* k = FromString.fromString(k0);
                    let* v = Json/Jsonable.fromJson(v0);
                    Some(k, v)
                );
                Some(List.toMap(l))
            case _ => None
        }
    }

    instance Jsonable[Option[a]] with Jsonable[a] {
        pub def toJson(x: Option[a]): JsonElement = match x {
            case Some(y) => Json/Jsonable.toJson(y)
            case None => JsonNull
        }
    
        pub def fromJson(x: JsonElement): Option[Option[a]] = match x {
            case JsonNull => Some(None)
            case json => {
                use Option.flatMap;
                let* y = Json/Jsonable.fromJson(json);
                Some(Some(y))
            }
        }
    }

    instance Jsonable[JsonElement] {
        pub def toJson(x: JsonElement): JsonElement = x

        pub def fromJson(x: JsonElement): Option[JsonElement] = Some(x)
    }
}