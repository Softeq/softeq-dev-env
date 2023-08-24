Refreshing U-Boot for dev board Nitrogen6x.
-------------------------------------------

To install clear U-Boot to the dev board nitrogen6x, you need to do the following steps:

  - connect dev board to your host PC throw the J3 connector on the board;
  - download file u-boot.nitrogen6q using link 1 on the bottom of this README;
  - install uuu utility to your host pc and run it using the prev downloaded file (link 4);
  - do all actions step by step using link 4.
  - finish.

If it doesn't work after prev actions, you need to upgrade U-Boot.
Do the next step by step:

  - insert your SD-card with 2 files upgrade.scr and u-boot.nitrogen6q to the dev board (getting files by link 2);
  - run all steps using link 5;
  - run screen or putty utility to get access to the board (br - 115200);  
  - do the following commands on the board console:
    - fatload mmc 0:0 0x10000000 upgrade.scr;
    - setenv devtype mmc;
    - setenv devnum 0;
    - setenv distro_bootpart 0;
    - source 0x10000000.
    
If it doesnt work, enter next commands:

  - ext4load mmc 0 0x10000000 6x_upgrade;
  - source 0x10000000.
  
To show your env use "env default -a"
To save your env use "saveenv".  
Another information you can get by link 3.

Links:

1. U-Boot download link for Nitrogen6x - https://boundarydevices.com/u-boot-v2017-07/
2. U-Boot Images + upgrade.scr - http://linode.boundarydevices.com/u-boot-images-2017.07/
3. U-Boot Tutorial - http://denx.de/wiki/DULG/UBoot
4. UUU Utility - https://boundarydevices.com/recovering-i-mx-platforms-using-uuu/
5. How to Upgrade U-Boot - https://boundarydevices.com/how-to-upgrade-u-boot/
