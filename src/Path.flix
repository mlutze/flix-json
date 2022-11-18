namespace Json/Path {
    use Json.JsonElement.JsonArray;
    use Json.JsonElement.JsonObject;
    use Json.JsonElement;
    use Json/Utils.escape;

    ///
    /// Represents a JSON Path
    ///
    pub enum Path with Eq {
        case Root
        case AtIndex(Path, Int32)
        case AtKey(Path, String)
    }

    instance ToString[Path] {
        pub def toString(x: Path): String = match x {
            case Root => "$"
            case AtIndex(base, i) => "${base}[${i}]"
            case AtKey(base, key) => "${base}[${escape(key)}]"
        }
    }

    sealed class Appendable[a] {
        pub def append(x: a, p: Path): Path
    }

    instance Appendable[Int32] {
        pub def append(x: Int32, p: Path): Path = atIndex(x, p)
    }

    instance Appendable[String] {
        pub def append(x: String, p: Path): Path = atKey(x, p)
    }

    //
    // Appends the index or key to the path.
    //
    pub def !!(p: Path, x: a): Path with Appendable[a] = Json/Path/Appendable.append(x, p)

    ///
    /// Appends an index to the path.
    ///
    pub def atIndex(i: Int32, p: Path): Path = AtIndex(p, i)

    ///
    /// Appends a key to the path.
    ///
    pub def atKey(k: String, p: Path): Path = AtKey(p, k)

    ///
    /// Retrieves the element at the given JSON path.
    ///
    pub def apply(p: Path, json: JsonElement): Option[JsonElement] = {
        use Option.flatMap;
        match p {
            case Root => Some(json)
            case AtIndex(root, i) =>
                let* next = apply(root, json);
                match next {
                    case JsonArray(l) => nth(i, l)
                    case _ => None
                }
            case (AtKey(root, key)) =>
                let* next = apply(root, json);
                match next {
                    case JsonObject(m) => Map.get(key, m)
                    case _ => None
                }
        }
    }

    ///
    /// Returns the nth element in the given list.
    ///
    def nth(n: Int32, l: List[a]): Option[a] = match (n, l) {
        case (0, hd :: _) => Some(hd)
        case (_, _ :: tl) if n > 0 => nth(n - 1, tl)
        case _ => None
    }
}