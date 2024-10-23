sudo apt-get update

# Install XFCE Desktop Environment
sudo apt-get install xfce4 xfce4-goodies -y

# Install TightVNC Server
sudo apt-get install tightvncserver -y

# Configure VNC Server
vncserver :1

#Kill the Initial VNC Session
#You need to kill the initial VNC session to configure the desktop environment properly
vncserver -kill :1
