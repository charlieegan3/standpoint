//NP VERB ADV

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)

WHERE rel_subj.label = "nsubj"
AND rel_adv.label = "advmod"

RETURN subj, verb, adv;
