# Linaia-Agon
This is a simulation in R (v3.6.0) of the game-theoretic musical composition Linaia-Agon by Iannis Xenakis.

The piece consists of four zero-sum game matrices: Choice of Combats, Combat α, Combat β, and Combat γ.

The piece is based on a mythical duel between the musician Linus (on trombone) and the god Apollo (on horn and/or tuba).
Musically, moves in each game correspond to musical notes (Choice of Combats) or a 20-bar measure of music.

First the players play Choice of Combats, where their moves are made into a sequence, e.g. (α, β), (γ, γ) → (α, β, γ, γ).

![Choice of Combats](/pics/linaia-cc.png)

Players then play the other combats in this sequence. In each game, the highest-scoring player after <i>r</i> rounds wins.

![Combats Alpha, Beta, Gamma](/pics/linaia-abg.png)

At the end, each player's number of wins is tallied up. As the games' values show, the duel is in Apollo's favor.

A natural question is: what are Linus's odds of winning? That's what this simulation is for.

## Simulation
Choice of Combats is a fair game (V=0), so `singularProbs()` uses linear programming to find an optimal mixed strategy.

Mixed strategies for the other games are straightforward to find (since V≠0), via the function `getProbs()`.

The function `combat()` takes a game and plays it for a given number of rounds (the default is 5).

The function `linaia.agon()` takes the number of rounds per game (default 5) and a sequence length 𝓁 (i.e. number of rounds in Choice of Combats), and plays a complete duel with 2𝓁 combats.

The function `xenakis()` takes a number of iterations <i>n</i> (default 1000), rounds per game, and sequence length, and plays <i>n</i> separate duels, printing the number (and percentage) of wins by Linus, ties, and wins by Apollo.

The extra parameter `cc.counts` (False by default) includes wins and losses from Choice of Combats in the final score.

The extra parameter `proportional` (False by default) makes the number of rounds per game proportional to how often the game is played (i.e. the number of times it appears in the sequence generated from Choice of Combats).

## Results
<ul>
<li> The higher the number of rounds and/or sequences, the less are Linus's odds of winning.</li>
<li> Including wins from Choice of Combats (cc.counts=T) raises Linus's chances considerably.</li>
<li> If rounds are proportional to game frequency,  Linus's odds increase — by making rounds shorter.</li>
<li> Linus wins more from 5 rounds in 1 game (n,5,1) than 1 round in 5 games (n,1,5).</li>
</ul>

<ul>
<li> With 10 games of 5 rounds each, Linus wins about 3.2% of the time (0.5% ties, 96.3% Apollo).
<li> At 1 round (excluding wins from Choice of Combats), Linus wins 25% of the time (13.5% ties, 61.5% Apollo).</li>
<li> At 1 round (including wins from Choice of Combats), Linus wins 39.6% of the time (8.77% ties, 51.6% Apollo).</li>
<li> Runtime is linear in iterations (1000 games take 1.22 seconds, 10,000 games take 12.5s).</li>
</ul>

## Possible Extensions
<ul>
<li>Incorporate musical excerpts, to generate a performance of Linaia-Agon</li>
<li>Make graphs to show how results change with different parameters</li>
<li>Make it easier to use different mixed strategies besides the optimal</li>
</ul>

## References
<ul>
<li>Bentley, J. (<a href="http://jtylerbentley.com/files/FormalHarmonic.pdf">2014</a>). “The Formal & Harmonic Structures of Linaia-Agon.” Working Paper.
<li>DeLio, T. (<a href="http://rohandrape.net/ut/rttcc-text/DeLio1987b.pdf">1987</a>). “Structure and Strategy: Iannis Xenakis’ Linaia-Agon.” <i>Interface</i> 16(3), pp. 143-64</li>
<li>Joncas, G. (2019). “Stochastic Game Theory and Iannis Xenakis.” Working paper.</li>
<li>Sluchin, B. (<a href="http://www.iannis-xenakis.org/Articles/Sluchin.pdf">2005</a>). “Linaia-Agon: Towards an Interpretation Based on the Theory,” in Georgaki, A. & Solomos, M. (Eds.). (2005). <i>Proceedings of International Symposium Iannis Xenakis</i>. Athens: University of Athens, pp. 299-311
</ul>
