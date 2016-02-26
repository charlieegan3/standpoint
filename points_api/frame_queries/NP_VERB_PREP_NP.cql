//NP VERB PREP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (obj)-[rel_prep:REL]->(prep:Node)
WHERE rel_subj.label = "nsubj"
AND rel_obj.label =~ 'nmod.*'
AND rel_prep.label = "case"
RETURN subj, verb, prep, obj;
