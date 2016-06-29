use regex::Regex;

pub fn pattern(pattern: String) -> String {
    let pattern = pattern.to_lowercase();
    let pattern = merge_person_nouns(pattern);
    let pattern = String::from(pattern.trim());
    return pattern;
}

fn merge_person_nouns(pattern: String) -> String {
    let re = Regex::new(r"(^|\s)(i|you|me|who|we|you|yourself|they|them|he|she|person|people).\w+(\s|$)").unwrap();
    return re.replace_all(pattern.as_str(), " PERSON.noun ");
}
