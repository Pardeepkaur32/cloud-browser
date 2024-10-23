sudo apt-get update

# Install XFCE Desktop Environment
sudo apt-get install xfce4 xfce4-goodies -y

# Install TightVNC Server
sudo apt-get install tightvncserver -y

# Configure VNC Server
vncserver :1
#enter password which is mention indockerfile


#Kill the Initial VNC Session (optional when require only then)
#You need to kill the initial VNC session to configure the desktop environment properly
vncserver -kill :1

# Configure VNC to Use XFCE Desktop
Now, configure VNC to use the XFCE desktop environment. To do this, edit the startup script for VNC:

nano ~/.vnc/xstartup


# In the xstartup file, replace its contents with the following lines to launch the XFCE desktop:

#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &

chmod +x ~/.vnc/xstartup

#start vnc
vncserver :1


