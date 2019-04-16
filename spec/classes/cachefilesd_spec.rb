require 'spec_helper'

describe 'cachefilesd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

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
          'secctx system_u:system_r:cachefiles_kernel_t:s0',
          'culltable 12',
        ]
        verify_contents(catalogue, 'cachefilesd.conf', expected)
      end
    end
  end
end
