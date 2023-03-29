# frozen_string_literal: true

require 'spec_helper'

describe 'pe_console_letsencrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
      let(:cert_dir) { '/etc/puppetlabs/puppet/ssl' }
      let(:nginx_dir) { '/etc/puppetlabs/nginx/conf.d' }
      let(:web_dir) { '/var/www' }

      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('pe_console_letsencrypt') }
      it { is_expected.to contain_letsencrypt__certonly(os_facts['puppet_server']).with({
        'domains'       => [os_facts['puppet_server']],
        'manage_cron'   => true,
        'webroot_paths' => [web_dir],
      })}

      it { is_expected.to contain_file("#{nginx_dir}/certs.conf").with({
        'ensure' => 'file',
      })}
      it { is_expected.to contain_file("#{cert_dir}/certs/console-cert.pem").with({
        'ensure' => 'file',
      })}
      it { is_expected.to contain_file("#{cert_dir}/private_keys/console-cert.pem").with({
        'ensure' => 'file',
      })}
      it { is_expected.to contain_exec("restart_nginx").with({
        'refreshonly' => true,
      })}

    end
  end
end
