extern crate rustc_serialize;

use std::io::prelude::*;
use std::fs::File;
use std::collections::HashMap;
use rustc_serialize::json::Json;

struct Verb {
    lemma: String,
    frames_patterns: Vec<String>,
}

impl rustc_serialize::Decodable for Verb {
    fn decode<D: rustc_serialize::Decoder>(d: &mut D) -> Result<Self, D::Error> {
        Ok(Verb {
            lemma: try!(d.read_struct_field("verb", 0, |d| rustc_serialize::Decodable::decode(d))),
            frames_patterns: try!(d.read_struct_field("frame_patterns",
                                                      0,
                                                      |d| rustc_serialize::Decodable::decode(d))),
        })
    }
}

pub fn verb_index() -> HashMap<String, Vec<String>> {
    let mut f = File::open("verb_index.json").unwrap();
    let mut contents = String::new();
    if f.read_to_string(&mut contents).is_err() {
        panic!("There was a problem building the list of verbs.")
    }

    let mut index: HashMap<String, Vec<String>> = HashMap::new();
    for raw_verb in Json::from_str(&contents).unwrap().as_array().unwrap() {
        let verb: Verb = rustc_serialize::json::decode(format!("{}", raw_verb).as_str()).unwrap();
        index.insert(verb.lemma, verb.frames_patterns);
    }

    return index;
}

#[test]
fn load_verb_index() {
    let index = verb_index();
    let test = index.get("test").unwrap();
    assert_eq!(test,
               &vec![String::from("NP VERB NP PREP NP"), String::from("NP VERB NP")]);
}
