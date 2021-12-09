turtles-own
  [ sick0?                ;; if true, the turtle is infectious
    exposed0?             ;; if true, the turtle is exposed (incubation period)
    sick1?
    exposed1?
    remaining-incubation ;; how long the incubation period is
    remaining-immunity   ;; how many days of immunity the turtle has left
    sick-time            ;; how long, in days, the turtle has been infectious
    age ]                ;; how many days old the turtle is

globals
  [ %infected0            ;; what % of the population is infectious
    %exposed0             ;; what % of the population is exposed
    %infected1            ;; what % of the population is infectious
    %exposed1             ;; what % of the population is exposed
    %immune              ;; what % of the population is immune (Recovered)
    lifespan             ;; the lifespan of a turtle
    chance-reproduce     ;; the probability of a turtle generating an offspring each tick
    number-people        ;; initial number of people
    carrying-capacity    ;; the number of turtles that can be in the world at one time
    immunity-duration ]  ;; how many days immunity lasts

;; The setup is divided into four procedures
to setup
  clear-all
  setup-constants
  setup-turtles
  update-global-variables
  update-display
  reset-ticks
end

;; We create a variable number of turtles of which 10 are exposed,
;; and distribute them randomly
to setup-turtles
  create-turtles number-people
    [ setxy random-xcor random-ycor
      set age random lifespan
      set sick-time 0
      set remaining-immunity 0
      set size 1
      get-healthy ]
  ask n-of 5 turtles
    [ get-exposed0 ]
  ask n-of 5 turtles with [not exposed0?]
    [ get-exposed1]
end

to get-exposed0 ;; turtle procedute
  set exposed0? true
  set remaining-incubation 4
end

to get-exposed1 ;; turtle procedute
  set exposed1? true
  set remaining-incubation 4
end

to get-sick0 ;; turtle procedure
  set exposed0? false
  set sick0? true
  set remaining-immunity 0
end

to get-sick1 ;; turtle procedure
  set exposed1? false
  set sick1? true
  set remaining-immunity 0
end

to get-healthy ;; turtle procedure
  set sick0? false
  set exposed0? false ;; Must be false here; needed for setup / initializing
  set sick1? false
  set exposed1? false ;; Must be false here; needed for setup / initializing
  set remaining-immunity 0
  set sick-time 0
end

to become-immune ;; turtle procedure
  set sick0? false
  set sick1? false
  set sick-time 0
  set remaining-immunity immunity-duration
end

;; This sets up basic constants of the model.
to setup-constants
  set lifespan 80 * 52 * 7    ;; 80 times 52 weeks times 7 days per week = approx. 80 years
  set carrying-capacity 3 * 500
  set number-people carrying-capacity
  set chance-reproduce 1
  set immunity-duration 4 * 30 ;; n * 30; n months of immunity
end

to go
  ;;stop if nobody is sick or exposed => variant is wiped out
  if (count turtles with [sick0?] = 0 and count turtles with [exposed0?] = 0) or (count turtles with [sick1?] = 0 and count turtles with [exposed1?] = 0)
  ;;or (%infected = 100 )
  [stop]

  ask turtles [
    get-older
    if not sick0? and not sick1? [move]
    if sick0? or sick1? [ recover-or-die ]
    ifelse sick0? [ infect0 ] [ ifelse sick1? [infect1] [reproduce] ]
  ]
  update-global-variables
  update-display
  tick
end

to update-global-variables
  if count turtles > 0
    [ set %infected0 (count turtles with [ sick0? ] / count turtles) * 100
      set %exposed0 (count turtles with [ exposed0? ] / count turtles) * 100
      set %infected1 (count turtles with [ sick1? ] / count turtles) * 100
      set %exposed1 (count turtles with [ exposed1? ] / count turtles) * 100
      set %immune (count turtles with [ immune? ] / count turtles) * 100
  ]
end

to update-display
  ask turtles
    [ set shape "person"
      set color ifelse-value sick0? [ red ] [ ifelse-value immune? [ grey ] [ ifelse-value exposed0? [yellow] [ ifelse-value sick1? [violet] [ifelse-value exposed1? [pink] [green] ] ] ] ] ]
