//NP VERB ADJ (copula)

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_adj:REL]->(adj:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_adj.label = "xcomp"
RETURN nsubj, verb, adj;
