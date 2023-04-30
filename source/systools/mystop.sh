#!/bin/bash
# this script in prefix/tools/systools
# conf file in prefix/config
cd `dirname $0`

# Please do not modify this file, add the specific configuration to the mystopconf.sh file.
[ ! -f ../../config/mystopconf.sh ] && echo "#!/bin/bash" > ../../config/mystopconf.sh
bash ../../config/mystopconf.sh