end

;;Turtle counting variables are advanced.
to get-older ;; turtle procedure
  ;; Turtles die of old age once their age exceeds the
  ;; lifespan (set at 50 years in this model).
  set age age + 1
  if age > lifespan [ die ]
  if immune? [ set remaining-immunity remaining-immunity - 1 ]
  if exposed0? or exposed1? [ set remaining-incubation remaining-incubation - 1 ]
  if exposed0? [ if remaining-incubation = 0 [get-sick0]]
  if exposed1? [ if remaining-incubation = 0 [get-sick1]]
  if sick0? or sick1? [ set sick-time sick-time + 1 ]
end

;; Turtles move about at random.
to move ;; turtle procedure
  rt random 100
  lt random 100
  fd 1
end

;; If a turtle is sick, it infects other turtles on the same patch.
;; Immune turtles don't get sick.
to infect0 ;; turtle procedure
  ask other turtles-here with [ not (sick0? or sick1?) and not immune? and not (exposed0? or exposed1?)] ;; with healthy?
    [ if random-float 100 < infectiousness
      [ get-exposed0 ] ]
end

;; If a turtle is sick, it infects other turtles on the same patch.
;; Immune turtles don't get sick.
to infect1 ;; turtle procedure
  ask other turtles-here with [ not (sick0? or sick1?) and not immune? and not (exposed0? or exposed1?)] ;; with healthy?
    [ if random-float 100 < infectiousness
      [ get-exposed1 ] ]
end

;; Once the turtle has been sick long enough, it
;; either recovers (and becomes immune) or it dies.
to recover-or-die ;; turtle procedure
  if sick-time > duration                        ;; If the turtle has survived past the virus' duration, then
    [ ifelse random-float 100 < chance-recover   ;; either recover or die
      [ become-immune ]
      [ die ] ]
end

;; If there are less turtles than the carrying-capacity
;; then turtles can reproduce.
to reproduce
  if count turtles < carrying-capacity and random-float 100 < chance-reproduce
    [ hatch 1
      [ set age 1
        lt 45 fd 1
        get-healthy ] ]
end

to-report immune?
  report remaining-immunity > 0
end

to startup
  setup-constants ;; so that carrying-capacity can be used as upper bound of number-people slider
end

;; defining aliases for CSV
to-report n-people-sick-var0
  report count turtles with [sick0?]
end

to-report n-people-sick-var1
  report count turtles with [sick1?]
end

to-report n-people-total
  report count turtles
end

to-report n-people-immune
  report count turtles with [immune?]
end

to-report n-people-healthy
  report count turtles with [ not (sick0? or sick1?) and not immune? and not (exposed0? or exposed1?)] ;; with healthy?
end

to-report n-people-exposed-var0
  report count turtles with [exposed0?]
end

to-report n-people-exposed-var1
  report count turtles with [exposed1?]
end

; Copyright 1998 Uri Wilensky, extended from SIR to SEIR in 2021 by Ferdinand König
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
280
10
778
509
-1
-1
14.0
1
10
1
1
1
0
1
1
1
-17
17
-17
17
1
1
1
ticks
30.0

SLIDER
40
155
234
188
duration
duration
0.0
99.0
15.0
1.0
1
days
HORIZONTAL

SLIDER
40
121
234
154
chance-recover
chance-recover
0.0
99.0
95.0
1.0
1
%
HORIZONTAL

SLIDER
40
87
234
120
infectiousness
infectiousness
0.0
99.0
9.0
1.0
1
%
HORIZONTAL

BUTTON
62
48
132
83
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
138
48
209
84
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
820
25
1465
445
Populations
days
people
0.0
52.0
0.0
200.0
true
true
"" ""
PENS
"sick0" 1.0 0 -2674135 true "" "plot n-people-sick-var0"
"immune" 1.0 0 -7500403 true "" "plot n-people-immune"
"healthy" 1.0 0 -10899396 true "" "plot n-people-healthy"
"total" 1.0 0 -13345367 true "" "plot n-people-total"
"exposed0" 1.0 0 -1184463 true "" "plot n-people-exposed-var0"
"sick1" 1.0 0 -8630108 true "" "plot n-people-sick-var1"
"exposed1" 1.0 0 -2064490 true "" "plot n-people-exposed-var1"

