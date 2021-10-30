namespace TestMain {
  use Main.parse;
  use Main.JsonElement.{JsonObject, JsonArray, JsonString, JsonNumber, JsonBool, JsonNull};
  
  @test
  def testEmptyObject01(): Bool = parse("{}") == Some(JsonObject(Map#{}))

  @test
  def testEmptyObject02(): Bool = parse("    {    }    ") == Some(JsonObject(Map#{}))

}