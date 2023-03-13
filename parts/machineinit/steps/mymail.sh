#!/bin/bash
cd `dirname $0`

echo '#!/bin/bash
cd `dirname $0`

[ -x "$(command -v python)" ] && { python /work/scripts/sendmail.py "$@"; exit; }
[ -x "$(command -v python3)" ] && { python /work/scripts/sendmail.py "$@"; exit; }
' > /usr/sbin/mysendmail

chmod 755 /usr/sbin/mysendmail
