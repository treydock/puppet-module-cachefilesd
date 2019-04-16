# Manage cachefilesd
#
# @summary Manage cachefilesd
#
# @example
#   include cachefilesd
#
# @param manage_package
#   Boolean that determines if package resource is managed.
# @param package_name
#   Package name for cachefilesd
# @param package_ensure
#   Package ensure property
# @param manage_config
#   Boolean that determines if config is managed.
# @param config_path
#   Path to cachefilesd.conf
# @param manage_dir
#   Booleans that determines if `dir` resource is managed.
# @param dir
#   cachefilesd `dir` config option
# @param cache_tag
#   cachefilesd `tag` config option
# @param brun
#   cachefilesd `brun` config option
# @param bcull
#   cachefilesd `bcull` config option
# @param bstop
#   cachefilesd `bstop` config option
# @param frun
#   cachefilesd `frun` config option
# @param fcull
#   cachefilesd `fcull` config option
# @param fstop
#   cachefilesd `fstop` config option
# @param secctx
#   cachefilesd `secctx` config option
# @param culltable
#   cachefilesd `culltable` config option
# @param nocull
#   cachefilesd `nocull` config option
# @param resume_thresholds
#   cachefilesd `resume_thresholds` config option
# @param manage_service
#   Boolean that determines if cachefilesd service is managed.
# @param service_name
#   cachefilesd service name
# @param service_ensure
#   cachefilesd service ensure property
# @param service_enable
#   cachefilesd service enable property
class cachefilesd (
  Boolean $manage_package = true,
  String[1] $package_name = 'cachefilesd',
  String[1] $package_ensure = 'installed',
  Boolean $manage_config = true,
  Stdlib::Absolutepath $config_path = '/etc/cachefilesd.conf',
  Boolean $manage_dir = true,
  Stdlib::Absolutepath $dir = '/var/cache/fscache',
  Variant[String[1], Boolean] $cache_tag = 'CacheFiles',
  Integer[0,99] $brun = 10,
  Integer[0,99] $bcull = 7,
  Integer[0,99] $bstop = 3,
  Integer[0,99] $frun = 10,
  Integer[0,99] $fcull = 7,
  Integer[0,99] $fstop = 3,
  String[1] $secctx = 'system_u:system_r:cachefiles_kernel_t:s0',
  Integer[12,20] $culltable = 12,
  Boolean $nocull = false,
  Optional[String[1]] $resume_thresholds = undef,
  Boolean $manage_service = true,
  String[1] $service_name = 'cachefilesd',
  String[1] $service_ensure = 'running',
  Boolean $service_enable = true,
) {

  if ! ($bstop < $bcull and $bcull < $brun ) {
    fail("${module_name}: Requires bstop < bcull < brun")
  }

  if ! ($fstop < $fcull and $fcull < $frun ) {
    fail("${module_name}: Requires fstop < fcull < frun")
  }

  if $manage_package {
    package { 'cachefilesd':
      ensure => $package_ensure,
      name   => $package_name,
    }
    if $manage_dir {
      Package['cachefilesd'] -> File[$dir]
    }
    if $manage_config {
      Package['cachefilesd'] -> File['cachefilesd.conf']
    }
    if $manage_service {
      Package['cachefilesd'] ~> Service['cachefilesd']
    }
  }

  if $manage_dir {
    file { $dir:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    if $manage_service {
      File[$dir] ~> Service['cachefilesd']
    }
  }

  if $manage_config {
    file { 'cachefilesd.conf':
      ensure  => 'file',
      path    => $config_path,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('cachefilesd/cachefilesd.conf.erb'),
      require => Package['cachefilesd'],
      notify  => Service['cachefilesd'],
    }
    if $manage_service {
      File['cachefilesd.conf'] ~> Service['cachefilesd']
    }
  }

  if $manage_service {
    service { 'cachefilesd':
      ensure => $service_ensure,
      enable => $service_enable,
      name   => $service_name,
    }
  }

}
