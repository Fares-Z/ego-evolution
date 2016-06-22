source('evolution.R')

school <- read.table('../data/Primary school temporal network data/primaryschool.csv')
names(school) <- c('timestamp', 'nodeA', 'nodeB', 'classA', 'classB')

school.meta <- read.table('../data/Primary school temporal network data/metadata_primaryschool.txt')
names(school.meta) <- c('node', 'class', 'sex')

links <- school[,c(1,2,3)]

number.of.slices <- 100
number.of.nodes <- length ( unique (c(links[,2],links[,3])) )

td.network <- time.density (links, bandwidth = 600, n = number.of.slices)
timestamps <- sort(unique(td.network[,3]))

##ego.centers <- c('1500')
##ego.centers <- c('1521') ## teacher
##ego.centers <- c('1500', '1521')
ego.centers <- c('1500')
school.meta[school.meta$node==1500,2] -> her.class

results <- temporal.pagerank (td.network, ego.centers, globality = 0.2)


## One visualisation
order (results[,5], decreasing = TRUE ) -> ord
sresults <- results[ord,]

visualise ( biz.scale (sresults),  timestamps,
           yaxt = 'n', xlab = 'time',
           ylab = '')



## To order by rowsum
##   order (rowSums(results), decreasing=TRUE) -> ord
## By rowmax
##   order (apply(results,1,max), decreasing=TRUE) -> ord
## Or by something other
##   order (max.col(results), decreasing=TRUE) -> ord


## A sequence of visualisations

png("../figs/school%03d.png", width = 1200, height = 800)

for (i in 1:number.of.slices) {
    ## sort results
    order (results[,i], decreasing = TRUE ) -> ord
    sresults <- results[ord,]

    ## visualise results
    visualise ( biz.scale (sresults),  timestamps,
               yaxt = 'n', xlab = 'time',
               ylab = ''
##               ,ylim=c(number.of.nodes-10-1, number.of.nodes + 1)
               )
    ## timestamp that sorts
    abline(v=timestamps[i]) 

    ## sort the metadata
    school.meta[match (names(sresults[,i]), school.meta$node),] ->
        school.meta.ord

    ## first nodes are in top
    number.of.nodes + 1 -
        which(school.meta.ord$class == her.class) + 0.5  ->
            her.class.positions

    number.of.nodes + 1 -
        which(school.meta.ord$class == '5A') + 0.5  ->
            A5.class.positions
        
    ## horizontal lines for the class of ego.centers
    ## her.class = school.meta$class[school.meta$node == ego.centers]
    ## abline(h = number.of.nodes + 1 -
    ##            which(school.meta.ord$class == her.class) + 0.5
    ##        , lty=3)


    ## horizontal lines for teachers
    ## abline(h = number.of.nodes + 1 -
    ##            which(school.meta.ord$class == 'Teachers') + 0.5
    ##        ,lty = 2)

    
    school.meta.ord$class -> labels.left
    axis(2, at=her.class.positions, col='black'
        ,labels = rep(her.class,length(her.class.positions)))

    axis(2, at=A5.class.positions, col='grey', col.axis = 'grey'
        ,labels = rep('5A',length(A5.class.positions)))
    
    school.meta.ord$sex -> labels.right
    axis(4, at=(number.of.nodes:1) + 0.5, labels=labels.right)

}


dev.off()


## to create a video run the following command
## ffmpeg -r 7 -i school%03d.png -vb 200M out.webm