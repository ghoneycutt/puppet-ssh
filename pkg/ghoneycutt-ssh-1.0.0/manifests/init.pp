# Class: ssh
#
# SSH includes both the client and server portions since we will always
# want both. It also includes the sshkey mechanism to distribute our
# public keys in the /etc/ssh/ssh_known_hosts file
#
class ssh {

    package {
        "openssh": ;
        "openssh-clients": ;
        "openssh-server": 
            require => Package["openssh"];
    } # package

    file {
        "/etc/ssh/sshd_config":
            source   => "puppet:///modules/ssh/sshd_config",
            mode     => "600",
            checksum => md5,
            require  => Package["openssh-server"],
            notify   => Service["sshd"];
        "/etc/ssh/ssh_config":
            source   => "puppet:///modules/ssh/ssh_config",
            mode     => "644",
            checksum => md5,
            require  => [ Package["openssh-server"], Package["openssh-clients"] ];
        "/etc/ssh/ssh_known_hosts":
            mode     => "644";
    } # file

    Sshkey { type => ssh-rsa }

    # /etc/ssh/ssh_host_rsa_key.pub from host
    # your key should *NOT* have the ssh-rsa part or it will show up
    # twice and will not work
    sshkey {
        "host1.pop.yourdomain.tld":
            key => "AAAABNa1ycVocshelciawgUkCymKankilcoucnagAreahuld9SadCybluOcEtovUvaphyap1kenebmeeHoofukdytVafnulEyGhickuandeOjubIrkAcCegJinnegMokeeJoFrowlatIvUjej5slyavfoapushgosNufHodsOckDuTajtoagUndedCafJicJenshicMognugoasEgcuvVibdepKoxjoopsInonawoddadIahefhaytshijyethFoonOuk0druwartudfityutGogPoanEmNomWeddaneelpoakE0swiOzcycsAjekbocCeHolOkyaHolIsjuksudwyffest1blopFihatEgNOTAREALKEY==";
    } # sshkey

    service { "sshd":
        ensure  => running,
        enable  => true,
    } # service

    # Definition: ssh::private_key
    #
    # install a private ssh key
    #
    # Parameters:   
    #   $path   - path to where private key should be installed, defaults to /home/$name
    #   $group  - specify group permissions on private key, defaults to $name
    #   $ensure - should the private key file be 'present' or 'absent', defaults to present
    #   $key    - name of file storing private key, defaults to 'id_rsa'
    #   $user   - used in retrieve_priv_key.erb
    #   $owner  - specify owner permissions on private key, defaults to $name
    #
    # Actions:
    #   install a private ssh key
    #
    # Requires:
    #   must specify $user
    #
    # Sample Usage:
    #    # setup private key for post-commit
    #    ssh::private_key { "puppetreposvn":
    #        user    => "puppetreposvn",
    #        require => Generic::Mkuser[puppetreposvn]
    #    } # ssh::private_key
    #
    define private_key($path = false, $group = false, $ensure = present, $key = "id_rsa", $user, $owner = false) { 
        # if the value has been changed, use it, else use default from prototype
        $realPath=$path ? {
            false   => "/home/$name",
            default => $path,
        }

        $realGroup=$group ? {
            false   => $name,
            default => $group,
        }

        $realOwner=$owner ? { 
            false   => $name,
            default => $owner,
        }

        file { "$realPath/.ssh/$key":
            content => template("ssh/retrieve_priv_key.erb"),
            owner   => $realOwner,
            group   => $realGroup,
            mode    => "600",
            ensure  => $ensure,
        } # file
    } # define private_key

    # Definition: ssh::authorized_keys
    #
    # install an authorized key file
    #
    # Parameters:   
    #   $path   - path to where private key should be installed, defaults to /home/$name
    #   $group  - specify group permissions on private key, defaults to $name
    #   $ensure - should the private key file be 'present' or 'absent', defaults to present
    #   $key    - name of file storing private key, defaults to 'id_rsa'
    #   $user   - used in retrieve_priv_key.erb
    #   $owner  - specify owner permissions on private key, defaults to $name
    #
    # Actions:
    #   install an authorized key file
    #
    # Requires:
    #   must specify $user
    #
    # Sample Usage:
    #   # setup authorized key for post-commit
    #   ssh::authorized_keys { "puppetreposvn":
    #       users   => [ "puppetreposvn-puppetrepo" ],
    #       require => Generic::Mkuser[puppetreposvn]
    #   } # ssh::authorized_keys
    #
    define authorized_keys($users, $path = false, $group = false, $ensure = present) { 
        # if the value has been changed, use it, else use default from prototype
        $realPath=$path ? {
            false   => "/home/$name",
            default => $path,
        }

        $realGroup=$group ? {
            false   => $name,
            default => $group,
        }

        file { "$realPath/.ssh/authorized_keys":
            content => template("ssh/gen_auth_keys.erb"),
            owner   => $name,
            group   => $realGroup,
            mode    => "600",
            ensure  => $ensure,
        } # file
    } # define authorized_keys

    # Definition: ssh::public_key
    #
    # install a public key file
    #
    # Parameters:   
    #   $path   - path to where public key should be installed, defaults to /home/$name/.
    #             Under the $path directory '.ssh/id_rsa.pub' will be created 
    #   $group  - specify group permissions on public key, defaults to $name
    #   $ensure - should the public key file be 'present' or 'absent', defaults to present
    #   $owner  - specify owner permissions on public key, defaults to $name
    #
    # Actions:
    #   install a public key file
    #
    # Requires:
    #   file matching $name must exist in modules/ssh/public_keys/
    #
    # Sample Usage:
    #   # install public_key for user foo
    #   ssh::public_key { "foo":
    #       require => Generic::Mkuser[foo],
    #   } # ssh::public_key
    #
    define public_key($path = false, $group = false, $ensure = present, $owner = false) { 
        # if the value has been changed, use it, else use default from prototype
        $realPath=$path ? {
            false   => "/home/$name",
            default => $path,
        } # $realPath

        $realGroup=$group ? {
            false   => $name,
            default => $group,
        } # $realGroup

        $realOwner=$owner ? {
            false   => $name,
            default => $owner,
        } # $realOwner

        file { "$realPath/.ssh/id_rsa.pub":
            source => "puppet:///modules/ssh/public_keys/$name",
            owner  => $readOwner,
            group  => $realGroup,
            mode   => "600",
            ensure => $ensure,
        } # file
    } # define public_key
} # class ssh