MONITOR
105
328
179
373
NIL
%immune
1
1
11

MONITOR
181
329
253
374
months
ticks / 30
1
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulates the transmission and perpetuation of a virus in a human population.

Ecological biologists have suggested a number of factors which may influence the survival of a directly transmitted virus within a population. (Yorke, et al. "Seasonality and the requirements for perpetuation and eradication of viruses in populations." Journal of Epidemiology, volume 109, pages 103-123)

Extension: Moved from SIR model to SEIR model. Parameters set in a way that the virus is emerging in waves.

Extension: Now, 2 variants

## HOW IT WORKS

The model is initialized with 1500 people, of which 10 (50:50) are infected.  People move randomly about the world in one of three states: healthy but susceptible to infection (S: green), healthy but exposed (E: yellow, pink), and healthy and immune (gray). If a person is sick and infectious (I: red, violet) a person stops moving. People may die of infection or old age.  When the population dips below the environment's "carrying capacity" (set at 1500 in this model) healthy people may produce healthy (but susceptible) offspring.

Some of these factors are summarized below with an explanation of how each one is treated in this model.

### The density of the population

Population density affects how often infected, immune and susceptible individuals come into contact with each other.

### Population turnover

As individuals die, some who die will be infected, some will be susceptible and some will be immune.  All the new individuals who are born, replacing those who die, will be susceptible.  People may die from the virus, the chances of which are determined by the slider CHANCE-RECOVER, or they may die of old age.

In this model, people die of old age at the age of 80 years.  Reproduction rate is constant in this model.  Each turn, if the carrying capacity hasn't been reached, every healthy individual has a 1% chance to reproduce.

### Transitions

S -> E0, E1 (gets exposed with a certain chance if in contact with sick person)
S,E0,E1,I0,I1,R -> D (dies of old age)
I0, I1 -> R | D (gets healthy and immune or dies)
E0 -> I0 (from exposed to infectous after 4 days)
E1 -> I1 (from exposed to infectous after 4 days)
R -> S (immunity is limited)

## HOW TO USE IT

Each "tick" represents a day in the time scale of this model.


## VISUALIZATION

The circle visualization of the model comes from guidelines presented in
Kornhauser, D., Wilensky, U., & Rand, W. (2009). http://ccl.northwestern.edu/papers/2009/Kornhauser,Wilensky&Rand_DesignGuidelinesABMViz.pdf.

At the lowest level, perceptual impediments arise when we exceed the limitations of our low-level visual system. Visual features that are difficult to distinguish can disable our pre-attentive processing capabilities. Pre-attentive processing can be hindered by other cognitive phenomena such as interference between visual features (Healey 2006).

The circle visualization in this model is supposed to make it easier to see when agents interact because overlap is easier to see between circles than between the "people" shapes. In the circle visualization, the circles merge to create new compound shapes. Thus, it is easier to perceive new compound shapes in the circle visualization.
Does the circle visualization make it easier for you to see what is happening?

## RELATED MODELS

* HIV
* Virus on a Network

## CREDITS AND REFERENCES

This model can show an alternate visualization of the Virus model using circles to represent the people. It uses visualization techniques as recommended in the paper:

Kornhauser, D., Wilensky, U., & Rand, W. (2009). Design guidelines for agent based model visualization. Journal of Artificial Societies and Social Simulation, JASSS, 12(2), 1.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U.; Koenig, F. (1998, 2021).  NetLogo Virus model. SEIR and two variants Extension. http://ccl.northwestern.edu/netlogo/models/Virus. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. https://github.com/ferdinand-dhbw/covid-variant-simulation

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky and extension created in 2021 by Ferdinand Koenig.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="initial-experiment-24m" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="720"/>
    <metric>n-total-people</metric>
    <metric>n-healthy-people</metric>
    <metric>n-immune-people</metric>
    <metric>n-exposed-people</metric>
    <metric>n-sick-people</metric>
    <enumeratedValueSet variable="duration">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectiousness">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-recover">
      <value value="95"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
