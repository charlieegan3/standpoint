extern crate hyper;

use std::io::Read;
use hyper::Url;
use rustc_serialize::json::Json;
use rustc_serialize::json::Array;

pub mod token;
pub mod dependency;

pub fn graphs_for_text(text: &String) -> Result<Vec<String>, String> {
    let body = match get_corenlp_response(&text) {
        Ok(body) => body,
        Err(message) => return Err(format!("Failed to fetch parse ({})", message)),
    };
    let sentences = match parse_sentences(&body) {
        Ok(s) => s,
        Err(message) => return Err(format!("Failed to parse sentences ({})", message)),
    };
    let mut graphs: Vec<String> = Vec::new();
    for s in sentences {
        let mut sentence_graph_text: Vec<String> = Vec::new();
        for t in s.0 {
            match token::token_to_node_string(&t) {
                Ok(string) => sentence_graph_text.push(string),
                Err(message) => return Err(format!("Failed to parse token. ({})", message)),
            }
        }
        for t in s.1 {
            match dependency::dependency_to_edge_string(&t) {
                Ok(string) => sentence_graph_text.push(string),
                Err(message) => return Err(format!("Failed to parse dependency. ({})", message)),
            }
        }
        graphs.push(sentence_graph_text.join("\n"))
    }
    return Ok(graphs);
}

fn get_corenlp_response(text: &String) -> Result<String, hyper::error::Error> {
    let mut url = Url::parse("http://corenlp_server:9000").unwrap();
    url.query_pairs_mut().append_pair("properties",
                                      "{\"annotators\": \"lemma,tokenize,ssplit,depparse\"}");
    let client = hyper::Client::new();
    let mut res = try!(client.post(url.as_str()).body(text).send());
    let mut body = String::new();
    try!(res.read_to_string(&mut body));

    return Ok(body);
}

fn parse_sentences(body: &String) -> Result<Vec<(Array, Array)>, String> {
    let json = match Json::from_str(&body) {
        Ok(json) => json,
        Err(error) => return Err(format!("Failed parse JSON response. ({}) ({})", error, body)),
    };

    let raw_sentences = match json.find_path(&["sentences"]) {
        Some(raw_sentences) => {
            match raw_sentences.as_array() {
                Some(array) => array,
                None => return Err("Failed to parse sentence array.".to_string()),
            }
        }
        None => return Err("Missing Sentences Key".to_string()),
    };

    let mut sentences: Vec<(Array, Array)> = Vec::new();

    for s in raw_sentences {
        match s.as_object() {
            Some(object) => {
                let tokens = match object.get("tokens") {
                    Some(t) => {
                        match t.as_array() {
                            Some(array) => array,
                            None => return Err("Failed to parse token array".to_string()),
                        }
                    }
                    None => return Err("Missing tokens".to_string()),
                };
                let dependencies = match object.get("basic-dependencies") {
                    Some(d) => {
                        match d.as_array() {
                            Some(array) => array,
                            None => return Err("Failed to parse dependencies array".to_string()),
                        }
                    }
                    None => return Err("Missing dependencies".to_string()),
                };
                sentences.push((tokens.clone(), dependencies.clone()));
            }
            None => return Err("Failed to parse sentence into object.".to_string()),
        };
    }
    return Ok(sentences);
}
