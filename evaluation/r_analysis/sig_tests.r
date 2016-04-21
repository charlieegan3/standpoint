library(scales)

study1 = read.csv(file="study1.csv", header=TRUE, sep=",")
study2 = read.csv(file="study2.csv", header=TRUE, sep=",")
study2_extracts = read.csv(file="study2_extracts.csv", header=TRUE, sep=",")

successesFailures <- function(table, comparison, factor) {
  counts = table[table$comparison==comparison & table$factor==factor & table$answer!='same',]$count
  successes = sum(counts[1:2])
  failures = sum(counts[3:4])

  return(c(successes, failures, successes + failures))
}

study2_extracts$bigram = scale(study2_extracts$bigram, center=TRUE, scale=TRUE)
study2_extracts$turkers = scale(study2_extracts$turkers, center=TRUE, scale=TRUE)


factors = c('overall', 'content', 'punctuation', 'readability', 'organization')
for(i in 1:5) {
  succFail = successesFailures(study1, 'plain_vs_stock', factors[i])
  print(factors[i])
  print(binom.test(succFail[1], succFail[3])$p.value)
}

for(i in 1:5) {
  succFail = successesFailures(study1, 'layout_vs_stock', factors[i])
  print(factors[i])
  print(binom.test(succFail[1], succFail[3])$p.value)
}

succFail = successesFailures(study1, 'layout_vs_formatted', 'overall')
print(binom.test(succFail[1], succFail[3])$p.value)

succFail = successesFailures(study2, 'bigram_vs_random', 'overall')
print(binom.test(succFail[1], succFail[3])$p.value)

cor.test(study2_extracts$bigram, study2_extracts$turkers, short=FALSE, exact=TRUE)$p.value
