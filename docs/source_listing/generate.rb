files = [
	'../../analysis_api/clean.rb',
	'../../analysis_api/collector.rb',
	'../../curator/main.go',
	'../../docker-compose.yml',
	'../../evaluation/extract_ranking.rb',
	'../../evaluation/process_extract_comparison.rb',
	'../../evaluation/process_summary_comparison.rb',
	'../../evaluation/r_analysis/hists.r',
	'../../evaluation/r_analysis/mann-whit.r',
	'../../evaluation/r_analysis/scatter.r',
	'../../evaluation/r_analysis/sig_tests.r',
	'../../evaluation/survey/extracts.rb',
	'../../evaluation/survey/generate.rb',
	'../../evaluation/survey/server.rb',
	'../../evaluation/survey/survey.html.erb',
	'../../evaluation/survey/survey_extract.html.erb',
	'../../points_api/app.rb',
	'../../points_api/frame_queries/LEX_VERB_NP_PREP_NP.cql',
	'../../points_api/frame_queries/LEX_VERB_PREP_NP_NP.cql',
	'../../points_api/frame_queries/NP_VERB.cql',
	'../../points_api/frame_queries/NP_VERB_ADJ-copula.cql',
	'../../points_api/frame_queries/NP_VERB_ADV-copula.cql',
	'../../points_api/frame_queries/NP_VERB_ADV.cql',
	'../../points_api/frame_queries/NP_VERB_ADV_LEX.cql',
	'../../points_api/frame_queries/NP_VERB_ADV_PREP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_LEX.cql',
	'../../points_api/frame_queries/NP_VERB_NP-copula.cql',
	'../../points_api/frame_queries/NP_VERB_NP.cql',
	'../../points_api/frame_queries/NP_VERB_NP_LEX.cql',
	'../../points_api/frame_queries/NP_VERB_NP_LEX_NP.cql',
	'../../points_api/frame_queries/NP_VERB_NP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_NP_PREP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_NP_PREP_NP_PREP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_PREP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_PREP_NP_NP.cql',
	'../../points_api/frame_queries/NP_VERB_PREP_NP_PREP_NP.cql',
	'../../points_api/frame_queries/PREP_NP_VERB_NP.cql',
	'../../points_api/frame_queries/VERB-universal.cql',
	'../../points_api/lib/corenlp_client.rb',
	'../../points_api/lib/frame.rb',
	'../../points_api/lib/neo4j_client.rb',
	'../../points_api/lib/node.rb',
	'../../points_api/lib/points_extraction.rb',
	'../../points_api/lib/relation.rb',
	'../../points_api/lib/utils.rb',
	'../../points_api/tasks/parse_verb_net.rb',
	'../../stock_summarizers/summarizer_topic.py',
	'../../summarizer/abortion_formatted.html',
	'../../summarizer/condense.rb',
	'../../summarizer/counters.rb',
	'../../summarizer/curator.rb',
	'../../summarizer/paragraphizer.rb',
	'../../summarizer/presenter.rb',
	'../../summarizer/related.rb',
	'../../summarizer/summarizer.rb',
	'../../summarizer/summary.rb',
	'../../summarizer/template_formatted.html.erb',
	'../../summarizer/utils.rb',
	'../../topic_api/app.rb',
	'../../utilities/plotter/graph.html',
	'../../utilities/plotter/plot.rb',
]

template = '
\section*{FILE}
\begin{lstlisting}[language=EXT]
CODE
\end{lstlisting}
\pagebreak
'

exts = {
  "rb" => 'Ruby,stringstyle=\color{black}',
  "r" => "R",
  "html" => "HTML5",
  "erb" => "HTML5",
  "py" => "Python",
  "cql" => "SQl",
  "yml" => "Ruby",
  "go" => "Golang",
}

def escape(string)
  string.gsub('_', '\_')
end

all_listings = ""
files.each do |path|
  contents = File.open(path).read
  all_listings += template
    .gsub("FILE", escape(path.gsub('../../', '')))
    .gsub("CODE", "\n#{contents}\n")
    .gsub("EXT", exts[path.split(".").last])
end

document = File.open('listing_template.tex').read
puts document
puts document.gsub("LISTINGS", all_listings)

