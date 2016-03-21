Ansible module used by OSAS to manage Apache httpd.

[![Build Status](https://travis-ci.org/OSAS/ansible-role-httpd.svg?branch=master)](https://travis-ci.org/OSAS/ansible-role-httpd)

# Adding a Vhost

The role is quite flexible and support all kind of setup. Since it serve as the basis for others roles
who may be different, the default setting do almost nothing, and in turn require almost nothing.

The domain used for the vhost come from `website_domain`. If not given, it will take `ansible_fqdn` by default.

One of the most basic usage is serving static web pages. For that, the variable `document_root` will need to
be set. If none is provided, no document root will be set.

# TLS support

This role can be used to setup and enable TLS support in differents ways, using
either letsencrypt, freeipa or a direct ssl certificate drop. The configuration
by default will set HSTS, and use the set of cipher from https://wiki.mozilla.org/Security/Server_Side_TLS
SSL v3 and V2 are disabled

A option to force the TLS version of the website exist, just set `force_tls: True` to enable it.

## Letsencrypt

To enable the letsencypt support, just set `use_letsencrypt: True` with your role.
It will take care of installing needed packages, and set the config for the HTTP challenge.

## FreeIPA / dogtag

[FreeIPA](http://freeipa.org) come with [DogTag](http://pki.fedoraproject.org/wiki/PKI_Main_Page),
a certificate management system. You can request certificates signed by the internal CA and have them
renewed automatically using the variable `use_freeipa`. This is mostly used for internal services.

## Self managed certificates

For people who prefer to use certificates signed manually by a CA, the option `use_ssl` permit to
enable SSL/TLS without managing the certificate. The key should be placed on /etc/pki/tls/private/$DOMAIN.key
the certificate in /etc/pki/tls/certs/$DOMAIN.crt and the CA certificate in /etc/pki/tls/certs/$DOMAIN.ca.crt.

# Others settings
## ModSecurity

A administrator can decide to enable ModSecurity by setting `use_mod_sec: True`. This will enable a regular
non tweaked ModSecurity install, with full protection. In order to test that it break nothing, the module can be
turned in detection mode only with `mod_sec_detection_only: True`.

## Tor Hidden service

The role can enable a tor hidden service for http and https with the option `use_hidden_service: True`. It will
automatically enable the hidden service and add the .onion alias to the httpd configuration. No specific
hardening for anonymisation purpose is done, the goal is mostly to enable regular website to be served over
tor to let the choice to people.

## Log retention period

Logs are rotated on a regular basis, and kept for some amount on time on the server. The default is 8 weeks, but it
can be tweaked with the `log_retention_week` variable

## Redirection

If the variable `redirect` is set, the vhost will redirect to the new domain name. This is mostly done for
supporting compatibility domain after moving a project, or to support multiple domain name.

## Password protection

In order to deploy website before launch, we traditionnaly protect them with a simple user/password
using a .htpasswd file. The 2 variables `website_user` and `website_password` can be set and will automatically
set the password protection.

Removing the password protection requires to remove the 2 variables and remove the /etc/httpd/$DOMAIN.htpasswd
file created.

# Extend the role

In order to compose more complex roles by combining (and using depends), the installed configuration also
support to include part of the configuration.

Due to the way ansible work, variable set on the first role will be inherited by the httpd role if set on the role
level. Thus, this permit to keep the same variable name, like this:

```
$ cat roles/piwik/meta/main.yml
---
dependencies:
- { role: mysql }
- { role: httpd, document_root: /var/www/piwik/, use_freeipa: True }

$ cat deploy_piwik.yml
- hosts: piwik
  roles:
  - role: piwik
    website_domain: piwik.example.org
```

However, some variable name are a bit generic (like use_tls), so beware of this as it can produes weird side effects.

In order to let a role extend the httpd configuration, a role can drop files ending in .conf in /etc/httpd/conf.d/$DOMAIN.conf.d/.
The file will be included for TLS and non TLS vhost for now, which might cause some issues. This is planned to be fixed later
to be able to support WSGI cleanly.
