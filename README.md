# homelab-alpine-linux

Setting up a whole homelab from scratch with :
- Google domain, GoDaddy or any other domain providers
- Cloudflare to handle the HTTP/HTTPS traffic and protect your domain against DDOS and a bunch of other attacks
- Alpine Linux
- Docker
- NGINX as reverse proxy

## Prerequisites :
- Download Alpine Linux **standard** edition : https://alpinelinux.org/downloads/
- Prepare a bootable USB stick (using Rufus) or create a virtual machine
- A wired server (Gigabit+ ethernet cable plugged or USB to Gigabit+ ethernet adapter), we won't rely on any WI-FI
connection for higher bandwidth and lower latency

> 2.5Gbps and 5Gbps ethernet connections are also very welcome! Considering that our server may have an SSD, even mSata
> or 2.5 formats, they can easily handle 300 to 500 Mo/s read and write operations, which is much higher than a regular
> gigabit connection (usually 105-115 Mo/s at best). 2.5Gbps connections are cheap and not overkill these days.

## Get a domain
Name and extension don't matter, as long as you have a real domain you own (even the cheapest one is fine).
A domain is required to expose your homelab to the outside world through HTTPS using SSL certificates.
> `homelab.dev`, `homelab.hk.com`, `homelab.io`, `homelab.tech`, ...

Since you own a domain, you will also own all its subdomains that will create later on :
> `portainer.homelab.dev`, `nextcloud.homelab.hk.com`, `cicd.homelab.io`, `plex.homelab.tech`, ...

## Rely on Cloudflare
- Create new account
- Add the (Google) domain you own
- Identify where you can get your Cloudflare token
- Grab the Cloudflare DNS (two DNS addresses)
- Update the DNS in your Google domain using the ones from Cloudflare
- Wait for Google (a day or two) to update the DNS so that your domain uses Cloudflare DNS

## Preparing a virtual machine

- Download and install QEMU : https://www.qemu.org/download/
- Once QEMU is installed, add the path of QEMU folder to the PATH (user environment variable)
- Open Powershell and run the following commands :
    - Create a folder that will contain your QEMU virtual drives : `mkdir $HOME/.qcow2`
    - Create a virtual drive for Alpine Linux : `qemu-img create -f qcow2 $HOME/.qcow2/alpine-linux-5G.qcow2 5G` since
      5GB should be enough to play around
    - Install Alpine Linux on the virtual drive using the
      ISO : `qemu-system-x86_64 -boot d -cdrom $HOME/Downloads/alpine-standard-3.16.1-x86_64.iso -drive file=$HOME/.qcow2/alpine-linux-5G.qcow2,media=disk,if=virtio -m 8192 -smp 4 -display gtk` (
      this will start the installation process, see step below)
    - Boot Alpine Linux from the virtual
      drive : `qemu-system-x86_64 -boot c -drive file=$HOME/.qcow2/alpine-linux-5G.qcow2,media=disk,if=virtio -m 8192 -smp 4 -net nic,model=virtio -net user,hostfwd=tcp::22-:22 -display gtk`

## Installing Alpine Linux

- Boot Alpine Linux (bare metal, QEMU, VirtualBox, Proxmox, ... whatever)
- Localhost login : `root`
- Install Alpine Linux : run the command `setup-alpine`
    - Select keyboard layout : `none` (default)
    - Enter system hostname : `localhost` (default)
    - Initialise network interface : `eth0` (default)
    - Private IP address : `dhcp` (default)
    - Add any manual network configuration : `n` (default)
    - New root password : `{you decide, must be strong, recommend 12+ chars with figures, lower+upper case and special chars}`
    - Timezone : `?`(so that you can see the list, in my case `Hongkong`
    - HTTP/FTP proxy URL : `none` (default)
    - NTP client : `chrony` (default)
    - Enter mirror : `f` so that it selects the best one wherever your server is
    - Setup a user : `no` (default) since we will do that later
    - SSH server : `openssh` (default)
    - Allow root SSH login : `no` since we will allow only "regular" users to connect to the server remotely
    - Disk to use : pick the one from the available disks list in your console (it should be `sda` or `vda`)
    - How we will the selected disk : `sys`
    - Erase the disk : `y`
- When the installation is done :
    - Install Git : `apk update && apk upgrade && apk add git`
    - Get and write down the MAC address of your network controller : `ifconfig | grep HWaddr | cut -d" " -f11` (should
      look like xx:xx:xx:xx:xx:xx)

## Router settings (TODO)

- Static DHCP bond based on the MAC address of the server's network controller
- Port forwarding TCP+UDP/80 and TCP+UDP/443 to the private IP address of the server
- Reboot your server so that your router assign the right private IP address : `reboot`

## Generating RSA keys from the server

Using your laptop, open Powershell and then :

- Create a folder that will contain SSH keys (may already exist) : `mkdir $HOME/.ssh`
- Generate your SSH keys (RSA 4096) : `ssh-keygen -t rsa -b 4096 -m PEM -f $HOME/.ssh/id_rsa_alpine`

Notice :

- You are encouraged to specify a passphrase so that you protect your private key properly
- Your private RSA will be `$HOME/.ssh/id_rsa_alpine` and your public RSA key is `$HOME/.ssh/id_rsa_alpine.pub`
- Do not share your private key with anything nor anyone, your private key must never ever leave your laptop


**TODO** add the public key to ~/.ssh/authorized_keys ...


## Adding the RSA key to the server (TODO)

Now Alpine Linux is installed and your SSH keys generated, we need to update a few OpenSSH settings so that the SSH
server allows you to connect using SSH keys. In order to add the new SSH public key, you need to run these commands :
From your computer :

- Identify your public SSH key using PowerShell : `Get-Content -Path $HOME/.ssh/id_rsa_alpine.pub`
  From your server :
- Identify the file that contains the authorized keys : 'grep "AuthorizedKeysFile" /etc/ssh/sshd_config'
- Add your public key to the authorized keys : `echo `

Try to connect to the server to check if the SSH connection is working fine :

## Running a script
`sh start.sh`