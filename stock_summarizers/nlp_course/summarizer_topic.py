#!/usr/bin/env python
import re, random, math, collections, itertools, sys, os

#------------- Function Definitions ---------------------

#calculates p(W)
def getProbabilities(sentences, pWord):
    freq = {} # {} initialises a dictionary [hash function]
    allWordsTot = 0
    #iterate through each sentence
    for sentence in sentences:
        wordList = re.findall(r"[\w']+", sentence)

        for word in wordList: #iterate over words in sentence
            allWordsTot += 1 # keeps count of total words in dataset
            if not (word in freq):
                freq[word] = 1
            else:
                freq[word] += 1


        # Calculate p(word)
    for word in freq.keys():
        pWord[word] = (freq[word] / float(allWordsTot) )

def cleanSentence(sentence):
    sentence = re.sub('^\W+', '', sentence)
    sentence = re.sub('[^\w\.\?]+$', '', sentence)
    sentence = re.sub('\/>?', '', sentence)
    sentence = re.sub('\.+', '.', sentence)
    sentence = re.sub('\s+', ' ', sentence)
    return sentence.capitalize()

#----------------------------------------------------------

def scoreSentences(sentences, pWord, maxLength):
    freq = {} # {} initialises a dictionary [hash function]
    allWordsTot = 0
    scores = {}
    lengths = {}

    summaryLength=0
    iters=0;
    while summaryLength<=maxLength and iters<50:
        iters += 1
        #recalculate scores each time
        for sentence in sentences:
            wordList = re.findall(r"[\w']+", sentence)
            length=1
            score=0
            for word in wordList: #iterate over words
                length += 1
                score += pWord[word]

            scores[sentence] = score / length #calculate sentence score
            if length <= 3: #ignore short sentences
                scores[sentence] = 0
            lengths[sentence] = length #calculate sentence length

        #generate summary by including best sentences and updating probabilities
        s = max(scores, key=scores.get)

        if summaryLength <= maxLength: #keep to word limit
            if summaryLength + lengths[s]<= maxLength:
                print (cleanSentence(s))
                summaryLength += lengths[s] #increment summary length
            wordList = re.findall(r"[\w']+", s)
            for word in wordList: #iterate over words and reduce probabilities
                pWord[word] *= pWord[word]

#-----------------------------------------------------------

f = sys.argv[1]
f = open("../stock_summarizers/nlp_course/" + f + ".txt", 'r')

text = f.read().replace('#stance=stance1', '').replace('#stance=stance2', '').replace('.', '. ')

sentences = re.split(r'\n|\. ', text)

pWord={}
getProbabilities(sentences,  pWord)

scoreSentences(sentences, pWord, int(sys.argv[2]))
