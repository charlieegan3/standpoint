#!/usr/bin/env python

# summarizer_topic.py
# This is the implementation of the ‘Stock’ summarizer used in the evaluation
# that was adjusted to run as part of the summary generation pro- cess.
# Originally sourced from:
# http://homepages.abdn.ac.uk/advaith/pages/teaching/NLP/practicals/Practical3.zip

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

def wordList(sentence):
    return re.findall(r"[\w']+", sentence)

def wordCount(sentence):
    return len(wordList(sentence))

#----------------------------------------------------------

def scoreSentences(sentences, pWord, maxLength):
    summaryLength = 0
    iters = 0
    while summaryLength <= maxLength and iters < 1000:
        scores = {}
        iters += 1

        sentences = [s for s in sentences if (len(s) < (maxLength * 1.05) - summaryLength)]
        sentences = [s for s in sentences if (wordCount(s) > 3)]
        if len(sentences) == 0:
            break

        for s in sentences:
            words = wordList(s)
            count = len(words)
            score = 0
            for w in words:
                score += pWord[w]
            scores[s] = score / count

        s = max(scores, key=scores.get)

        if summaryLength <= (maxLength * 1.05):
            print (cleanSentence(s))
            summaryLength += wordCount(s)
        for word in wordList(s): #iterate over words and reduce probabilities
            pWord[word] *= pWord[word]

#-----------------------------------------------------------

f = sys.argv[1]
f = open("../stock_summarizers/" + f + ".txt", 'r')

text = f.read().replace('#stance=stance1', '').replace('#stance=stance2', '')
text = ''.join([i if ord(i) < 128 else '' for i in text])
#text = text.replace('.', '. ')

#sentences = re.split(r'\n|\. ', text)
sentences = re.split(r'\n', text)

pWord={}
getProbabilities(sentences,  pWord)

scoreSentences(sentences, pWord, int(sys.argv[2]))
