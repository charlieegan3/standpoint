extern crate encoding;
use encoding::{Encoding, EncoderTrap, DecoderTrap};
use encoding::all::ASCII;

pub fn force_ascii(text: &String) -> Result<String, String> {
    match ASCII.encode(text.as_str(), EncoderTrap::Ignore) {
        Ok(encoded) => {
            match ASCII.decode(&encoded, DecoderTrap::Replace) {
                Ok(decoded) => {
                    return Ok(decoded);
                },
                Err(error) => { return Err(String::from(format!("Failed to decode ASCII. ({})", error))) }
            }
        },
        Err(error) => { return Err(String::from(format!("Failed to encode ASCII. ({})", error))) }
    }
}
