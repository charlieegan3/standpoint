use regex::Regex;

pub fn pattern(pattern: &String) -> bool {
    return !is_banned_speech_act(pattern);
}

fn is_banned_speech_act(pattern: &String) -> bool {
    if !pattern.contains("PERSON.noun") || pattern.split_whitespace().count() != 2 {
        return false;
    }
    let re = Regex::new(r"\s(object|continue|come|go|sit|open|close|begin|end|believe|happen|leave|understand|realize|debate|speak|show|stand|call|refer|believe|lose|change|care|hear|write|disagree|read|tell|start|talk|explain|come|live|take|support|guess|feel|follow|make|go|get|move|agree|find|fail|think|wonder|feel|ask|argue|try)\.").unwrap();
    return re.is_match(pattern);
}
