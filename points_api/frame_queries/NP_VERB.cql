//NP VERB

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
WHERE rel_nsubj.label = "nsubj"
RETURN nsubj, verb;
