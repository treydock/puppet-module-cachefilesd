require 'spec_helper'

describe 'cachefilesd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_package('cachefilesd').with(
          ensure: 'installed',
          name: 'cachefilesd',
        )
      end

      it { is_expected.to contain_package('cachefilesd').that_comes_before('File[/var/cache/fscache]') }
      it { is_expected.to contain_package('cachefilesd').that_comes_before('File[cachefilesd.conf]') }
      it { is_expected.to contain_package('cachefilesd').that_notifies('Service[cachefilesd]') }

      it do
        is_expected.to contain_file('/var/cache/fscache').with(
          ensure: 'directory',
          owner: 'root',
          group: 'root',
          mode: '0755',
          seluser: 'system_u',
          selrole: 'object_r',
          seltype: 'cachefiles_var_t',
          selrange: 's0',
        )
      end

      it { is_expected.to contain_file('/var/cache/fscache').that_notifies('Service[cachefilesd]') }

      it do
        is_expected.to contain_file('cachefilesd.conf').with(
          ensure: 'file',
          path: '/etc/cachefilesd.conf',
          owner: 'root',
          group: 'root',
          mode: '0644',
        )
      end

      it { is_expected.to contain_file('cachefilesd.conf').that_notifies('Service[cachefilesd]') }

      it 'has valid cachefilesd.conf' do
        expected = [
          'dir /var/cache/fscache',
          'tag CacheFiles',
          'brun 10%',
          'bcull 7%',
          'bstop 3%',
          'frun 10%',
          'fcull 7%',
          'fstop 3%',
          'secctx system_u:object_r:cachefiles_var_t:s0',
          'culltable 12',
        ]
        verify_contents(catalogue, 'cachefilesd.conf', expected)
      end

      it do
        is_expected.to contain_service('cachefilesd').with(
          ensure: 'running',
          enable: 'true',
          name: 'cachefilesd',
        )
      end

      context 'service_enable => UNSET' do
        let(:params) { { service_enable: 'UNSET' } }

        it { is_expected.to contain_service('cachefilesd').without_enable }
      end
    end
  end
end
