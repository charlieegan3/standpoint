//NP VERB ADV PREP NP

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)

WHERE rel_subj.label = "nsubj"
AND rel_adv.label = "advmod"
AND rel_nmod.label =~ 'nmod.*'
AND rel_prep.label = "case"

RETURN subj, verb, adv;
