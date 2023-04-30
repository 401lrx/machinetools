#!/bin/bash
# this script in prefix/tools/systools
# conf file in prefix/config
cd `dirname $0`

# Please do not modify this file, add the specific configuration to the mystartconf.sh file.
[ ! -f ../../config/mystartconf.sh ] && echo "#!/bin/bash" > ../../config/mystartconf.sh
bash ../../config/mystartconf.sh