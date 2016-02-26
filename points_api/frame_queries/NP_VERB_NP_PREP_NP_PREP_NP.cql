//NP VERB NP PREP NP PREP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_nmod1:REL]->(nmod1:Node)
MATCH (verb)-[rel_nmod2:REL]->(nmod2:Node)
MATCH (nmod1)-[rel_case1:REL]->(prep1:Node)
MATCH (nmod2)-[rel_case2:REL]->(prep2:Node)

WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_nmod1.label =~ 'nmod.*'
AND rel_nmod2.label =~ 'nmod.*'
AND rel_case1.label = "case"
AND rel_case2.label = "case"
AND nmod1.index < nmod2.index

RETURN subj, verb, obj, prep1, nmod1, prep2, nmod2;
