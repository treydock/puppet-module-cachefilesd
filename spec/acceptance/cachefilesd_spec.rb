require 'spec_helper_acceptance'

describe 'cachefilesd class:' do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'cachefilesd':
        # Docker can not run cachefilesd
        service_ensure => 'stopped',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
