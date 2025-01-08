# Stolen from https://stackoverflow.com/a/30650831/4935114

import os
import sys

if 'VIRTUAL_ENV' in os.environ:
    py_version = sys.version_info[:2] # formatted as X.Y
    py_infix = os.path.join('lib', ('python%d.%d' % py_version))
    virtual_site = os.path.join(os.environ.get('VIRTUAL_ENV'), py_infix, 'site-packages')
    dist_site = os.path.join('/usr', py_infix, 'dist-packages')

    # OPTIONAL: exclude debian-based system distributions sites
    sys.path = filter(lambda p: not p.startswith(dist_site), sys.path)

    # add virtualenv site
    sys.path.insert(0, virtual_site)
