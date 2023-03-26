# homelab-alpine-linux

Setting up a whole homelab from scratch with :

- Google domain, GoDaddy or anything else as domain provider
- Cloudflare as HTTP/HTTPS traffic manager and protector against DDOS and a bunch of other attacks
- Alpine Linux as operating system since light and secure
- NGINX as reverse proxy (using alternative like Traefik is also fine, as long as it remains convenient to maintain)
- Docker as services manager (portainer, nextcloud, cicd, wireguard, jellyfin, ...)

## Get a domain

Name and extension don't matter, as long as you have a real domain you own (even the cheapest one is fine).
A domain is required to expose your homelab to the outside world through HTTPS using SSL certificates.
> `homelab.dev`, `homelab.hk.com`, `homelab.io`, `homelab.tech`, ...

Since you own a domain, you will also own all its subdomains that will create later on :
> `portainer.homelab.dev`, `nextcloud.homelab.hk.com`, `cicd.homelab.io`, `jellyfin.homelab.tech`, ...

## Prepare SSH authentication

Using your laptop or desktop (not the server, you got it), open Terminal and then :

- Create a folder that will contain SSH keys (may already exist) : `mkdir $HOME/.ssh`
- Generate your SSH keys (RSA 4096) : `ssh-keygen -t ed25519 -a 256 -f $HOME/.ssh/id_ed25519_nano`

Notice :

- You are encouraged to specify a passphrase so that you protect your private key properly
- Your private key will be `$HOME/.ssh/id_ed25519_nano` and your public key is `$HOME/.ssh/id_ed25519_nano.pub`
- Do not share your private key with anything nor anyone, your private key must never (ever) leave your laptop

No worry, you will add your public key in the SSH server configuration later on. but not now, not yet.

## Rely on Cloudflare

- Create new account
- Add the (Google) domain you own
- Grab the Cloudflare DNS (two DNS addresses)
- Update the DNS in your Google domain using the ones from Cloudflare
- Identify where you can get your Cloudflare token
- Wait for Google (a day or two) to update the DNS so that your domain uses Cloudflare DNS (no choice, you have to wait)

## Installing Alpine Linux

While Google is taking into consideration your new DNS server settings (Google needs a day or two to apply them), you
can start preparing your server.

### Option 1 : using a virtual machine (QEMU)

#### Hardware requirements

My server is a palm-size computer with low hardware
specifications : [GMK NucBox S](https://www.gmktec.com/products/nucbox-most-powerful-palm-sized-4k-mini-pc-1?variant=c932a16c-0219-4b10-ace4-4d8650f33ade)

- CPU Intel J4125
- RAM LPDDR4 8GB dual-channel (soldered)
- SSD mSATA 256GB
- USB to Gigabit+ ethernet adapter `TP-Link UE305`
- MicroSD card slot

#### Prerequisites :

- Download Alpine Linux **standard** edition : https://alpinelinux.org/downloads/
- Prepare a bootable USB stick (or a MicroSD card in my case) using Rufus
- A wired server (Gigabit+ ethernet cable plugged or USB to Gigabit+ ethernet adapter), we won't rely on any WI-FI
  connection for higher bandwidth and lower latency

> 2.5Gbps and 5Gbps ethernet connections are also very welcome! Considering that our server may have an SSD, even mSata
> or 2.5 formats, they can handle over 300 Mo/s read and write operations, which is much higher than a regular
> gigabit connection (usually 105-115 Mo/s at best). 2.5Gbps connections are cheap and not overkill these days.

#### First steps :

- Boot Alpine Linux (bare metal, QEMU, VirtualBox, Proxmox, ... whatever)
- Localhost login : `root`
- Install Alpine Linux : run the command `setup-alpine`
    - Select keyboard layout : `none` (default)
    - Enter system hostname : `localhost` (default)
    - Initialise network interface : `eth0` (default)
    - Private IP address : `dhcp` (default)
    - Add any manual network configuration : `none`
    - No need to initialize any other network interface (since `eth0` is what we wanted): `done`
    - No need to bring any other manual network configuration: `n` (default)
    - New root password : `{must be strong: 12+ chars with figures, lower+upper case and special chars}`
    - Timezone : `?` (so that you can see the list, in my case `Hongkong`
    - HTTP/FTP proxy URL : `none` (default)
    - NTP client : `chrony` (default)
    - Enter mirror : `f` so that it selects the best one wherever your server is
    - Setup a user : `no` (default) since we will do that later when installing docker and docker-compose
    - SSH server : `openssh` (default)
    - Allow root SSH login : `yes` since we will disable it when configuring SSH connection (using non-root account)
    - Disk to use : pick the one from the available disks list in your console (it should be `sda`)
    - How we will the selected disk : `sys`
    - Erase the disk : `y`
- Since the installation is now done :
    - Power off the server: `poweroff`
    - Once off, unplug the USB stick you used to install Alpine Linux
    - Start your server
    - Login using root
    - Install Git : `apk update && apk upgrade && apk add git`
    - Write down the MAC address of your network controller : `ifconfig | grep HWaddr | cut -d" " -f11` (should
      look like `xx:xx:xx:xx:xx:xx`)

## Router settings

- Get into your router settings (usually web interface), as far I'm concerned: `http://192.168.10.1/`
- Add the static DHCP bond based on the MAC address of the server's network controller:
    - Assign IP address: input the private IP address you want the server to always use (as far I'm
      concerned I choose `192.168.10.10`)
    - To MAC address: input the one you got in the previous step, it should look like `xx:xx:xx:xx:xx:xx`
    - Validate the static DHCP bond
- Add a bunch of port forwarding rules (`IP` refers to the private IP you defined above in your static DHCP bond):
    - Rule named `HTTP`:
        - External port `80`
        - Internal port `80`
        - Protocols: `TCP` only
        - IP `192.168.10.10`
    - Rule named `HTTPS`:
        - External port `443`
        - Internal port `443`
        - Protocols: `TCP` only
        - IP `192.168.10.10`
    - Rule named `SSH`:
        - External port `2443`
        - Internal port `22`
        - Protocols: `TCP` only
        - IP `192.168.10.10`
    - Rule named `VPN`:
        - External port `21022`
        - Internal port `51820`
        - Protocols: `UDP` only
        - IP `192.168.10.10`
- Reboot your server so that your router assign the right private IP address : `reboot`

## Now, it's time to play

Alpine Linux has been successfully installed and rebooted.
I also notice that nano is now using the private IP address it's supposed to use (`ifconfig`).

- Create a workspace folder: `mkdir -p $HOME/workspace/ && cd $HOME/workspace/`
- Clone the git repository to configure your server
  properly: `git clone https://github.com/mottieraurelien/nano-alpine-linux.git && cd nano-alpine-linux.git`
- Apply the basic configuration: `alpine/start.sh`
- Connect to the server (from your laptop) using root username/password authentication so that you can add your public
  RSA key before turning off the root username/password authentication:
    - `ssh root@192.168.10.10`
    - Input the root password
    - Add your public RSA key: TODO
    - `exit`
- `sh ssh/start.sh` (will turn off the root username/password authentication)
- `sh docker/start.sh`