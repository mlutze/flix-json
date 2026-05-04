pub mod Json.Jsonable {
    use Json.FromJson
    use Json.JsonElement
    use Json.ToJson

    pub lawful trait Jsonable[a] with ToJson[a], FromJson[a] {
        law inverse: forall (x: a) with Eq[a] {
            x |> Json.ToJson.toJson |> Json.FromJson.fromJson == Ok(x)
        }
    }

    instance Jsonable[Bool]

    instance Jsonable[Char]

    instance Jsonable[BigDecimal]

    instance Jsonable[Int8]

    instance Jsonable[Int16]

    instance Jsonable[Int32]

    instance Jsonable[Int64]

    instance Jsonable[BigInt]

    instance Jsonable[String]

    instance Jsonable[List[a]] with Jsonable[a]

    instance Jsonable[Vector[a]] with Jsonable[a]

    instance Jsonable[Map[k, v]] with ToString[k], FromString[k], Order[k], ToJson[v], FromJson[v]

    instance Jsonable[Option[a]] with FromJson[a], ToJson[a]

    instance Jsonable[(a, b)] with Jsonable[a], Jsonable[b]

    instance Jsonable[(a, b, c)] with Jsonable[a], Jsonable[b], Jsonable[c]

    instance Jsonable[(a, b, c, d)] with Jsonable[a], Jsonable[b], Jsonable[c], Jsonable[d]

    instance Jsonable[JsonElement]
}
