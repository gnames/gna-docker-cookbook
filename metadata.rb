name             'gna-docker'
maintainer       'Dmitry Mozzherin'
maintainer_email 'dmozzherin@gmail.com'
license          'MIT'
description      'Installs/Configures gna-docker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.9'

depends "apt", "~>2.6"
depends "yum-epel", "~>0.6"
