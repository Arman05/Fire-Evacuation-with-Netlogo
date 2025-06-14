Globals [
  exited
  deaths
]

breed [fires fire]
breed [people person]
breed [bombs bomb]

people-own
[
  state
]

to setup
  ca
  reset-ticks

  setup-patches
  setup-people
  setup-fires
  setup-bombs
end

to Go
  tick
  people-move
  if ticks > start-fire [ignite]
  if exited + deaths = 220 [
    show deaths
    show exited
    show ticks
    clear-turtles
    setup-patches
    stop
  ]

end


to setup-people
  set-default-shape people "person"


  let peoplelist create-peoplelist 30 10   ; 30 is the number of people and 10 is starting value of i, the list

  ;People are arranging themselves in rows in coordinates from the list
  foreach peoplelist [ [i] -> create-people 1 [setxy i 10 set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 8  set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 6  set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 4  set heading 180]]

  ;create-peoplelist2 increments by 2
  set peoplelist create-peoplelist2 10 18  ; 10 is the number of people and 8 is starting value of i, the list

  ;People are arranging themselves in columns  in coordinates from the list
  foreach peoplelist [ [i] -> create-people 1 [setxy 2 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 4 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 6 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 8 i set heading 180]]

  ;create-peoplelist2 increments by 2
  set peoplelist create-peoplelist2 10 18  ; 10 is the number of people and 8 is starting value of i, the list

  foreach peoplelist [ [i] -> create-people 1 [setxy 41 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 43 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 45 i set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy 47 i set heading 180]]

  ;create-peoplelist5 increments by 3
  set peoplelist create-peoplelist5 5 14  ; 5 is the number of people and 14 is starting value of i, the list
  foreach peoplelist [ [i] -> create-people 1 [setxy i 44 set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 42 set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 40 set heading 180]]
  foreach peoplelist [ [i] -> create-people 1 [setxy i 38 set heading 180]]

  ask people [ set color cyan ]

end

; Takes two values(number of values,initial value of the list) as input and returns a list of values with increment 1
to-report create-peoplelist [input1 input2]
  report n-values (input1) [ [i] -> input2 + 1 * i]
end

; Takes two values(number of values,initial value of the list) as input and returns a list of values with increment 2
to-report create-peoplelist2 [input1 input2]
  report n-values (input1) [ [i] -> input2 + 2 * i]
end

; Takes two values(number of values,initial value of the list) as input and returns a list of values with increment 5
to-report create-peoplelist5 [input1 input2]
  report n-values (input1) [ [i] -> input2 + 5 * i]
end


to setup-patches
  ask patches
  [

    ; Setting 3 exits
    if pxcor = 50  and pycor > 0 and pycor < 11 [ set pcolor green ] ; right exit
    if pxcor = 0  and pycor > 0 and pycor < 11 [ set pcolor green ] ; left exit
    if field-exit[
      if pxcor = 23 and pycor = 31 [ set pcolor green ];
    ]

    if pycor = 50  and pxcor > 10 and pxcor < 22 [ set pcolor red ] ; top exit

    ; Setting field walls
    if pxcor > 9 and pxcor < 39 and pycor = 20 [ set pcolor gray]
    if pxcor = 10 and pycor > 20 and pycor < 51 [ set pcolor gray ]
    if pxcor = 38 and pycor > 20 and pycor < 51 [ set pcolor gray ]

    ; Setting floor white
    if pcolor = black [ set pcolor white ]
  ]

  ask patches with [ pcolor = gray ] [ ask neighbors with [ pcolor = white ] [set pcolor 9 ]]

end

to setup-fires
  set-default-shape fires "fire"

  ; Setting location and color of the fire initiation
  ask patches with [pxcor = 7 and pycor = 49] [sprout-fires 1]
  ask patches with [pxcor = 43 and pycor = 49] [sprout-fires 1]
  ask fires [set color red]

end


to people-move

  ask people [
    ;if people reach patch color red or green they have reached the exit safely
    ifelse [pcolor] of patch-here = green or [pcolor] of patch-here = red
    [
      set state "exited"
    ]
    [
      ;if patch-ahead 0 != nobody [
        people-choose-exit
        forward people-speed

        if tracker [
          pen-down
        ]
      ;]
    ]
  ]

  ask people[
    if state = "exited" [
      set exited exited + 1   ; Counting Number of people safely exited
      die
    ]
  ]
