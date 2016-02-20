//NP VERB ADV (copula)

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_advmod:REL]->(adv:Node)
WHERE rel_subj.label = "nsubj"
AND rel_advmod.label = "advmod"
RETURN subj, verb, adv;
