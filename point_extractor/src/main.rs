extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;
extern crate iron;
extern crate router;

#[macro_use]
mod macros;
mod core_nlp;
mod graph_parser;
mod points;
mod frames;
mod verbs;

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

    let mut router = Router::new();
    router.post("/points", move |r: &mut Request| handle(r, &frames, &verbs, &banned_edges));

    Iron::new(router).http("0.0.0.0:3456").unwrap();
    println!("Listening on 3456");
}

fn handle(request: &mut Request, frames: &HashMap<String, (usize, Graph)>, verbs: &HashMap<String, Vec<String>>, banned_edges: &Vec<String>) -> IronResult<Response> {
    let mut text: String = String::new();
    if request.body.read_to_string(&mut text).is_err() {
        let response: IronResult<Response> = Ok(Response::with((status::InternalServerError, "Failed to read the request body.")));
        return response;
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

        let queries = match points::build_queries(&verb_indices, &graph, &verbs, &frames) {
            Some(queries) => queries,
            None => {
                println!("No queries could be generated.");
                continue;
            }
        };

        for query in queries {
            match frames.get(&query.1) {
                Some(frame) => {
                    for matched_components in graph_match::match_graph(&frame.1, frame.0, &graph, Some(query.0), &EqualityRequirement::Contains) {
                        let root_node_index = matched_components.list[0].node;
                        let node_indexes = graph_match::expand_subgraph(&graph, root_node_index, &banned_edges);

                        let point = Point {
                            frame: query.1.clone(),
                            pattern: points::matched_components_to_pattern(&matched_components, &graph),
                            extract: points::subgraph_nodes_to_extract_string(&node_indexes, &graph),
                        };
                        points.push(point);
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
