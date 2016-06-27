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

#[test]
fn test_reserved_token_to_node_string() {
    let token_json_string = r#"{
        "index": 13,
        "word": ":",
        "originalText": ":",
        "lemma": ":",
        "characterOffsetBegin": 40,
        "characterOffsetEnd": 41,
        "pos": ":",
        "before": "",
        "after": " "
        }"#;
    let json_token = Json::from_str(token_json_string).unwrap();
    assert_eq!("type:node identifier:COLON12 index:12 pos:COLON word:COLON original_text:COLON \
                lemma:COLON offset_start:40 offset_end:41 before:empty after:space",
               token_to_node_string(&json_token).unwrap());
}

enum Context {
    Space,
    BigSpace,
    Empty,
    NewLine,
    Unknown,
}

impl fmt::Display for Context {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Context::Space => write!(f, "space"),
            Context::BigSpace => write!(f, "bigspace"),
            Context::Empty => write!(f, "empty"),
            Context::NewLine=> write!(f, "newline"),
            Context::Unknown => write!(f, "unknown"),
        }
    }
}

impl Decodable for Context {
    fn decode<D: Decoder>(d: &mut D) -> Result<Self, D::Error> {
        match d.read_str() {
            Ok(string) => {
                if string.as_str() == " " {
                    Ok(Context::Space)
                } else if string.as_str() == "" {
                    Ok(Context::Empty)
                } else if string.contains("\n") {
                    Ok(Context::NewLine)
                } else if string.trim() == "" {
                    Ok(Context::BigSpace)
                } else {
                    println!("Unknown Token Context ({})", string);
                    Ok(Context::Unknown)
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
                       Token::sanitize(&self.pos),
                       self.index - 1,
                       self.index - 1,
                       Token::sanitize(&self.pos),
                       Token::sanitize(&self.word),
                       Token::sanitize(&self.original_text),
                       Token::sanitize(&self.lemma),
                       self.offsets.0,
                       self.offsets.1,
                       self.before,
                       self.after);
    }

    fn sanitize(string: &String) -> String {
        let mut clean_string = string.clone();
        clean_string = clean_string.replace(":", "COLON");
        clean_string = clean_string.replace("-rrb-", ")");
        clean_string = clean_string.replace("-RRB-", ")");
        clean_string = clean_string.replace("-lrb-", "(");
        clean_string = clean_string.replace("-LRB-", "(");
        clean_string = clean_string.replace("-rsb-", "]");
        clean_string = clean_string.replace("-RSB-", "]");
        clean_string = clean_string.replace("-lsb-", "[");
        clean_string = clean_string.replace("-LSB-", "[");
        clean_string = clean_string.replace("-rcb-", "}");
        clean_string = clean_string.replace("-RCB-", "}");
        clean_string = clean_string.replace("-lcb-", "{");
        clean_string = clean_string.replace("-LCB-", "{");
        return clean_string;
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
