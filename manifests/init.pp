# == Class: profile_dockerhost
#
# Full description of class profile_dockerhost here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { profile_dockerhost:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class docker (

  $version = 'latest',
  $fw_port = '2375',

) {
 
 notify {"Installing version $version":}

 package { 'docker':
	ensure => $version,
 }

 file { '/etc/sysconfig/docker': 
	ensure  => file,
	require => Package['docker'],
	content => template('docker/docker.erb'),
	owner	=> 'root',
	group	=> 'root',
	mode 	=> '640',
	notify 	=> Service['docker'],
 }

 file { '/etc/sysconfig/docker-network': 
	ensure  => file,
	require => Package['docker'],
	content => template('docker/docker-network.erb'),
	owner	=> 'root',
	group	=> 'root',
	mode 	=> '640',
	notify 	=> Service['docker'],
 }

 service { 'docker':
	ensure	=> running,
	enable	=> true,
	hasrestart => true,
	hasstatus  => true,
	require	   => Package['docker'],
 }

 service { 'firewalld':
        ensure  => running,
        enable  => true,
        hasrestart => true,
        hasstatus  => true,
 }

 exec { "configure_firewalld":
        path     => "/usr/bin:/usr/sbin:/bin",
        onlyif   => "firewall-cmd --list-ports | grep -qv $fw_port",
        command  => "firewall-cmd --add-port=\"${fw_port}/tcp\" --permanent",
        require  => File['/etc/sysconfig/docker-network'],
        notify   => [
                     Service['docker'],
                     Service['firewalld'],
                    ]
 }

}
