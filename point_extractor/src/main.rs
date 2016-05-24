extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

mod core_nlp;
mod graph_parser;

use graph_match::matching::EqualityRequirement;
use graph_match::graph::Graph;

fn matched_components_to_pattern(matched_components: &graph_match::matching::MatchedComponents, graph: &Graph) -> String {
    let mut pattern: Vec<(usize, String)> = Vec::new();

    for component in &matched_components.list {
        let mut label = String::new();
        match component.from_edge {
            Some(edge) => label.push_str(&graph.edges[edge].identifier.as_str()),
            None => label.push_str("root"),
        }
        label.push_str(".");
        match graph.nodes[component.node].attributes {
            Some(ref attrs) => {
                match attrs.get("lemma") {
                    Some(lemma) => label.push_str(lemma.as_str()),
                    None => label.push_str("BLANK"),
                }
            },
            None => label.push_str("BLANK"),
        }
        pattern.push((component.node, label));
    }

    pattern.sort_by(|a,b| a.0.cmp(&b.0));
    return pattern.iter().map(|e| e.1.clone() ).collect::<Vec<String>>().join(" ");
}

fn subgraph_nodes_to_extract_string(node_indexes: &Vec<usize>, graph: &Graph) -> String {
    let mut extract_string = String::new();
    let mut sorted_node_indexes = node_indexes.clone();
    sorted_node_indexes.sort_by(|a, b| a.cmp(b));
    for index in sorted_node_indexes {
        match graph.nodes[index].attributes {
            Some(ref attrs) => {
                match attrs.get("before") {
                    Some(value) => {
                        match value.as_str() {
                            "space" => extract_string.push_str(" "),
                            "empty" => extract_string.push_str(""),
                            "unknown" => extract_string.push_str("?"),
                            _ => extract_string.push_str("???"),
                        }
                    }
                    _ => {}
                }
                match attrs.get("word") {
                    Some(value) => extract_string.push_str(value.as_str()),
                    _ => {}
                }
                match attrs.get("after") {
                    Some(value) => {
                        match value.as_str() {
                            "space" => extract_string.push_str(" "),
                            "empty" => extract_string.push_str(""),
                            "unknown" => extract_string.push_str("?"),
                            _ => extract_string.push_str("???"),
                        }
                    }
                    _ => {}
                }
            },
            None => {}
        };
    }
    return extract_string.replace("  ", " ");
}

fn main() {
    let text = "The man ran home, the man eat the food.".to_string();
    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => panic!("There was an error in building the graph string representation ({})", message),
    };

    let query_string = "type:node identifier:subj pos:NN\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj pos:NN\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj";
    let query = graph_parser::parse(&query_string.to_string()).unwrap();

    for g in string_graphs {
        println!("Graph:\n{}", g);
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph: {}, failed with the following message: {}", g, message);
                continue;
            }
        };

        let banned_edges: Vec<String> = vec!["advcl".to_string(), "csubj".to_string(), "ccomp".to_string(), "dep".to_string(), "parataxis".to_string()];
        println!("Points");
        for matched_components in graph_match::match_graph(&query, 1, &graph, &EqualityRequirement::Contains) {
            println!("{:?}", matched_components_to_pattern(&matched_components, &graph));
            let root_node_index = matched_components.list[0].node;
            let node_indexes = graph_match::expand_subgraph(&graph, root_node_index, &banned_edges);
            println!("{:?}", subgraph_nodes_to_extract_string(&node_indexes, &graph));
        }
    }
}
