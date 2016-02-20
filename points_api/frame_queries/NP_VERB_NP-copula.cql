//NP VERB NP (copula)

MATCH (obj:Node)
MATCH (obj)-[rel_cop:REL]->(verb:Node {uuid: 'VERB_UUID'})
MATCH (obj)-[rel_subj:REL]->(subj:Node)
WHERE rel_subj.label = "nsubj"
AND rel_cop.label = "cop"
RETURN subj, verb, obj;
