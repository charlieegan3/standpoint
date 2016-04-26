library(coin)

#example 1
#http://yatani.jp/teaching/doku.php?id=hcistats:mannwhitney
#GroupA = c(2,4,3,1,2,3,3,2,3,1)
#GroupB = c(3,5,4,2,4,3,5,5,3,2)

#example 2
#http://www.snabonline.com/Content/SkillsSupport/MathsAndStatsSupport/M0_14S.pdf
#GroupA = c(1,2,2,2,3,4,4,5)
#GroupB = c(3,3,4,4,5,6,6,6)

wt_old <- wilcox.test(GroupA, GroupB)

g = factor(c(rep("GroupA", length(GroupA)), rep("GroupB", length(GroupB))))
v = c(GroupA, GroupB)
wt <- wilcox_test(v ~ g)

r = rank(v)
data = data.frame(g, r)
mean((split(data, data$g))$GroupA$r)
mean((split(data, data$g))$GroupB$r)

median(GroupA)
median(GroupB)
length(GroupA)
length(GroupB)

abs(statistic(wt)) / sqrt(length(GroupA) + length(GroupB))
pvalue(wt)
wt_old$statistic
wt
