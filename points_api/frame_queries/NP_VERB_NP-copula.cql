//NP VERB NP (copula)

MATCH (dobj:Node)
MATCH (dobj)-[rel_cop:REL]->(verb:Node)
MATCH (dobj)-[rel_nsubj:REL]->(nsubj:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_cop.label = "cop"
AND ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
RETURN nsubj, verb, dobj;
