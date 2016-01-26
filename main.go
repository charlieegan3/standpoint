package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"regexp"
	"strings"

	"github.com/neurosnap/sentences/english"
)

type Comment struct {
	Id       int
	Body     string
	ParentId int
	Source   string
	Created  string
	Updated  string
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func formatText(text string) string {
	re := regexp.MustCompile(`([^\.]$)`)
	text = re.ReplaceAllString(text, "$1. ")

	re = regexp.MustCompile(`https?\S+`)
	text = re.ReplaceAllString(text, "URL")

	re = regexp.MustCompile(`(\w{2,}[^\s\w-']+)(\w{2,})`)
	text = re.ReplaceAllString(text, "$1 $2")

	re = regexp.MustCompile(`\n`)
	text = re.ReplaceAllString(text, " ")

	re = regexp.MustCompile(`^-\s*`)
	text = re.ReplaceAllString(text, "")

	re = regexp.MustCompile(`\s+`)
	text = re.ReplaceAllString(text, " ")
	return text
}

func main() {
	// get some comments
	commentId := "1"
	response, err := http.Get("http://192.168.99.100:3000/comments/" + commentId + ".json?flat=true")
	if err != nil {
		panic(err)
	}
	defer response.Body.Close()
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		panic(err)
	}
	var comments = []Comment{}
	json.Unmarshal([]byte(body), &comments)

	// collect all the text
	allText := ""
	for _, v := range comments {
		allText += v.Body + "\n\n"
	}
	allText = formatText(allText)

	// get the topics for the text
	payload := struct {
		Text         string `json:"text"`
		TopicCount   int    `json:"topic_count"`
		TopWordCount int    `json:"top_word_count"`
	}{
		allText, 5, 5,
	}
	b, _ := json.Marshal(payload)
	reqBody := bytes.NewBuffer(b)

	response, err = http.Post("http://192.168.99.100:4567", "text/json", reqBody)
	if err != nil {
		panic(err)
	}

	defer response.Body.Close()
	body, err = ioutil.ReadAll(response.Body)
	if err != nil {
		panic(err)
	}
	var result struct {
		Topics []string
		Groups [][]string
	}
	json.Unmarshal([]byte(body), &result)
	fmt.Println(result)

	// extract the sentences from the text
	tokenizer, err := english.NewSentenceTokenizer(nil)
	if err != nil {
		panic(err)
	}

	sentences := tokenizer.Tokenize(allText)

	// scan for matching sentences
	var topics []string
	for _, s := range sentences {
		s.Text = strings.TrimSpace(s.Text)
		s.Text = strings.ToLower(s.Text)
		for _, topic := range result.Topics {
			if strings.Contains(s.Text, topic) {
				topics = append(topics, topic)
			}
		}
		if contains(topics, "born") {
			fmt.Println(topics)
			fmt.Println(s.Text)
			fmt.Println("-------")
		}
		topics = topics[:0]
	}
}
