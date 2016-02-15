//NP VERB NP PREP NP PREP NP

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_nmod1:REL]->(nmod1:Node)
MATCH (verb)-[rel_nmod2:REL]->(nmod2:Node)

WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_nmod1.label =~ 'nmod.*'
AND rel_nmod2.label =~ 'nmod.*'
AND nmod1.index < nmod2.index

RETURN subj, verb, obj, nmod1, nmod2;
