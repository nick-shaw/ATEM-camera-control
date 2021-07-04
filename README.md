# ATEM-camera-control
A simple app to control a Blackmagic camera via an ATEM switcher

Tested only with my ATEM Mini and Pocket Cinema Camera 4K

![Main Window](./images/main_window.png)![Grading Window](./images/grading_window.png)

## Notes:

* This is just a simple experiment for my own amusement. You may use it freely, but it comes with no guarantees whatsoever!

* Pressing and holding any of the ***Memory*** buttons at the bottom for three seconds stores the current settings.

* Pressing one momentarily restores the settings.

* There is no feedback from the camera to the app. Therefore using the ***Auto Iris*** or ***Auto Focus*** buttons will put the focus and iris sliders out of sync with the camera.

* The LUT controls have no effect. At least not on my camera. It seems that is not implemented on the Pocket 4K. Perhaps it works on other cameras.


## About
* The main application code is Copyright (c) 2021 Antler Post

* The ATEM Switcher SDK is Copyright (c) 2020 Blackmagic Design

* This software is released under terms of New BSD License: [https://opensource.org/licenses/BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause)