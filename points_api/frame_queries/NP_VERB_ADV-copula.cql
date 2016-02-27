//NP VERB ADV (copula)

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_advmod:REL]->(adv:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_advmod.label = "advmod"
RETURN nsubj, verb, adv;
