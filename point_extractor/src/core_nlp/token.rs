extern crate rustc_serialize;

use std::fmt;
use rustc_serialize::json::Json;
use rustc_serialize::{Decodable, Decoder};

pub fn token_to_node_string(token: &Json) -> Result<String, String> {
    let token: Token = match rustc_serialize::json::decode(&format!("{}", token)) {
        Ok(token) => token,
        Err(message) => return Err(format!("Json decode error ({})", message)),
    };
    return Ok(token.to_node_string());
}

#[test]
fn test_token_to_node_string() {
    let token_json_string = r#"{
        "index": 3,
        "word": "another",
        "originalText": "another",
        "lemma": "another",
        "characterOffsetBegin": 40,
        "characterOffsetEnd": 47,
        "pos": "DT",
        "before": " ",
        "after": " "
        }"#;
    let json_token = Json::from_str(token_json_string).unwrap();
    assert_eq!("type:node identifier:DT2 index:2 pos:DT word:another original_text:another \
                lemma:another offset_start:40 offset_end:47 before:space after:space",
               token_to_node_string(&json_token).unwrap());
}

enum Context {
    Space,
    Empty,
    Unknown,
}

impl fmt::Display for Context {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Context::Space => write!(f, "space"),
            Context::Empty => write!(f, "empty"),
            Context::Unknown => write!(f, "unknown"),
        }
    }
}

impl Decodable for Context {
    fn decode<D: Decoder>(d: &mut D) -> Result<Self, D::Error> {
        match d.read_str() {
            Ok(string) => {
                match string.as_str() {
                    " " => Ok(Context::Space),
                    "" => Ok(Context::Empty),
                    _ => { println!("Unknown Context: {}", string); Ok(Context::Unknown) }
                }
            },
            Err(error) => return Err(error),
        }
    }
}


struct Token {
    index: usize,
    pos: String,
    word: String,
    original_text: String,
    lemma: String,
    offsets: (usize, usize),
    before: Context,
    after: Context,
}

impl Token {
    fn to_node_string(&self) -> String {
        return format!("type:node identifier:{}{} index:{} pos:{} word:{} \
                       original_text:{} lemma:{} offset_start:{} \
                       offset_end:{} before:{} after:{}",
                       self.pos,
                       self.index - 1,
                       self.index - 1,
                       self.pos,
                       self.word,
                       self.original_text,
                       self.lemma,
                       self.offsets.0,
                       self.offsets.1,
                       self.before,
                       self.after);
    }
}

impl rustc_serialize::Decodable for Token {
    fn decode<D: rustc_serialize::Decoder>(d: &mut D) -> Result<Self, D::Error> {
        Ok(Token {
            index: try!(d.read_struct_field("index", 0, |d| rustc_serialize::Decodable::decode(d))),
            word: try!(d.read_struct_field("word", 0, |d| rustc_serialize::Decodable::decode(d))),
            pos: try!(d.read_struct_field("pos", 0, |d| rustc_serialize::Decodable::decode(d))),
            original_text: try!(d.read_struct_field("originalText",
                                                    0,
                                                    |d| rustc_serialize::Decodable::decode(d))),
            lemma: try!(d.read_struct_field("lemma", 0, |d| rustc_serialize::Decodable::decode(d))),
            offsets: (try!(d.read_struct_field("characterOffsetBegin",
                                               0,
                                               |d| rustc_serialize::Decodable::decode(d))),
                      try!(d.read_struct_field("characterOffsetEnd",
                                               0,
                                               |d| rustc_serialize::Decodable::decode(d)))),
            before:
                try!(d.read_struct_field("before", 0, |d| rustc_serialize::Decodable::decode(d))),
            after: try!(d.read_struct_field("after", 0, |d| rustc_serialize::Decodable::decode(d))),
        })
    }
}
