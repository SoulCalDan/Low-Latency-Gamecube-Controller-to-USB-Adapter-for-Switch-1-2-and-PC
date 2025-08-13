This is an open source FPGA based USB adapter to connect a Nintendo Gamecube controller to Switch 1|2 and PC. The adapter in Switch mode mimics the official Nintendo Gamecube adapter, but with significantly less latency. This adapter is made with Gamecube NSO (Nintendo Switch Online) in mind, and fixes the joystick calibration issue present in Nintendo's Gamecube emulator, allowing for improved joystick control in games like F-Zero GX and camera controls in Wind Waker. Total cost of project from the FPGA board used (Tang Nano 9k), Gamecube connectors, PCB order, and 3D printed parts is currently at $42 per adapter.

Features:
1. Sub 1ms latency! - timed from Gamecube button press to USB packet transfer.
     PC polling rate natively at 1000Hz in both GC and PC Modes
     Switch 1|2 polling rate is console limited at 125Hz
3. Fix Gamecube NSO joystick calibration with a press of a button. 
4. 4 player support, for games like Super Smash Bros Ultimate and the catalog of Gamecube NSO multiplayer games.
5. Native Dolphin emulator support. No driver changes, no need to reconfigure polling rate, it just works.
6. Separate firmware available to configure the adapter in PC Mode to act as a XBOX360 controller on Windows/Linux, with 1000Hz native polling.
7. Fully open source FPGA Verilog code, PCB schematics, 3D printed case, and firmware update tool.
   
![PXL_20250812_210435340 MP](https://github.com/user-attachments/assets/6a2e6cdd-a9af-49cd-94a5-abf7ec3f653b)
![PXL_20250812_210521479 MP](https://github.com/user-attachments/assets/0defaece-58ec-45e0-8d86-69b8bbf838ce)
![PXL_20250812_210556207 MP](https://github.com/user-attachments/assets/4f49512a-7d50-471b-9d27-b3cb9da89b82)

Future Features:
1. 4 Player PC Mode - currently only supports 1 Player
2. LCD Screen button input display
3. Combined firmware for all features
4. Nintendo 64 controller support for N64 NSO and PC
5. PCB updates to use a different (cheaper) FPGA

Known Issues:
1. NYXI brand controllers pull too much current, and are not expected to work. All tested controllers work including official, Smash Bros branded, Phob 2.x, ProGCC, and Hori pads.

Special Thanks:     
1.This project would not be possible without the available open source USB FPGA implementation from Wang Xuan. Thanks so much for the available FPGA resources for the various USB cores. https://github.com/WangXuan95/FPGA-USB-Device . This Gamecube Adapter uses a modified version of the USB-HID core to accept Gamecube Controller data. <br> 2. Bootloader to flash the firmware (.fs) used from the open source implementation of the Time Sleuth Tang Nano 4k, modified to work with Tang Nano 9k. Thank you, pthalin. https://github.com/pthalin/video_lag_tester/tree/main
