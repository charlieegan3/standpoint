require(ggplot2)
require(gridExtra)
require(psych)

library(scales)

table = read.csv(file="study2_extracts.csv", header=TRUE, sep=",")
attach(table)

table$bigram = scale(table$bigram, center=TRUE, scale=TRUE)
table$turkers = scale(table$turkers, center=TRUE, scale=TRUE)

plot <- ggplot(table, aes(x=bigram, y=turkers)) +
               geom_point(color="gray") +
               geom_smooth(method=lm, se=FALSE, color="black") +
               theme_bw() + theme(plot.title=element_text(size=8),
                                  axis.text=element_text(size=8),
                                  panel.grid.major = element_blank(),
                                  panel.grid.minor = element_blank()) +
               labs(x="Extract Bigram Score (z Score)", y="Mean Extract Human Score (z Score)")

pdf("scatter.pdf", width=4, height=4)
grid.arrange(plot, ncol=1, nrow=1)
dev.off()

cor.test(table$bigram, table$turkers, short=FALSE, exact=TRUE)
