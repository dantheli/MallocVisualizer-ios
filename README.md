# MallocVisualizer

MallocVisualizer is an iOS app written in Swift that can call heaplib functions written in C as specified in CS 3410 and display them in a pretty interface. You can init, alloc, release, and resize.
I'm not responsible for any damage done to your phone/computer if you allocate a super large heap (no damage should be done though).

![alt tag](https://raw.githubusercontent.com/dantheli/MallocVisualizer-ios/master/Resources/screenshot.PNG)

## To Use
Open the .xcodeproj file. Paste in your heaplib implementation into heaplib.c under the malloc folder in the project pane.
Remove #include "heaplib.h" if it exists. Make sure have:
~~~~
#include "MallocVisualizer-Bridging-Header.h"
~~~~
Hopefully you can build the project either through the simulator or on your own iPhone or iPad. If not, then fix any compilation errors. (the iPad experience is much better).

## Install on your iPhone or iPad


## Troubleshooting
Probably your Xcode or (God forbid) macOS installation should be updated.
