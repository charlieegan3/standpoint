use regex::Regex;

pub fn pattern(pattern: &String) -> bool {
    return !is_banned_speech_act(pattern) && !is_banned_pattern(pattern);
}

fn is_banned_speech_act(pattern: &String) -> bool {
    if !pattern.contains("PERSON.noun") || pattern.split_whitespace().count() != 2 {
        return false;
    }
    let re = Regex::new(r"\s(object|continue|come|go|sit|open|close|begin|end|believe|happen|leave|understand|realize|debate|speak|show|stand|call|refer|believe|lose|change|care|hear|write|disagree|read|tell|start|talk|explain|come|live|take|support|guess|feel|follow|make|go|get|move|agree|find|fail|think|wonder|feel|ask|argue|try)\.").unwrap();
    return re.is_match(pattern);
}

fn is_banned_pattern(pattern: &String) -> bool {
    if vec![
        "PERSON.noun be.verb correct.adj",
        "PERSON.noun be.verb able.adj",
        "PERSON.noun be.verb good.adj",
        "PERSON.noun be.verb likely.adj",
        "PERSON.noun be.verb sorry.adj",
        "PERSON.noun be.verb say.verb",
        "PERSON.noun be.verb aware.adj",
        "PERSON.noun be.verb one.noun",
        "PERSON.noun be.verb sure.adj",
        "PERSON.noun be.verb wrong.adj",
        "PERSON.noun be.verb right.adj",
        "PERSON.noun be.verb glad.adj",
        "PERSON.noun be.verb here.noun",
        "PERSON.noun be.verb willing.verb",
        "PERSON.noun be.verb true.adj",
        "PERSON.noun be.verb false.adj",
        "PERSON.noun be.verb favor.noun",
        "PERSON.noun be.verb interested.adj",
        "PERSON.noun want.verb have.verb",
        "PERSON.noun want.verb what.wp",
        "PERSON.noun want.verb what.wp do.verb",
        "PERSON.noun say.verb what.wp",
        "PERSON.noun mean.verb what.wp",
        "PERSON.noun know.verb what.wp",
        "PERSON.noun believe.verb what.wp",
        "PERSON.noun see.verb what.wp",
        "PERSON.noun see.verb argument.noun",
        "PERSON.noun have.verb problem.noun",
        "PERSON.noun tell.verb PERSON.noun",
        "PERSON.noun think.verb what.wp",
        "PERSON.noun argue.verb in.prep fact.noun",
        "PERSON.noun argue.verb with.prep PERSON.noun",
        "debate.noun be.verb about.adj",
        "question.noun be.verb",
        "make.verb claim.noun",
        "ask.verb PERSON.noun",
        "thing.noun happen.verb",
        "something.noun happen.verb"].contains(&pattern.as_str()) {
            return true;
        } else {
            return false;
        }
}
