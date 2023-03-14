#!/bin/bash
cd `dirname $0`

# limit root remote login
sed -i "s/^#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
sed -i "s/^PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
