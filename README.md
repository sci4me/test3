# test3
This is just some (bad) debug code I'm using to try and figure out what the heck is wrong with my 65c02 computer.

The issue I'm observing is that interrupt handlers appear to be returning to an incorrect location in memory.
Basically, any code in the "main context" (what to call this? not "main thread"... since there are no threads...) works correctly _until the first interrupt_.

Even if I make the interrupt handler as simple as possible (just clear the interrupt and `rti`), the same failure occurs.

In main.s, I have `isr_via2` counting up and incrementing `leds_value` once per second. `leds_value` is the value that gets written to the 7-segment LEDs.
In the "main context" (the loop at the end of the `reset` procedure) I am calling `leds_update` to do the pseudo-PWM to drive the LEDs.

The behavior I observe when running the code, as it is in this commit, is that the LEDs turn on very briefly, as they're being driven in that main loop, but then
turn off and never turn on again, as soon as the first interrupt occurs.

I have spent a significant amount of time tinkering and debugging with this, but gotten essentially nowhere. 
The first most obvious culprit would be either stack pointer "corruption" (push without pop, pop without push, etc.).
Next would be the possibility that the data in the stack itself is being erroneously overwritten.
I have yet to find either of these errors in the code. Maybe it's obvious and a second pair of eyes will spot in no time. (*crosses fingers*)

Beyond those possibilities, I fear that it could actually be a hardware problem. However, I am skeptical of this because all the code I've written that
runs in interrupts seems to work flawlessly. I suppose this doesn't guarantee that the hardware isn't at fault, but it strongly suggests it, to me.

I'll update this as more is learned. Any help is GREATLY appreciated!