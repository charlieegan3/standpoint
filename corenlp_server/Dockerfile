FROM java:8
RUN curl http://nlp.stanford.edu/software/stanford-corenlp-full-2015-12-09.zip > corenlp.zip
RUN unzip corenlp.zip -d /corenlp
RUN mv /corenlp/*/* /corenlp
WORKDIR /corenlp
RUN export CLASSPATH="`find . -name '*.jar'`"
CMD java -cp "*" -mx4g edu.stanford.nlp.pipeline.StanfordCoreNLPServer
