namespace Json {
  pub enum JsonElement with Eq {
    case JsonObject(Map[String, JsonElement])
    case JsonArray(List[JsonElement])
    case JsonString(String)
    case JsonInt(Int32)
    case JsonFloat(Float64)
    case JsonBool(Bool)
    case JsonNull
  }
}