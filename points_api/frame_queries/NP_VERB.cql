//NP VERB

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
WHERE rel_subj.label = "nsubj"
RETURN subj, verb;
