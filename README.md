# Hass.io frp client

A fast reverse proxy client for Hass.io to help you expose a home assistant or any other local service behind a NAT or firewall to the internet.

Read more about the project: https://github.com/fatedier/frp


# How to use?

1. Add a frpc.int configuration file to /share/frp directory
2. Run frps on remote server with public ip
3. Start Hass.io addon

# Example for home assistant

I don't use frp server directly to expose home assistant to the net, but have a nginx before it so a have next config

### nginx config

```
upstream frps {
    server 0.0.0.0:8080;
}

server {
    listen 443 ssl;
    server_name <SERVER_NAME>;

    location / {
        proxy_pass http://frps;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host frps123home.hidden; #$host;
        proxy_cache_bypass $http_upgrade;
        proxy_http_version 1.1;
    }

}

```

### frp server config (frps.ini)

```
[common]
bind_addr = 0.0.0.0
bind_port = 7000

# port should be the same as an upsteam in nginx config
vhost_http_port = 8080
vhost_https_port = 8081

# dashboard used by a client
dashboard_addr = 0.0.0.0
dashboard_port = 7500

# makes sense to protect admin panel with a password since it is exposed to the net
dashboard_user = admin
dashboard_pwd = admin

# for authentication
token = sometoken
```

### frp client config for hass.io addon in /share/frp/frpc.ini

```
# [common] is integral section
[common]
server_addr = <server's ip address>
server_port = 7000

# console or real logFile path like ./frpc.log
log_file = /share/frp/frpc.log

# for authentication
token = sometoken

# set admin address for control frpc's action by http api such as reload
admin_addr = 194.146.38.134
admin_port = 7500
admin_user = admin
admin_pwd = admin

heartbeat_interval = 30
heartbeat_timeout = 90

[homeassistant]
type = http
# home assistant port, usually 812
local_port = 8123
# custom domain, used locally, should much the domain from nginx config
custom_domains = frps123home.hidden

```