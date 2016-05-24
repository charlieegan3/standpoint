extern crate graph_match;

use graph_match::graph::Graph;

pub fn matched_components_to_pattern(matched_components: &graph_match::matching::MatchedComponents, graph: &Graph) -> String {
    let mut pattern: Vec<(usize, String)> = Vec::new();

    for component in &matched_components.list {
        let mut label = String::new();
        match graph.nodes[component.node].attributes {
            Some(ref attrs) => {
                match attrs.get("lemma") {
                    Some(lemma) => label.push_str(lemma.as_str()),
                    None => label.push_str("BLANK"),
                }
            },
            None => label.push_str("BLANK"),
        }
        label.push_str(".");
        match component.from_edge {
            Some(edge) => label.push_str(&graph.edges[edge].identifier.as_str()),
            None => label.push_str("root"),
        }
        pattern.push((component.node, label));
    }

    pattern.sort_by(|a,b| a.0.cmp(&b.0));
    return pattern.iter().map(|e| e.1.clone() ).collect::<Vec<String>>().join(" ");
}

#[test]
fn matched_component_pattern() {
    use std::collections::HashMap;
    let mut graph = graph_match::graph::Graph{ nodes: vec![], edges: vec![] };
    let mut attributes: HashMap<String,String> = HashMap::new();
    attributes.insert(String::from("lemma"), String::from("cat"));
    graph.add_node(String::from("node1"), Some(attributes.clone()));
    graph.add_edge(0, 0, String::from("edge1"), None);
    let matched_components = graph_match::matching::MatchedComponents {
        list: vec![
            graph_match::matching::Component { from_edge: Some(0), node: 0},
        ],
    };
    assert_eq!(String::from("cat.edge1"), matched_components_to_pattern(&matched_components, &graph));
}

pub fn subgraph_nodes_to_extract_string(node_indexes: &Vec<usize>, graph: &Graph) -> String {
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

#[test]
fn subgraph_string() {
    use std::collections::HashMap;
    let mut graph = graph_match::graph::Graph{ nodes: vec![], edges: vec![] };
    let mut attributes: HashMap<String,String> = HashMap::new();
    attributes.insert(String::from("word"), String::from("cat"));
    attributes.insert(String::from("before"), String::from("space"));
    attributes.insert(String::from("after"), String::from("empty"));
    graph.add_node(String::from("node1"), Some(attributes.clone()));
    assert_eq!(String::from(" cat"), subgraph_nodes_to_extract_string(&vec![0], &graph));
}
