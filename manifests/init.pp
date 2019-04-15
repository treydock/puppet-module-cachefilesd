# Manage cachefilesd
#
# @summary Manage cachefilesd
#
# @example
#   include cachefilesd
class cachefilesd (
  String[1] $package_name = 'cachefilesd',
  String[1] $package_ensure = 'installed',
  Stdlib::Absolutepath $dir = '/var/cache/fscache',
  Variant[String[1], Boolean] $cache_tag = 'CacheFiles',
  Integer[0,100] $brun = 10,
  Integer[0,100] $bcull = 7,
  Integer[0,100] $bstop = 3,
  Integer[0,100] $frun = 10,
  Integer[0,100] $fcull = 7,
  Integer[0,100] $fstop = 3,
  String[1] $secctx = 'system_u:system_r:cachefiles_kernel_t:s0',
  Integer[12,20] $culltable = 12,
  Boolean $nocull = false,
  Optional[String[1]] $resume_thresholds = undef,
  String[1] $service_name = 'cachefilesd',
  String[1] $service_ensure = 'running',
  Boolean $service_enable = true,
) {

  package { 'cachefilesd':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { '/etc/cachefilesd.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('cachefilesd/cachefilesd.conf.erb'),
    require => Package['cachefilesd'],
    notify  => Service['cachefilesd'],
  }

  service { 'cachefilesd':
    ensure  => $service_ensure,
    enable  => $service_enable,
    name    => $service_name,
    require => Package['cachefilesd'],
  }

}
