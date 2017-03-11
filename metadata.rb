name              'conda'
maintainer        'Jim Dowling'
maintainer_email  'jdowling@sics.se'
license           'Apache v.2'
description       'Installs/Configures conda'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '0.1'

supports 'ubuntu', '= 14.04'
supports 'ubuntu', '= 16.04'

supports 'centos', '= 7.2'


#depends 'bzip2'
#depends 'tar'
depends 'kagent'
depends 'hops'
depends 'magic_shell'


attribute "conda/dir",
          :description => "Base installation directory for Conda",
          :type => 'string'

attribute "conda/user",
          :description => "User that runs conda",
          :type => 'string'

attribute "conda/group",
          :description => "Group that runs conda",
          :type => 'string'

attribute "install/dir",
          :description => "Set to a base directory under which we will install.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"