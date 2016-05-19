extern crate graph_match;
use std::collections::HashMap;

pub fn parse(string: String) -> Result<graph_match::graph::Graph, String> {
    let mut graph = graph_match::graph::Graph { nodes: vec![], edges: vec![] };
    for line in string.split("\n") {
        let attributes = parse_line(line.to_string());
        match attributes.get("type") {
            Some(element_type) => {
                match element_type.as_str() {
                    "node" => {
                        match attributes.get("identifier") {
                            Some(identifier) => {
                                graph.add_node(identifier.clone(), Some(attributes.clone()));
                            },
                            None => return Err("Missing identifier".to_string())
                        }
                    },
                    "edge" => {
                        match attributes.get("identifier") {
                            Some(identifier) => {
                                match extract_source_target(&attributes) {
                                    Some((source, target)) => {
                                        graph.add_edge(source, target, identifier.clone(), Some(attributes.clone()));
                                    },
                                    None => return Err("Invalid source or target".to_string())
                                }
                            },
                            None => return Err("Missing identifier".to_string())
                        }
                    },
                    _ => { return Err("Invalid type".to_string()) },
                }
            }
            None => return Err("A line must have a graph component type".to_string())
        }
    }
    return Ok(graph);
}

fn parse_line(line: String) -> HashMap<String,String> {
    let mut attributes: HashMap<String,String> = HashMap::new();
    for pair in line.split(" ") {
        let mut pair = pair.split(":");
        match pair.next() {
            Some(k) => {
                match pair.next() {
                    Some(v) => {
                        attributes.insert(k.to_string(), v.to_string());
                    },
                    None => continue,
                }
            },
            None => continue,
        }
    }
    return attributes;
}

fn extract_source_target(attributes: &HashMap<String,String>) -> Option<(usize,usize)> {
    match attributes.get("source") {
        Some(source) => {
            match attributes.get("target") {
                Some(target) => {
                    let usize_source = source.parse::<usize>();
                    let usize_target = target.parse::<usize>();
                    if usize_source.is_ok() && usize_target.is_ok() {
                        return Some((usize_source.unwrap(), usize_target.unwrap()));
                    } else {
                        return None;
                    }
                },
                None => return None,
            }
        },
        None => return None,
    }
}

