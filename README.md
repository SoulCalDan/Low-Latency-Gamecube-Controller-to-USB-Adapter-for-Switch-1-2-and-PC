This is an open source FPGA based USB adapter to connect a Nintendo Gamecube controller to Switch 1|2 and PC. The adapter in Switch mode mimics the official Nintendo Gamecube adapter, but with significantly less latency. This adapter is made with Gamecube NSO (Nintendo Switch Online) in mind, and fixes the joystick calibration issue present in Nintendo's Gamecube emulator, allowing for improved joystick control in games like F-Zero GX and camera controls in Wind Waker. Total cost of project from the FPGA board used (Tang Nano 9k), Gamecube connectors, PCB order, and 3D printed parts is currently at $42 per adapter.

Features: <br>
1. Sub 1ms latency! - timed from Gamecube button press to USB packet transfer.
     - PC polling rate natively at 1000Hz in both GC and PC Modes <br>     Switch 1 polling rate is console limited at 125Hz.  <br> Switch 2 polling rate is increased to 1000Hz for NSO mode.
3. Fix Gamecube NSO joystick calibration with a press of a button. <br>     Acts as a wired Gamecube NSO controller, or a Switch 2 Pro Controller.
4. 4 player support, for games like Super Smash Bros Ultimate and the catalog of Gamecube NSO multiplayer games.
6. Native Dolphin emulator support. No driver changes, no need to reconfigure for 1000Hz polling rate, just plug and play for the lowest latency possible.
7. Separate firmware available to configure the adapter in PC Mode to act as a XBOX360 controller on Windows/Linux, with 1000Hz native polling.
     - To avoid flashing firmware to the adapter, you can use "Delfinovin" software to act as a XBOX360 controller on PC
8. Fully open source FPGA Verilog code, PCB schematics, 3D printed case, and firmware update tool.
   
<img width="2378" height="1230" alt="image" src="https://github.com/user-attachments/assets/3f0b269d-63e4-4065-97d9-30fc0effc2b5" />
<img width="2403" height="1299" alt="image" src="https://github.com/user-attachments/assets/5cbef871-e9ff-4faf-b460-df413746858b" />
<img width="2573" height="1461" alt="image" src="https://github.com/user-attachments/assets/a2a437f2-6622-4671-8cb1-c23824ddbabd" />
<img width="1990" height="785" alt="image" src="https://github.com/user-attachments/assets/b25c432e-2291-4d5a-b29f-25b5191b5798" />

Future Features: <br>
2. LCD Screen button input display
4. Nintendo 64 controller support for N64 NSO and PC
5. PCB updates to use a different (cheaper) FPGA

Known Issues: <br>
1. NYXI brand controllers pull too much current, and are not expected to work. (NYXI has polling issues using other adapters, but the official Nintendo branded ones work with NYXI brand products)
     - All tested controllers work including official, Smash Bros branded, Phob 2.x, ProGCC, and Hori pads.
2. Connection to USB Hubs with other HIDs (mouse, keyboard, other controllers) may cause disconnects. May be driver related, but not sure. Just don't use a USB Hub if this causes an issue.

Special Thanks: <br>
1. This project would not be possible without the available open source USB FPGA implementation from Wang Xuan. Thanks so much for the available FPGA resources for the various USB cores.                     https://github.com/WangXuan95/FPGA-USB-Device . This Gamecube Adapter uses a modified version of the USB-HID core to accept Gamecube Controller data. <br>
2. Bootloader to flash the firmware (.fs) used from the open source implementation of the Time Sleuth Tang Nano 4k, modified to work with Tang Nano 9k. Thank you, pthalin.                     https://github.com/pthalin/video_lag_tester/tree/main <br>

Parts Ordering:
All parts except the PCB can be ordered with AliExpress. Gamecube connectors can be ordered in packs of 10 from the seller XOXNXEX. Any Tang Nano 9k seller is fine on AliExpress for about $23 a board. I will not provide links here due to listing frequent changing and delisting. Amazon is not recommended due to the markup and availability. 

Contact: Discord @ soulumbreon with a message (not friend request) for inquiries. I will be selling a limited number of these adapters to the public.
