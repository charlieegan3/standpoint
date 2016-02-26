//NP VERB ADJ (copula)

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_adj:REL]->(adj:Node)
WHERE rel_subj.label = "nsubj"
AND rel_adj.label = "xcomp"
RETURN subj, verb, adj;
