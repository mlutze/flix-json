mod TestReadme {
    use Json.ToJson
    use Json.FromJson;
    use Json.FromJson.fromJsonAt;
    use Json.Path.Path;
    use Json.JsonElement;
    use Json.JsonError;
    use Json.getAtKey;
    use Json.getAtKeyOpt;
    use Json.Path.{!!};

    enum Person({
        name = String,
        age = Int32,
        city = String,
        zip = String,
        contact = Contact
    })

    enum Contact({
        email = String,
        phone = String
    })

    instance FromJson[Contact] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Contact] = {
            forM (
                map <- fromJsonAt(p, x);
                email <- getAtKey(p, "email", map);
                phone <- getAtKey(p, "phone", map)
            ) yield {
                Contact.Contact({ email = email, phone = phone })
            }
        }
    }


    instance FromJson[Person] {
        pub def fromJsonAt(p: Path, x: JsonElement): Result[JsonError, Person] = {
            forM (
                map <- fromJsonAt(p, x);
                name <- getAtKey(p, "name", map);
                age <- getAtKey(p, "age", map);
                addressMap <- getAtKey(p, "address", map);
                city <- getAtKey(p !! "address", "city", addressMap);
                zip <- getAtKey(p !! "address", "zip", addressMap);
                contact <- getAtKey(p, "contact", map)
            ) yield {
                Person.Person({
                    name = name,
                    age = age,
                    city = city,
                    zip = zip,
                    contact = contact
                })
            }
        }
    }

    instance ToJson[Contact] {
        pub def toJson(x: Contact): JsonElement = {
            let Contact.Contact(record) = x;
            let map = Map#{
                "email" => record#email,
                "phone" => record#phone
            };
            ToJson.toJson(map)
        }
    }

    instance ToJson[Person] {
        pub def toJson(x: Person): JsonElement = {
            let Person.Person(record) = x;
            let addressMap = Map#{
                "city" => record#city,
                "zip" => record#zip
            };
            let map = Map#{
                "name" => ToJson.toJson(record#name),
                "age" => ToJson.toJson(record#age),
                "address" => ToJson.toJson(addressMap),
                "contact" => ToJson.toJson(record#contact)
            };
            ToJson.toJson(map)
        }
    }
    
    

    @Test
    def testReadmeParse(): Bool = {
        let string = "{\r\n  \"name\": \"Alice\",\r\n  \"age\": 30,\r\n  \"address\": {\r\n    \"city\": \"New York\",\r\n    \"zip\": \"10001\"\r\n  },\r\n  \"contact\": {\r\n    \"email\": \"alice@example.com\",\r\n    \"phone\": \"123-456-7890\"\r\n  }\r\n}";
        let resOpt = forM (
            json <- Json.Parse.parse(string);
            Person.Person(record) <- FromJson.fromJson(json) |> Result.toOption;
            Contact.Contact(contact) = record#contact
        ) yield {
            record#age == 30
            and record#name == "Alice"
            and record#zip == "10001"
            and record#city == "New York"
            and contact#email == "alice@example.com"
            and contact#phone == "123-456-7890"
        };
        Option.getWithDefault(false, resOpt)
    }
}