# @summary
#	  Manage SSL certs for NGINX on PE using letsencrypt
#
# @param nginx_conf_dir Stdlib::Absolutepath
#   The directory containing the nginx config for the console
#
# @param letsencrypt_conf_dir Stdlib::Absolutepath
#   The directory containing the letsencrypt config
#
# @param docroot Stdlib::Absolutepath
#   The directory we should use as the docroot
#
# @param mode Stdlib::Filemode
#   Octal value for the file permissions
#
# @param email Stdlib::Email
#   Email address to use when requesting the certificates
#
# @param port Stdlib::Port
#   Port to use for the nginx server
#
# @param owner String
#   User running the puppet console services
#
# @param group String
#   Group running the puppet console services
#
# @param manage_letsencrypt Boolean
#   Should we manage the letsencrypt install?
#
# @param cert_dir Stdlib::Absolutepath
#   Where are the PE console certs?
#
# @example Basic usage
#   include pe_console_letsencrypt
#
class pe_console_letsencrypt (
  Stdlib::Absolutepath $cert_dir = '/etc/puppetlabs/puppet/ssl',
  Stdlib::Absolutepath $nginx_conf_dir = '/etc/puppetlabs/nginx/conf.d',
  Stdlib::Absolutepath $letsencrypt_conf_dir = '/etc/letsencrypt',
  Stdlib::Absolutepath $docroot = '/var/www',
  Stdlib::Filemode $mode = '0640',
  Stdlib::Email $email = "puppet@${facts['puppet_server']}",
  Stdlib::Port $port = 80,
  Boolean $manage_letsencrypt = true,
  String $owner = 'pe-puppet',
  String $group = 'pe-puppet',
) {
  # Lookup the default redirect value
  $default_redirect_enabled = lookup('puppet_enterprise::profile::console::proxy::http_redirect::enable_http_redirect',Boolean,first,true)
  $hiera_cert = lookup('puppet_enterprise::profile::console::browser_ssl_cert',Varient[String,Boolean],first,false)
  $hiera_key = lookup('puppet_enterprise::profile::console::browser_ssl_private_key',Varient[String,Boolean],first,false)

  # Ensure that the default redirect has been disabled before we begin
  # If it hasn't, we have to fail as it'll end up in a change loop
  #
  # This can be set in hiera or in the console
  if $default_redirect_enabled == true {
    fail('Could not enable pe_console_letsencrypt, 
      puppet_enterprise::profile::console::proxy::http_redirect::enable_http_redirect is set to true'
    )
  }

  if $hiera_cert or $hiera_key {
    fail('Existing entires exist for the browser ssl ert and private key')
  }

  if $manage_letsencrypt {
    # Setup the letsencrypt class using the email parameter
    class { 'letsencrypt':
      config     => {
        email  => $email,
      },
      config_dir => $letsencrypt_conf_dir,
      require    => File["${nginx_conf_dir}/certs.conf"],
    }
  }

  unless defined(File[$docroot]) {
    file { '/var/www':
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '0755',
    }
  }

  # Generate the certs for the puppet server
  letsencrypt::certonly { $facts['puppet_server']:
    domains       => [$facts['puppet_server']],
    manage_cron   => true,
    plugin        => 'webroot',
    webroot_paths => [$docroot],
    require       => File[$docroot],
  }

  # A custom nginx vhost to do the redirection and host the letsencrypt challange response
  file { "${nginx_conf_dir}/certs.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/cert_vhost.conf.erb"),
    notify  => Exec['restart_nginx'],
  }

  # This is a **TINY** bit hacky, but it means we can get a new cert live in a single puppet run
  exec { 'restart_nginx':
    command     => '/bin/systemctl restart pe-nginx',
    refreshonly => true,
  }

  # The console cert
  file { "${cert_dir}/certs/console-cert.pem":
    ensure    => file,
    owner     => $owner,
    group     => $group,
    links     => 'follow',
    mode      => $mode,
    source    => "${letsencrypt_conf_dir}/live/${facts['puppet_server']}/cert.pem",
    backup    => '.puppet_bak',
    notify    => Service['pe-nginx'],
    require   => Exec['restart_nginx'],
    subscribe => Letsencrypt::Certonly[$facts['puppet_server']],
  }

  # The console key
  file { "${cert_dir}/private_keys/console-cert.pem":
    ensure    => file,
    owner     => $owner,
    group     => $group,
    links     => 'follow',
    mode      => $mode,
    source    => "${letsencrypt_conf_dir}/live/${facts['puppet_server']}/privkey.pem",
    backup    => '.puppet_bak',
    notify    => Service['pe-nginx'],
    require   => Exec['restart_nginx'],
    subscribe => Letsencrypt::Certonly[$facts['puppet_server']],
  }
}
