require(ggplot2)
require(gridExtra)

library(scales)

myHist <- function(dataTable, graphTitle, xLabelsFrom, xLabelsTo){
  hist <- ggplot(dataTable, aes(y=dataTable$count, x=factor(dataTable$answer, levels=unique(as.character(dataTable$answer))))) +
         geom_bar(stat="identity", fill="grey") +
         ylab("") + xlab("") +
         theme_bw() + theme(plot.title=element_text(size=8, vjust=-3),
                            plot.margin=unit(c(0.1,0.1,-0.4,-0.4), "cm"),
                            axis.text=element_text(size=8),
                            panel.grid.major = element_blank(),
                            panel.grid.minor = element_blank()) +
         theme(axis.text.x = element_text(size=8, angle=90, hjust=1.05, vjust=0.4, lineheight=0.72)) +
         ylim(0,35) +
         scale_x_discrete(breaks=xLabelsFrom, labels=xLabelsTo) +
         annotate("text",  x=Inf, y = Inf, label = graphTitle, size=3, hjust=1+(1.0/nchar(graphTitle)), vjust=1.5)
  return(hist)
}

#------------------------------------------------------------------------------
# Study 1
#------------------------------------------------------------------------------

table = read.csv(file="study1.csv", header=TRUE, sep=",")
attach(table)

#------------------------------------------------------------------------------

dataLabels = c("plain-much_better", "plain-better", "same", "stock-better", "stock-much_better")
printLabels = c("plain \n much better", "plain better", "same ", "stock better", "stock \n much better")

plot1 <- myHist(table[table$comparison=='plain_vs_stock' & table$factor=='overall',],
                "overall", dataLabels, printLabels)
plot2 <- myHist(table[table$comparison=='plain_vs_stock' & table$factor=='content',],
                "content", dataLabels, printLabels)
plot3 <- myHist(table[table$comparison=='plain_vs_stock' & table$factor=='punctuation',],
                "punctuation", dataLabels, printLabels)
plot4 <- myHist(table[table$comparison=='plain_vs_stock' & table$factor=='readability',],
                "readability", dataLabels, printLabels)
plot5 <- myHist(table[table$comparison=='plain_vs_stock' & table$factor=='organization',],
                "organization", dataLabels, printLabels)

pdf("plain_vs_stock_hists.pdf", width=8, height=2)
grid.arrange(plot1, plot2, plot3, plot4, plot5, ncol=5, nrow=1)

#------------------------------------------------------------------------------

dataLabels = c("layout-much_better", "layout-better", "same", "stock-better", "stock-much_better")
printLabels = c("layout \n much better", "layout better", "same ", "stock better", "stock \n much better")

plot1 <- myHist(table[table$comparison=='layout_vs_stock' & table$factor=='overall',],
                "overall", dataLabels, printLabels)
plot2 <- myHist(table[table$comparison=='layout_vs_stock' & table$factor=='content',],
                "content", dataLabels, printLabels)
plot3 <- myHist(table[table$comparison=='layout_vs_stock' & table$factor=='punctuation',],
                "punctuation", dataLabels, printLabels)
plot4 <- myHist(table[table$comparison=='layout_vs_stock' & table$factor=='readability',],
                "readability", dataLabels, printLabels)
plot5 <- myHist(table[table$comparison=='layout_vs_stock' & table$factor=='organization',],
                "organization", dataLabels, printLabels)

pdf("layout_vs_stock_hists.pdf", width=8, height=2)
grid.arrange(plot1, plot2, plot3, plot4, plot5, ncol=5, nrow=1)

#------------------------------------------------------------------------------

dataLabels = c("formatted-much_better", "formatted-better", "same", "layout-better", "layout-much_better")
printLabels = c("formatted \n much better", "formatted better", "same ", "layout better", "layout \n much better")

plot1 <- myHist(table[table$comparison=='layout_vs_formatted' & table$factor=='overall',],
                "overall", dataLabels, printLabels)

pdf("layout_vs_formatted_hists.pdf", width=1.6, height=2)
grid.arrange(plot1, ncol=1, nrow=1)

#------------------------------------------------------------------------------
# Study 2
#------------------------------------------------------------------------------

table = read.csv(file="study2.csv", header=TRUE, sep=",")
attach(table)

table

dataLabels = c("bigram-much_better", "bigram-better", "same", "random-better", "random-much_better")
printLabels = c("bigram \n much better", "bigram better", "same ", "random better", "random \n much better")

table[table$comparison=='bigram_vs_random' & table$factor=='overall',]

plot1 <- myHist(table[table$comparison=='bigram_vs_random' & table$factor=='overall',],
                "overall", dataLabels, printLabels)

pdf("bigram_vs_random_hists.pdf", width=1.6, height=2)
grid.arrange(plot1, ncol=1, nrow=1)

dev.off()
