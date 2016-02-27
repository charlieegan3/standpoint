//NP VERB NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
RETURN nsubj, verb, dobj;
