#!/bin/bash

cd `dirname $0`

echo '#!/bin/bash

cd `dirname $0`

python /work/scripts/sendmail.py "$@"
' > /usr/sbin/mysendmail
