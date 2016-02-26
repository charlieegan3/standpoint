//NP VERB ADV

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)

WHERE rel_subj.label = "nsubj"
AND rel_adv.label = "advmod"

RETURN subj, verb, adv;
