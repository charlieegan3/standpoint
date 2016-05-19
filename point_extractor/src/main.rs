extern crate graph_match;
extern crate hyper;

use hyper::Url;
use hyper::client::Request;
use std::io::Read;

fn main() {
    let mut url = Url::parse("http://corenlp_server:9000").unwrap();
    url.query_pairs_mut().append_pair("properties", "{\"annotators\": \"lemma,tokenize,ssplit,depparse\"}");
    println!("{}", url.as_str());

    let client = hyper::Client::new();

    let mut res = client.post(url.as_str())
        .body("This is a sentence about a dog.")
        .send()
        .unwrap();

    let mut body = String::new();
    res.read_to_string(&mut body);
    println!("{}", body);
}
