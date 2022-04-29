# Manage cachefilesd
#
# @summary Manage cachefilesd
#
# @example
#   include cachefilesd
#
# @param manage_repo
#   Boolean that determines if managing package repo.
#   Only used by Debian 10 at this time
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
# @param filesecctx
#   SELinux security context for the `dir` resource
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
  Boolean $manage_repo = true,
  Boolean $manage_package = true,
  String[1] $package_name = 'cachefilesd',
  String[1] $package_ensure = 'installed',
  Boolean $manage_config = true,
  Stdlib::Absolutepath $config_path = '/etc/cachefilesd.conf',
  Boolean $manage_dir = true,
  String[1] $filesecctx = 'system_u:object_r:cachefiles_var_t:s0',
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
  Variant[Boolean, Enum['UNSET']] $service_enable = true,
) {

  if ! ($bstop < $bcull and $bcull < $brun ) {
    fail("${module_name}: Requires bstop < bcull < brun")
  }

  if ! ($fstop < $fcull and $fcull < $frun ) {
    fail("${module_name}: Requires fstop < fcull < frun")
  }

  if $service_ensure == 'UNSET' {
    $_service_ensure = undef
  } else {
    $_service_ensure = $service_ensure
  }

  if $service_enable == 'UNSET' {
    $_service_enable = undef
  } else {
    $_service_enable = $service_enable
  }

  if $manage_repo and $facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '10') == 0 {
    include apt::backports
    if $manage_package {
      Class['apt::backports'] -> Package['cachefilesd']
    }
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

  if $facts['os']['family'] == 'Debian' {
    file_line { 'cachefilesd-RUN':
      ensure => 'present',
      path   => '/etc/default/cachefilesd',
      line   => 'RUN=yes',
      match  => '^RUN=',
      after  => '^#RUN=.*',
    }

    if $manage_package {
      Package['cachefilesd'] -> File_line['cachefilesd-RUN']
    }
    if $manage_service {
      File_line['cachefilesd-RUN'] ~> Service['cachefilesd']
    }
  }

  if $manage_dir {
    $selentries = split($filesecctx, ':')
    $seluser = $selentries[0]
    $selrole = $selentries[1]
    $seltype = $selentries[2]
    $selrange = $selentries[3]

    file { $dir:
      ensure   => 'directory',
      owner    => 'root',
      group    => 'root',
      mode     => '0755',
      seluser  => $seluser,
      selrole  => $selrole,
      seltype  => $seltype,
      selrange => $selrange,
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
    }
    if $manage_service {
      File['cachefilesd.conf'] ~> Service['cachefilesd']
    }
  }

  if $manage_service {
    service { 'cachefilesd':
      ensure => $_service_ensure,
      enable => $_service_enable,
      name   => $service_name,
    }
  }

}
