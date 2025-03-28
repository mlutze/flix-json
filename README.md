# flix-json

A basic JSON parser in pure Flix.

Note: The current implementation is naive (not tail-recursive, not lazily evaluated).


## Usage

There are essentially three components to the interface:

1. `Json.Parse` for reading JSON from a string
2. `Jsonable.ToJson` and `Jsonable.FromJson` for converting `JsonElement` to and from a given data type
3. `Json.Write` for writing a `JsonElement` to a string

### Reading

To read a custom data type, we can define an instance of `Jsonable.FromJson`.
Suppose we have a JSON object and its corresponding data type.

```json
{
  "name": "Alice",
  "age": 30,
  "address": {
    "city": "New York",
    "zip": "10001"
  },
  "contact": {
    "email": "alice@example.com",
    "phone": "123-456-7890"
  }
}
```

```scala
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
```

To convert from JSON to our enum,
we need to define a `FromJson` instance for our data types.

First, `Contact`:

```scala
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
```

The `FromJson` trait has one required signature, `fromJsonAt`.
It takes two parameters:
- A `Path` representing the path in the JSON tree we have traversed so far. This is used for reporting errors.
- A `JsonElement` as the input.

In the implementation, we make use of two functions:
- `Jsonable.fromJsonAt`, to convert the `JsonElement` into a map for easier manipulation
- `Jsonable.getAtKey` to extract fields from the map

We don't need to say what types we expect from the JsonElement due to type inference.
The types in the `Contact` constructor ensure the right types are expected at runtime.

The `Person` instance will make use of the `Contact` instance:

```scala
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
```

The "city" and "zip" fields are nested in the JSON representation,
but are not nested in the Flix representation.
When extracting them from the JSON,
we first extract the nested object as `addressMap`,
then access each field from that map.
We append `"address"` to the path parameter,
which ensures proper error messages
in case the JSON does not match what we expect.

### Writing

To convert a Flix data type to JSON,
we just need to define a `ToJson` instance for it.
First, `Contact`:

```scala
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
```

Here, we do the opposite of what we did before.
We just construct a map and put the fields in it.
Then we convert the map to a JSON element.

We can do the same with `Person`.

```
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
```

This mirrors what we did for `FromJson`.
We constructed a separate `addressMap`
since that's present in the JSON
but not in the data definition.
We had to call `toJson` on all the fields as we built the map,
because not all the fields have the same type.

These classes give us a `JsonElement`.
We can convert the result to a string by using
`Json.Write.toCompactString` or `Json.Write.toPrettyString`.