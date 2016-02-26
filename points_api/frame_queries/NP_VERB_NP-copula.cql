//NP VERB NP (copula)

MATCH (obj:Node)
MATCH (obj)-[rel_cop:REL]->(verb:Node)
MATCH (obj)-[rel_subj:REL]->(subj:Node)
WHERE rel_subj.label = "nsubj"
AND rel_cop.label = "cop"
AND ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
RETURN subj, verb, obj;
