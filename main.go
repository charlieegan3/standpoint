package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
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
	response, err := http.Get("http://local.docker:3000/comments/" + commentId + ".json?flat=true")
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

	response, err = http.Post("http://local.docker:4567", "text/json", reqBody)
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
	patterns := []string{
		"{}=verb >nsubj {}=subj >dobj {}=obj",
		"{}=obj >nsubj {}=subj >cop {}=verb",
		"{}=verb >nsubj {}=subj >ccomp {}=verb2",
		"{}=subj >advcl {}=verb",
		"{}=verb >/nmod.*/ {}=subj >dobj {}=obj",
		"{}=verb >nsubj {}=subj >/nmod.*/ {}=obj",
	}
	var topics []string
	for _, s := range sentences {
		s.Text = strings.TrimSpace(s.Text)
		s.Text = strings.ToLower(s.Text)
		for _, topic := range result.Topics {
			if strings.Contains(s.Text, topic) {
				topics = append(topics, topic)
			}
		}
		if contains(topics, "evolution") {
			fmt.Println(topics)
			fmt.Println(s.Text)

			for _, v := range patterns {
				fmt.Println(v)
				payload := struct {
					Text    string `json:"text"`
					Pattern string `json:"pattern"`
				}{
					s.Text, v,
				}
				b, _ := json.Marshal(payload)
				reqBody := bytes.NewBuffer(b)

				response, err = http.Post("http://local.docker:4568", "text/json", reqBody)
				if err != nil {
					panic(err)
				}
				body, err = ioutil.ReadAll(response.Body)
				if len(string(body)) < 10 {
					continue
				}
				var out bytes.Buffer
				json.Indent(&out, body, "", "    ")
				fmt.Println(string(out.Bytes()))
			}
			reader := bufio.NewReader(os.Stdin)
			fmt.Print(">")
			_, _ = reader.ReadString('\n')
			fmt.Println("-------\n\n")
		}
		topics = topics[:0]
	}
}
