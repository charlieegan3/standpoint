//NP VERB ADV

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)

WHERE rel_nsubj.label = "nsubj"
AND rel_adv.label = "advmod"

RETURN nsubj, verb, adv;
