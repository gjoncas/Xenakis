#Xenakis - Linaia-Agon :: calculates Linus's odds of winning
#Play CC to decide games, each played for multiple rounds
library("lpSolve")

#V=0, so need linear programming to get probabilities
#http://www.egwald.ca/operationsresearch/gametheory.php3
singularProbs <- function(M) {
  obj.fun <- c(rep(0,ncol(M)),1)                      #new var x4 = expected payoff of game
  constr = cbind(t(M),rep(-1,nrow(M)))                #column of -1 coefficients for x4
  constr = rbind(constr,c(rep(1,ncol(constr)-1),0))   #1*X1	+ 1*X2	+ 1*X3	+ 0*X4	= 1
  constr.dir <- c(rep(">=",ncol(constr)-1),"=")
  rhs <- c(rep(0,ncol(constr)-1),1)                   #col c(0,0,0,1)
  prod.sol <- lp("max", obj.fun, constr, constr.dir, rhs, compute.sens = TRUE)
  row = prod.sol$solution[1:nrow(M)]
  col = -1*prod.sol$duals[1:ncol(M)]
  prob = data.frame(row,col)
  return(prob)                                      #probabilities for each move
}

getProbs <- function(M) {
  ones <- rep(1,ncol(M))
  invM <- solve(M)
   bot <- drop((t(ones)%*%invM%*%ones))
   row <- t(t(ones)%*%invM / bot)
   col <- invM%*%ones / bot
  prob <- data.frame(row,col)
  return(prob)                    #NB: returns row & col probabilities (NOT matrix)
}

choice = matrix(c(-3, -8,  7,
                   2,  2, -3,
                  -8, 12,  2),
                nrow=3,ncol=3,byrow=T)
  
alpha = matrix(c(-2,  0,  0,  0,
                  1,  0, -3, -2,
                  0, -1,  1, -2,
                  0, -1, -2,  1),
               nrow=4,ncol=4,byrow=T)

beta = matrix(c(1, -2, -2,  3,
                1, -1,  0, -2,
                0,  4, -2, -2,
               -2, -1,  5,  1),
              nrow=4, ncol=4, byrow=TRUE)

gamma = matrix(c(2, -6,  0,  1,
                -3, -3, -2,  2,
                -5, -1,  3, -4,
                -3,  0, -3, -5),
               nrow=4, ncol=4, byrow=TRUE)

CC = singularProbs(choice)
 A = getProbs(alpha)
 B = getProbs(beta)
 G = getProbs(gamma)

P = list("CC"=CC[,1], "A"=A[,1], "B"=B[,1], "G"=G[,1])      #row probabilities (Linus)
Q = list("CC"=CC[,2], "A"=A[,2], "B"=B[,2], "G"=G[,2])      #col probabilities (Apollo)
rm(CC,A,B,G)


#NB: each play can be X rounds, or proportional to how often each game shows up
combat <- function(game, rounds=5, proportional=F, plays=NULL) {
  
  if (proportional==T) {rounds <- length(which(plays==game))}  #NB: plays must be non-NULL
  if (game=="A") {matrix <- alpha} else
    if (game=="B") {matrix <- beta} else
      if (game=="G") {matrix <- gamma} else {stop("Game must be 'A', 'B', or 'G'")}
  
    linus = sample(1:4,rounds,rep=T,prob=P[[game]])
   apollo = sample(1:4,rounds,rep=T,prob=Q[[game]])
    moves = matrix(c(linus,apollo),nrow=2)
  payoffs = vector(length=rounds)
  for (i in (1:rounds)) {
    payoffs[i] <- matrix[moves[1,i],moves[2,i]]
  }
  return(payoffs)
}


