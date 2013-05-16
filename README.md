# **DEPRECATED** #

## Please use [https://github.com/ghoneycutt/puppet-module-ssh](https://github.com/ghoneycutt/puppet-module-ssh)

<br/>

===

ssh

Manages SSH and provides functionality to install public/private keys and authorized_keys files.

## Definition: ssh::authorized_keys ##

install an authorized key file

### Parameters:
* $path   - path to where private key should be installed, defaults to /home/$name
* $group  - specify group permissions on private key, defaults to $name
* $ensure - should the private key file be 'present' or 'absent', defaults to present
* $key    - name of file storing private key, defaults to 'id_rsa'
* $user   - used in retrieve_priv_key.erb
* $owner  - specify owner permissions on private key, defaults to$name

### Actions:
  install an authorized key file

### Requires:
  must specify $user

### Sample Usage:
<pre>
  # setup authorized key for post-commit
  ssh::authorized_keys { "puppetreposvn":
      users   => [ "puppetreposvn-puppetrepo" ],
      require => Generic::Mkuser[puppetreposvn]
  } # ssh::authorized_keys
</pre>

===

## Definition: ssh::public_key

install a public key file

### Parameters:
* $path   - path to where public key should be installed, defaults to /home/$name/.
            Under the $path directory '.ssh/id_rsa.pub' will be created
* $group  - specify group permissions on public key, defaults to $name
* $ensure - should the public key file be 'present' or 'absent', defaults to present
* $owner  - specify owner permissions on public key, defaults to $name

### Actions:
  install a public key file

### Requires:
  file matching $name must exist in modules/ssh/public_keys/

### Sample Usage:
<pre>
  # install public_key for user foo
  ssh::public_key { "foo":
      require => Generic::Mkuser[foo],
  } # ssh::public_key
</pre>

===

## Definition: ssh::private_key

install a private ssh key

### Parameters:
* $path   - path to where private key should be installed, defaults to /home/$name
* $group  - specify group permissions on private key, defaults to $name
* $ensure - should the private key file be 'present' or 'absent', defaults to present
* $key    - name of file storing private key, defaults to 'id_rsa'
* $user   - used in retrieve_priv_key.erb
* $owner  - specify owner permissions on private key, defaults to $name

### Actions:
  install a private ssh key

### Requires:
  must specify $user

### Sample Usage:
<pre>
   # setup private key for post-commit
   ssh::private_key { "puppetreposvn":
       user    => "puppetreposvn",
       require => Generic::Mkuser[puppetreposvn]
   } # ssh::private_key
</pre>