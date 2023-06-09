# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`pe_console_letsencrypt`](#pe_console_letsencrypt): Manage SSL certs for NGINX on PE using letsencrypt

## Classes

### <a name="pe_console_letsencrypt"></a>`pe_console_letsencrypt`

Manage SSL certs for NGINX on PE using letsencrypt

#### Examples

##### Basic usage

```puppet
include pe_console_letsencrypt
```

#### Parameters

The following parameters are available in the `pe_console_letsencrypt` class:

* [`nginx_conf_dir`](#nginx_conf_dir)
* [`letsencrypt_conf_dir`](#letsencrypt_conf_dir)
* [`docroot`](#docroot)
* [`mode`](#mode)
* [`email`](#email)
* [`port`](#port)
* [`owner`](#owner)
* [`group`](#group)
* [`manage_letsencrypt`](#manage_letsencrypt)
* [`cert_dir`](#cert_dir)

##### <a name="nginx_conf_dir"></a>`nginx_conf_dir`

Data type: `Stdlib::Absolutepath`

Stdlib::Absolutepath
The directory containing the nginx config for the console

Default value: `'/etc/puppetlabs/nginx/conf.d'`

##### <a name="letsencrypt_conf_dir"></a>`letsencrypt_conf_dir`

Data type: `Stdlib::Absolutepath`

Stdlib::Absolutepath
The directory containing the letsencrypt config

Default value: `'/etc/letsencrypt'`

##### <a name="docroot"></a>`docroot`

Data type: `Stdlib::Absolutepath`

Stdlib::Absolutepath
The directory we should use as the docroot

Default value: `'/var/www'`

##### <a name="mode"></a>`mode`

Data type: `Stdlib::Filemode`

Stdlib::Filemode
Octal value for the file permissions

Default value: `'0640'`

##### <a name="email"></a>`email`

Data type: `Stdlib::Email`

Stdlib::Email
Email address to use when requesting the certificates

Default value: `"puppet@${facts['puppet_server']}"`

##### <a name="port"></a>`port`

Data type: `Stdlib::Port`

Stdlib::Port
Port to use for the nginx server

Default value: `80`

##### <a name="owner"></a>`owner`

Data type: `String`

String
User running the puppet console services

Default value: `'pe-puppet'`

##### <a name="group"></a>`group`

Data type: `String`

String
Group running the puppet console services

Default value: `'pe-puppet'`

##### <a name="manage_letsencrypt"></a>`manage_letsencrypt`

Data type: `Boolean`

Boolean
Should we manage the letsencrypt install?

Default value: ``true``

##### <a name="cert_dir"></a>`cert_dir`

Data type: `Stdlib::Absolutepath`

Stdlib::Absolutepath
Where are the PE console certs?

Default value: `'/etc/puppetlabs/puppet/ssl'`

