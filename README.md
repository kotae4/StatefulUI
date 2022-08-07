# StatefulUI #

A buggy, half-finished, and fully-abandoned UI system written in Lua atop the [LÖVE](https://love2d.org/) game framework.<br>
As with a lot of my projects, this started out as a game idea but once I got into it I decided to implement my own systems instead of using other people's (much better) systems. This time it happened to be a UI system that diverted me from my original game idea and that's what you're looking at.<br>
There are a lot of edge cases and bugs that I still need to iron out, and I wanted to include a lot more UI elements (like graphs and color palettes and whatnot) but I never got around to it.<br>
Still, I learned a lot about the design of event systems and how important the **specifics** of event propagation can be! I'm most proud of my 'button within a button' functionality and how hover and press events work as expected for the inner button :smiley:

## Third-Party Notices ##

This project makes use of other people's stuff.<br>
Refer to the `third-party-code` folder and the `licenses` folder.<br>
All images are made using the built-in shapes in Paint.NET.