linaia.agon <- function(rounds=5,sequence=5,proportional=F,cc.counts=F) {

  #generates moves according to mixed strategy probabilities
  cc.moves = matrix(c(sample(1:3,sequence,rep=T,prob=P[["CC"]]),
                      sample(1:3,sequence,rep=T,prob=Q[["CC"]])),nrow=2)

  #order for combats                      #can optimize by defining cc.moves with c()
  plays = vector(length=(2*sequence))
  for (i in 1:(2*sequence)) {plays[i] <- c("A","B","G")[c(cc.moves)[i]]}; rm(i)

  #use if rounds are proportional to how often they show up in CC
  if (proportional==T) {
    proportions <- c(length(which(plays=="A")),length(which(plays=="B")),length(which(plays=="G")))
  }

  #use if CC wins count for final total       #NB: relies on unflattened CC.moves
  if (cc.counts==T) {                         #breaks if that is changed
    cc.payoffs = vector(length=sequence)
    for (i in (1:sequence)) {cc.payoffs[i] <- choice[cc.moves[1,i],cc.moves[2,i]]}; rm(i)
  }

  #use c() b/c number of rounds may be indeterminate; else is plays*rounds
    #for speed, can do: if (proportional=F) {no c()} else {with c()} (don't forget cc.payoffs!)
  if (cc.counts==F) {wins = NULL} else {wins = cc.payoffs}
   for (i in plays) {wins = c(wins,combat(i,rounds,proportional,plays))}
  
  return(wins)    #returns vector of payoffs for each round

} #end of linaia.agon()


  #NB: sequence is rounds in CC (--> #games), rounds is #rounds in each game
xenakis <- function(iterations=1000,rounds=5,sequence=5,proportional=F,cc.counts=F) {
  
  if (!all(is.numeric(c(iterations,rounds,sequence)))) {stop("Must be numbers")}
  if (any(iterations<1,rounds<1,sequence<1)) {stop("Numbers must be 1 or higher")}
  
  games = list()                                        #list of payoffs in each game 
  for (i in 1:iterations) {games[[i]] <- linaia.agon(rounds,sequence,proportional,cc.counts)}
  
  total = vector(length=iterations)                     #scores for each game
  for (i in 1:iterations) {total[i] = sum(games[[i]])}      
  
   linus = length(which(total>0))       #>0 --> Linus wins
   draws = length(which(total==0))
  apollo = iterations - linus - draws   #<0 --> Apollo wins
  
  cat(paste0("Out of ",format(iterations)," games, Linus wins ",format(linus)," times (",
      format(100*linus/iterations),"%), with ",format(draws)," ties (",format(100*draws/iterations),
      "%), and Apollo wins ",format(apollo)," times (",format(100*apollo/iterations),"%)\n"))
}

#TO DO:
#- test how dirty tricks (e.g. only choosing B & G in CC) affect the odds [redo cc.moves]
#- combat() has arguments proportional & plays -- can probably eliminate proportional
     #if (!is.null(plays)) {rounds <- length(which(plays==game))}

#NOTES
#- the higher the number of rounds/sequences, the less are Linus's odds
#- including CC wins (cc.counts=T) raises Linus's chances considerably
#- at 10 rounds, Apollo wins 99.8% of the time (with 11 rounds, 99.97%)
#- if rounds proportional to game frequency,  L's odds increase -- by making rounds shorter
#- Linus wins more from 5 rounds of 1 game (n,5,1) than 1 round of 5 games (n,1,5)
#
#- at 1 round (no CC), Linus wins 25% of the time (13.5% ties, 61.5% Apollo)
#- at 1 round (+CC), Linus wins 39.6% of the time (8.77% ties, 51.6% Apollo)
#- runtime is linear in iterations (1000 games take 1.22 seconds, 10,000 games take 12.5s)
#
#- to tally number of wins (irrespective of score), use: total[i] = sum(sign(games[[i]]))
#- reproducing linaia.R with 1000 iterations: Linus 19.2%, ties 31.4%, Apollo 49.4%

#EXTENSIONS
#- incorporate musical excerpts, to generate a performance of Linaia-Agon
#- make graphs to show how results change with different parameters
#- show that mixed strategy probabilities are optimal