//NP VERB PREP NP PREP NP
//here the NP at the end is really a sentence, the verb is returned

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (verb2:Node)-[rel_advcl:REL]-(verb)
MATCH (verb2)-[rel_prep2:REL]-(prep2:Node)

WHERE rel_nsubj.label = "nsubj"
AND rel_nmod.label =~ 'nmod.*'
AND rel_prep.label = "case"
AND rel_advcl.label =~ 'advcl|ccomp'
AND verb2.part_of_speech =~ 'VB.?'
AND rel_prep2.label =~ 'mark|case'

RETURN nsubj, verb, prep, nmod, prep2, verb2;
