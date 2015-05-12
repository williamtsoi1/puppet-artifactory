# Setting up reverse proxy as mentioned under
class artifactory::nginx(
  $certdir = '/etc/nginx/ssl',
  $key = "artifactory.ozforex.local.key",
  $crt = "artifactory.ozforex.local.crt"
) {

  file{$certdir:
    ensure => directory,
  }

  file { '$certdir/$key':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/artifactory/$key',
    owner   => root,
    group   => root,
    require => File[$certdir]
  } ~> Service['nginx']

  file { '$certdir/$crt':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/artifactory/$crt',
    owner   => root,
    group   => root,
    require => File[$certdir]
  } ~> Service['nginx']

  package{'nginx':
    ensure  => present
  } ->

  file { '/etc/nginx/sites-enabled/artifactory.conf':
    ensure  => file,
    mode    => '0644',
    content => template('artifactory/artifactory.conf.erb'),
    owner   => root,
    group   => root,
  } ->

  service{'nginx':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  file{'/etc/nginx/sites-enabled/default':
    ensure => absent
  } ~> Service['nginx']

  include ufw

  ufw::allow { 'allow-ssh-from-all':
      port => 22,
  }

  ufw::allow { 'allow-80':
    from => 'any',
    port => 80,
    ip   => 'any'
  }

  ufw::allow { 'allow-https-from-all':
    from  => 'any',
    port  => 443,
    ip    => 'any'
  }
}
