pub fn parse_args(input: &String) -> Option<Vec<&str>> {
    let res = input.trim().split_whitespace().collect::<Vec<&str>>();
    if res.len() <= 1 {
        None
    } else {
        Some(res[2..].to_vec())
    }
}
