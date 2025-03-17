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
