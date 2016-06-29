extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;
extern crate iron;
extern crate router;
extern crate encoding;
extern crate regex;

#[macro_use]
mod macros;
mod core_nlp;
mod graph_parser;
mod points;
mod frames;
mod formatting;
mod validate;
mod verbs;
mod sanitize;

use std::io::Read;
use std::collections::HashMap;
use graph_match::graph::Graph;
use iron::prelude::*;
use iron::status;
use router::Router;
use rustc_serialize::json;

use graph_match::matching::EqualityRequirement;

#[derive(RustcEncodable)]
struct Point {
    frame: String,
    pattern: String,
    extract: String,
}

fn main() {
    let frames = frames::frame_index();
    let verbs = verbs::verb_index();
    let banned_edges: Vec<String> = vec![String::from("advcl"), String::from("csubj"), String::from("ccomp"), String::from("dep"), String::from("parataxis")];
    let copula_verbs: Vec<String> = vec![
        String::from("act"), String::from("appear"), String::from("be"), String::from("become"), String::from("come"),
        String::from("end"), String::from("get"), String::from("go"), String::from("grow"), String::from("fall"), String::from("feel"),
        String::from("keep"), String::from("look"), String::from("prove"), String::from("remain"), String::from("run"), String::from("seem"),
        String::from("smell"), String::from("sound"), String::from("stay"), String::from("taste"), String::from("turn"), String::from("wax")
    ];

    let mut router = Router::new();
    router.post("/points", move |r: &mut Request| handle(r, &frames, &verbs, &banned_edges, &copula_verbs));

    Iron::new(router).http("0.0.0.0:3456").unwrap();
    println!("Listening on 3456");
}

fn handle(request: &mut Request,
          frames: &HashMap<String, (usize, Graph)>,
          verbs: &HashMap<String, Vec<String>>,
          banned_edges: &Vec<String>,
          copula_verbs: &Vec<String>) -> IronResult<Response> {
    let mut text: String = String::new();
    if request.body.read_to_string(&mut text).is_err() {
        let response: IronResult<Response> = Ok(Response::with((status::InternalServerError, "Failed to read the request body.")));
        return response;
    }

    match sanitize::force_ascii(&text) {
        Ok(clean_text) => text = clean_text,
        Err(error) => {
            let response: IronResult<Response> = Ok(Response::with((status::InternalServerError, error)));
            return response;
        }
    }

    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => {
            let message = format!("There was an error in building the graph string ({})", message);
            let response: IronResult<Response> = Ok(Response::with((status::InternalServerError, message)));
            return response;
        }
    };

    let mut points: Vec<Point> = Vec::new();

    for g in string_graphs {
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph:\n\n{}\n\nfailed with the following message: {}", g, message);
                continue;
            }
        };

        let verb_indices = match points::find_verbs(&graph) {
            Some(indices) => indices,
            None => {
                println!("There were no verbs.");
                continue;
            }
        };

        let queries = match points::build_queries(&verb_indices, &graph, &verbs, &frames, &copula_verbs) {
            Some(queries) => queries,
            None => {
                println!("No queries could be generated.");
                continue;
            }
        };

        for query in queries {
            match frames.get(&query.1) {
                Some(frame) => {
                    for matched_components in graph_match::match_graph(&frame.1, frame.0, &graph, query.0, &EqualityRequirement::Contains) {
                        let root_node_index = matched_components.list[0].node;
                        let node_indexes = graph_match::expand_subgraph(&graph, root_node_index, &banned_edges);

                        let pattern = points::matched_components_to_pattern(&matched_components, &graph);
                        let extract = points::subgraph_nodes_to_extract_string(&node_indexes, &graph);

                        let pattern = formatting::pattern(pattern);

                        if validate::pattern(&pattern) {
                            points.push(Point {
                                frame: query.1.clone(),
                                pattern: pattern,
                                extract: extract,
                            });
                        }
                    }
                },
                None => println!("Previously matched frame now missing."),
            }
        }
    }

    match json::encode(&points) {
        Ok(string) => {
            let response: IronResult<Response> = Ok(Response::with((status::Ok, string)));
            return response
        },
        Err(_) => {
            let response: IronResult<Response> = Ok(Response::with((status::InternalServerError, "failed to encode points as json")));
            return response
        }

    }
}
