Raspberry Pi 3 yocto image
================================

Boot speed optimizations
------------------------
Yocto boot optimizations for raspberry pi 3 example image are performed within https://jira.softeq.com/browse/EMBEDU-386

Lately raspberry pi image has been converted to the use of "systemd" and as such
"systemd-analyze" and "systemd-analyze blame" have been used for kernel and userspace boot time profiling.
Below are some boot time metrics based on systmed-analyze:

[Non-optimizable bootloader time]:
	Raspberry Pi 3B+ has a non-optimizable bootloader procedere, that includes:
	- Firmware loading from EEPROM at POWER-ON-RESET 
	- Primary initialization of peripherals
	- Loading and executing bootcode.bin from SD card
	- Loading and executing start.elf from SD card
	- Loading and executing fixup.dat from SD card
	- Loading kernel and dtb from SD card
	In total these procedures take 6-7 seconds of boot time and currenly we do not try to optimize that.
	systemd-analyze does not account this time so let's just add 6.5 seconds to the numbers below to see
	the total boot time.
	

[Raspberry Pi 3B+ (systemd, no boot optimizations)]:

	Startup finished in 3.782s (kernel) + 10.580s (userspace) = 14.362s
	6.946s hciuart.service
	1.766s systemd-random-seed.service
	1.318s dev-mmcblk0p2.device
	 618ms systemd-logind.service
	 543ms systemd-udev-trigger.service
	 445ms systemd-resolved.service
	 365ms systemd-timesyncd.service
	 320ms dev-mqueue.mount
	 282ms sys-kernel-debug.mount
	 255ms systemd-networkd.service
	 231ms tmp.mount
	 228ms bluetooth.service
	 213ms systemd-fsck-root.service
	 204ms kmod-static-nodes.service
	 187ms avahi-daemon.service
	 185ms systemd-udevd.service
	 165ms systemd-journald.service
	 143ms psplash-start.service
	 140ms systemd-sysctl.service
	 112ms rpcbind.service
	 99ms systemd-update-utmp.service
	 80ms systemd-tmpfiles-setup.service
	 68ms systemd-remount-fs.service
	 65ms systemd-tmpfiles-setup-dev.service
	 57ms sys-kernel-config.mount
	 55ms systemd-update-utmp-runlevel.service
	 36ms var-volatile.mount
	 35ms systemd-journal-flush.service
	 22ms systemd-rfkill.service


[Raspberry Pi 3B+ (systemd, have boot optimizations)]:
SECOND BOOT:
    Startup finished in 2.868s (kernel) + 2.323s (userspace) = 5.191s 
    multi-user.target reached after 2.231s in userspace
    1.507s dev-mmcblk0p2.device                
     463ms systemd-udev-trigger.service        
     456ms systemd-resolved.service            
     323ms systemd-timesyncd.service           
     320ms systemd-logind.service              
     234ms systemd-fsck-root.service           
     197ms systemd-networkd.service            
     183ms systemd-udevd.service               
     164ms systemd-journald.service            
     103ms rpcbind.service                     
      92ms dev-mqueue.mount                    
      88ms systemd-sysctl.service              
      88ms systemd-tmpfiles-setup.service      
      87ms sys-kernel-debug.mount              
      82ms systemd-random-seed.service         
      81ms tmp.mount                           
      77ms kmod-static-nodes.service           
      70ms systemd-update-utmp.service         
      62ms systemd-tmpfiles-setup-dev.service  
      57ms systemd-update-utmp-runlevel.service
      53ms systemd-remount-fs.service          
      41ms systemd-rfkill.service              
      39ms sys-kernel-config.mount             
      37ms systemd-journal-flush.service       
      18ms var-volatile.mount           

FIRST BOOT:
    Startup finished in 2.867s (kernel) + 3.248s (userspace) = 6.116s 
    multi-user.target reached after 2.274s in userspace
    1.850s systemd-random-seed.service (eliminated on second boot)
    1.464s dev-mmcblk0p2.device                
     439ms systemd-udev-trigger.service        
     385ms systemd-resolved.service            
     325ms systemd-timesyncd.service           
     296ms systemd-logind.service              
     260ms systemd-fsck-root.service           
     205ms systemd-networkd.service            
     198ms systemd-udevd.service               
     152ms systemd-journald.service            
      98ms systemd-rfkill.service              
      95ms dev-mqueue.mount                    
      94ms systemd-sysctl.service              
      92ms systemd-update-utmp.service         
      90ms sys-kernel-debug.mount              
      85ms tmp.mount                           
      85ms rpcbind.service                     
      83ms systemd-tmpfiles-setup.service      
      82ms kmod-static-nodes.service           
      70ms systemd-update-utmp-runlevel.service
      61ms systemd-tmpfiles-setup-dev.service  
      48ms systemd-remount-fs.service          
      43ms sys-kernel-config.mount             
      33ms systemd-journal-flush.service       
      19ms var-volatile.mount  


[What has been done?]:
	- Disabled hciuart.service. This service detects bluetooth module on a raspberry pi, asks the bluetooth module ids and uploads corresponding firmware binary, located on the SD card, all done via UART communication. This service takes up ~7 seconds to launch, so disabling it really cuts userspace boot time.
	- Improved systemd-random-seed.service boot time. This service waits for random pool availability in the kernel by blocking on /dev/random read operation. Fine tuning service config files helps us only do that at FIRST BOOT, so the 1.5 seconds, taken by this service only take once at FIRST BOOT. Next boots use previously cached data to initialize random pool to start much faster by the same service.
	- Disabled avahi-daemon.service. This service is not always needed, although it has it's usecases. In general it provides mdns capability to the running Raspberry, so that it can introduce itself to the local network by it's hostname.
	- Disabled psplash-start.service. This service is loading the splash image from SD card and shows it instead of systemd/kernel bootup logs. This itself will not work great if we do not disable systemd/kernel log printing to the screen as it can also take a lot of time, so the kernel command line should also be appended with "quiet" parameter, which we also do.

