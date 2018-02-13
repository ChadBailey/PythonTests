#!/bin/bash
#while inotifywait -e modify /sys/class/drm/card0/card0-HDMI-A-2/status #/sys/class/drm/card0/*HDMI*/status; 
#do
	if grep '^connected$' /sys/class/drm/card0/card0-HDMI*/status ;then #/sys/class/drm/card0/*HDMI*/status >/dev/null 2>&1;then 
	    gksu -u gv pacmd set-card-profile 0 output:hdmi-surround;
        echo "$(date) --- HDMI connected" >> /home/gv/Desktop/PythonTests/hdmi.log #full path required
	else
	    gksu -u gv pacmd set-card-profile 0 output:analog-stereo+input:analog-stereo;
	    echo "$(date) --- HDMI disconnected" >> /home/gv/Desktop/PythonTests/hdmi.log #full path required
	fi

#done
exit 0

<<EOF
Sound auto switching to hdmi
https://wiki.archlinux.org/index.php/PulseAudio/Examples#Automatically_switch_audio_to_HDMI
You need to work with udev , systemd and shell

1. create a  new rule file 
nano /lib/udev/rules.d/78-hdmi.rules
KERNEL=="card0", SUBSYSTEM=="drm", ACTION=="change", RUN+="/bin/systemctl start hdmi-sound.service"

PS: rule files can not call shell scripts directly
PS: systemctl path may vary. Find it using which systmctl

2. Create a .service file. Service files can call sh scripts without problem.
nano /etc/systemd/system/hdmi-sound.service
[Unit]
Description=hdmi sound hotplug

[Service]
Type=simple
RemainAfterExit=no
ExecStart=/home/gv/Desktop/PythonTests/hdmisound.sh

[Install]
WantedBy=multi-user.target

3. Reload rules and you are ready
udevadm control --reload-rules

4. Verify that udev calls the required service using #journalctl and scroll to the end.
You should see something like this close to the end
Feb 13 02:21:16 debian systemd[1]: Configuration file /etc/systemd/system/hdmi-sound.service is marked executable. Please remove executable permission bits. Proceeding anyway.
Feb 13 02:21:16 debian systemd[1]: Configuration file /etc/systemd/system/hdmi-sound.service is marked world-writable. Please remove world writability permission bits. Proceeding anyway.
Feb 13 02:21:16 debian systemd[1]: Started hdmi sound hotplug.
Feb 13 02:21:16 debian hdmisound.sh[25807]: connected


EOF

