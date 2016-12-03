# MallocVisualizer

MallocVisualizer is an iOS app written in Swift that can call heaplib functions written in C as specified in CS 3410 and display them in a pretty interface. You can init, alloc, release, and resize.
I'm not responsible for any damage done to your phone/computer if you allocate a super large heap (no damage should be done though).

![alt tag](https://raw.githubusercontent.com/dantheli/MallocVisualizer-ios/master/Resources/screenshot.PNG)

## To Use
Open the .xcodeproj file. Paste in your heaplib implementation into heaplib.c under the malloc folder in the project pane.
Remove #include "heaplib.h" if it exists. Make sure to have:
~~~~
#include "MallocVisualizer-Bridging-Header.h"
~~~~
Hopefully you can build the project either through the iOS simulator or on your own iPhone or iPad. If not, then fix any compilation errors. Since your implementation, including any definitions, should all be in heaplib.c, the bridging header file should be fine.

You can now create blocks and see them visually.

**To resize or free blocks:** swipe left on any of the blocks in the table.

## Install on your iPhone or iPad (the iPad experience is much better)
You need an Apple Developer account (it's free). Select your team in the Xcode project. Now you can malloc on the go! I'm not sure why you would want to do that.


## Troubleshooting
Probably your Xcode or (God forbid) macOS installation should be updated.

Keep in mind this visualizer is for looks only and assumes a good, working malloc implementation. It's not a debugger, but I'm sure you could debug using it.

## Halp
There are bugs for sure.
