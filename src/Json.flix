namespace Json {
    pub enum JsonElement {
        case JsonObject(Map[String, JsonElement])
        case JsonArray(List[JsonElement])
        case JsonString(String)
        case JsonNumber(BigDecimal)
        case JsonBool(Bool)
        case JsonNull
    }

    instance Eq[JsonElement] {
        pub def eq(x: JsonElement, y: JsonElement): Bool = match (x, y) {
            case (JsonObject(a), JsonObject(b)) => a == b
            case (JsonArray(a), JsonArray(b)) => a == b
            case (JsonString(a), JsonString(b)) => a == b
            case (JsonNumber(a), JsonNumber(b)) => a == b
            case (JsonBool(a), JsonBool(b)) => a == b
            case (JsonNull, JsonNull) => true
            case _ => false
        }
    }
}