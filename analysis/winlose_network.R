require(igraph)

df <- read.csv('../training_set/winlose_network.csv', header = FALSE, col.names = c('lteam','wteam','scoreratio','loc'))



ig <- graph.data.frame(df)
seasons = LETTERS[1:18]

loctyp <- c('H','A','N')
locwt <- c(.3822,.0502,.0663)/.3822
E(ig)$locwt <- locwt[match(E(ig)$loc, loctyp)]
outdf <- data.frame(ID = V(ig)$name)

for(seas.id in seasons){
    seas.ig <- induced.subgraph(ig, V(ig)[substr(V(ig)$name, 1, 1) == seas.id])
    V(seas.ig)$scwtevcent <- evcent(seas.ig, directed = TRUE, weights = E(seas.ig)$scoreratio)$vector
    V(seas.ig)$locwtevcent <- evcent(seas.ig, directed = TRUE, weights = E(seas.ig)$locwt)$vector
    V(seas.ig)$uwevcent <- evcent(seas.ig, directed = TRUE)$vector
    outdf$scwtevcent[outdf$ID %in% V(seas.ig)$name] <- V(seas.ig)$scwtevcent[match(outdf$ID[outdf$ID %in% V(seas.ig)$name], V(seas.ig)$name)]
    outdf$uwevcent[outdf$ID %in% V(seas.ig)$name] <- V(seas.ig)$uwevcent[match(outdf$ID[outdf$ID %in% V(seas.ig)$name], V(seas.ig)$name)]
    outdf$locwtevcent[outdf$ID %in% V(seas.ig)$name] <- V(seas.ig)$locwtevcent[match(outdf$ID[outdf$ID %in% V(seas.ig)$name], V(seas.ig)$name)]

    el <- get.edgelist(seas.ig, names = FALSE)
    seas.rev <- graph(rbind(el[,2],el[,1]))
    V(seas.ig)$revevcent <- evcent(seas.rev, directed = TRUE)$vector
    outdf$revevcent[outdf$ID %in% V(seas.ig)$name] <- V(seas.ig)$revevcent[match(outdf$ID[outdf$ID %in% V(seas.ig)$name], V(seas.ig)$name)]
    
    
}

write.csv(outdf,'../csv/eigenscores.csv', row.names = FALSE)
