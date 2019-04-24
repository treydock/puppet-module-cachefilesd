# puppet-module-cachefilesd

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/cachefilesd.svg)](https://forge.puppetlabs.com/treydock/cachefilesd)
[![Build Status](https://travis-ci.org/treydock/puppet-module-cachefilesd.png)](https://travis-ci.org/treydock/puppet-module-cachefilesd)

#### Table of Contents

1. [Description](#description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Manage resources for cachefilesd.

## Usage

To manage cachefilesd

```puppet
include ::cachefilesd
```

## Reference

[http://treydock.github.io/puppet-module-cachefilesd/](http://treydock.github.io/puppet-module-cachefilesd/)

## Limitations

Only tested on RHEL 6 and RHEL 7.

## Development

This module uses PDK for testing.

## Release Process

1. Update metadata.json version
1. Generate REFERENCE.md: `bundle exec rake strings:generate:reference`
1. Update CHANGELOG.md: `bundle exec rake changelog`
1. Commit changes, eg `git commit -a -m "Release 0.1.0"`
1. Tag, eg: `git tag 0.1.0`
1. Update GitHub pages: `bundle exec rake strings:gh_pages:update`
