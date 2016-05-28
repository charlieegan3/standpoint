use std::collections::HashMap;

pub fn verb_index() -> HashMap<String, String> {
    let mut index: HashMap<String, String> = HashMap::new();
    index.insert(String::from("run"), String::from("NP VERB NP"));
    index.insert(String::from("eat"), String::from("NP VERB NP"));
    index.insert(String::from("climb"), String::from("NP VERB NP"));
    return index;
}
