#!/bin/bash
# TODO detect that the certificate got changed and restart apache 
letsencrypt-renewer --config-dir /etc/letsencrypt/
