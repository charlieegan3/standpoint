extern crate rustc_serialize;

use rustc_serialize::json::Json;

pub fn dependency_to_edge_string(dependency: &Json) -> Result<String, String> {
    let dependency: Dependency = match rustc_serialize::json::decode(&format!("{}", dependency)) {
        Ok(dependency) => dependency,
        Err(message) => return Err(format!("Json decode error ({})", message)),
    };
    return Ok(dependency.to_node_string());
}

#[test]
fn test_dependency_to_edge_string() {
    let dependency_json_string = r#"{
        "dep": "nsubj",
        "governor": 4,
        "governorGloss": "sentence",
        "dependent": 1,
        "dependentGloss": "This"
        }"#;
    let json_dependency = Json::from_str(dependency_json_string).unwrap();
    assert_eq!("type:edge identifier:nsubj label:nsubj source:3 target:0", dependency_to_edge_string(&json_dependency).unwrap());
}

struct Dependency {
    dep: String,
    source: usize,
    target: usize,
}

impl Dependency {
    fn to_node_string(&self) -> String {
        let mut new_source = 0;
        if self.source > 0 {
            new_source = self.source - 1;
        }
        return format!("type:edge identifier:{} label:{} source:{} target:{}",
                       self.dep.replace(":", "_"),
                       self.dep.replace(":", "_"),
                       new_source,
                       self.target - 1);
    }
}

impl rustc_serialize::Decodable for Dependency {
    fn decode<D: rustc_serialize::Decoder>(d: &mut D) -> Result<Self, D::Error> {
        Ok(Dependency {
            dep: try!(d.read_struct_field("dep", 0, |d| rustc_serialize::Decodable::decode(d))),
            source: try!(d.read_struct_field("governor", 0, |d| rustc_serialize::Decodable::decode(d))),
            target: try!(d.read_struct_field("dependent", 0, |d| rustc_serialize::Decodable::decode(d))),
        })
    }
}