end

to people-choose-exit

  ; for people above the pycor 37 move towards red exit otherwise move towards green exit
  ifelse pycor > 37
  [
    face min-one-of (patches with [pcolor = red])[distance myself]  ; Exit Field Player with the red exit
  ]
  [
    face min-one-of (patches with [pcolor = green ])[distance myself]  ; Exit Gallery People using the green exit
  ]

end



to ignite
  ask fires [
    if ticks mod slow-fire-spread = 0 [
      if one-of neighbors with [pcolor = white] != nobody
      [
        ask one-of neighbors with [pcolor = white ]
        [
          sprout-fires 1 [set color red]
          set pcolor black
        ]
      ]

    ]
    ; People in radius 5 will panic and start wiggling
    ask people in-radius 5 [
      set color red
      fd 0.80
      wiggle
    ]
    ; People who gets too close in contact with fire (radius 2) will die
    ask people in-radius 2 [
      set deaths deaths + 1
      die
    ]
  ]
end

to wiggle
  right random 90
  left random 90
end

;--------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------

to bomb-go
  tick
  ask bombs[explode]
  people-move
end


to setup-bombs
  set-default-shape bombs "x"

  ask patches with [pxcor = 5 and pycor = 28] [sprout-bombs 1]
  ask patches with [pxcor = 44 and pycor = 28] [sprout-bombs 1]
  ask bombs [set color red]

end

to explode
  ask  bombs [

    ;People in radius 3 will panic and avoid the area of explosion
    ask people in-radius explosion-radius [
      set color red

      if pxcor < 10 and pycor > 28[
        face min-one-of bombs [distance myself]  ; setting heading towards the nearest bomb
        right 90
        fd 1
      ]
      if pxcor > 39 and pycor > 28[
        face min-one-of bombs [distance myself]  ; setting heading towards the nearest bomb
        left 90
        fd 1

      ]
    ]

    ;people 0.5 radius closer to the explosion dies
    ask people in-radius (explosion-radius - 0.5)
    [
      set deaths deaths + 1
      die
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
243
13
914
685
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
50
0
50
1
1
1
ticks
30.0

BUTTON
15
43
78
76
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
85
43
149
77
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
15
92
90
126
go once
go
NIL
1
T
OBSERVER
NIL
O
NIL
NIL
1

SLIDER
15
210
187
243
start-fire
start-fire
0
50
0.0
10
1
NIL
HORIZONTAL

SWITCH
100
97
204
130
tracker
tracker
0
1
-1000

BUTTON
22
435
105
468
Explosion
bomb-go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
16
254
188
287
slow-fire-spread
slow-fire-spread
1
4
1.0
1
1
NIL
HORIZONTAL

SLIDER
3
302
236
335
people-speed
people-speed
0.1
0.4
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
16
363
188
396
explosion-radius
explosion-radius
0
3
3.0
0.5
1
NIL
HORIZONTAL

PLOT
933
28
1133
178
Deaths vs Total Exited
Ticks
Number
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Exited" 1.0 0 -16777216 true "" "plot exited"
"Deaths" 1.0 0 -2674135 true "" "plot deaths"

SWITCH
19
152
123
185
field-exit
field-exit
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

It is a simulation of fire evacuation in stadium . This simulation studies how: 

1) People's speed of movement
2) Fire spreading speed
4) Starting Time of Fire 
3) Radius of explosion 

affects the number of deaths and number of safely exited people for fire hazards and bomb hazards

In case of fire, we simulated a panic behavior by changing their motion from a straight line 
to wiggle motion.


## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>deaths</metric>
    <metric>exited</metric>
    <steppedValueSet variable="start-fire" first="0" step="10" last="30"/>
    <enumeratedValueSet variable="field-exit">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="people-speed" first="0.1" step="0.1" last="0.5"/>
    <enumeratedValueSet variable="tracker">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="slow-fire-spread" first="1" step="1" last="4"/>
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
0
@#$#@#$#@
