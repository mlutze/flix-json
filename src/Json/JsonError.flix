pub mod Json.JsonError {
    use Json.Path;

    pub enum JsonError(Path, Set[String]) with Eq
}
