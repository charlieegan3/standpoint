extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

mod core_nlp;
mod graph_parser;
mod presentation;
mod frames;
mod verbs;

use graph_match::matching::EqualityRequirement;

fn main() {
    let frames = frames::frame_index();
    let verbs = verbs::verb_index();
    let banned_edges: Vec<String> = vec![String::from("advcl"), String::from("csubj"), String::from("ccomp"), String::from("dep"), String::from("parataxis")];

    let text = "The man ran home, he eat his food. He climbed the stairs.".to_string();
    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => panic!("There was an error in building the graph string representation ({})", message),
    };

    for g in string_graphs {
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph:\n\n{}\n\nfailed with the following message: {}", g, message);
                continue;
            }
        };

        let mut verb_indices: Vec<usize> = Vec::new();
        for node_index in 0..graph.nodes.len() {
            match graph.nodes[node_index].attributes {
                Some(ref attrs) => {
                    match attrs.get("pos") {
                        Some(pos) => {
                            if pos.contains("VB") {
                                verb_indices.push(node_index);
                            }
                        },
                        None => println!("Node {} was missing a POS.", node_index)
                    }
                },
                None => println!("Node {} was missing attributes.", node_index),
            }
        };

        let mut queries: Vec<(usize, String)> = Vec::new();
        for verb_index in verb_indices {
            match graph.nodes[verb_index].attributes {
                Some(ref attrs) => {
                    match attrs.get("lemma") {
                        Some(lemma) => {
                            match verbs.get(lemma) {
                                Some(pattern) => {
                                    match frames.get(pattern) {
                                        Some(_) => {
                                            queries.push((verb_index, pattern.clone()))
                                        },
                                        None => println!("{} has no match in the frame index.", pattern),
                                    }
                                },
                                None => println!("{} is not in the verb index", lemma),
                            }
                        },
                        None => println!("verb was missing a lemma."),
                    }
                },
                None => println!("Node previously matched on attrs is now missing attrs."),
            }
        };

        for query in queries {
            match frames.get(&query.1) {
                Some(frame) => {
                    println!("Pattern: {}", query.1);
                    for matched_components in graph_match::match_graph(&frame.1, frame.0, &graph, Some(query.0), &EqualityRequirement::Contains) {
                        println!("{:?}", presentation::matched_components_to_pattern(&matched_components, &graph));
                        let root_node_index = matched_components.list[0].node;
                        let node_indexes = graph_match::expand_subgraph(&graph, root_node_index, &banned_edges);
                        println!("{:?}", presentation::subgraph_nodes_to_extract_string(&node_indexes, &graph));
                    }
                },
                None => println!("Previously matched frame now missing."),
            }
        }
        print!("\n");
    }
}
