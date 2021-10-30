namespace TestMain {
  use Main.parse;
  use Main.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull};
  
  @test
  def testEmptyObject01(): Bool = parse("{}") == Some(JsonObject(Map#{}))

  @test
  def testEmptyObject02(): Bool = parse("    {    }    ") == Some(JsonObject(Map#{}))

  @test
  def testSingletonObject01(): Bool = parse("{\"key\": \"value\"}") == Some(JsonObject(Map#{"key" ->  JsonString("value")}))

  @test
  def testDoubleObject01(): Bool = 
    parse("{\"key1\": \"value1\", \"key2\": \"value2\"}") == Some(JsonObject(Map#{"key1" -> JsonString("value1"), "key2" -> JsonString("value2")}))
}