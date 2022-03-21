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

    describe package('cachefilesd') do
      it { is_expected.to be_installed }
    end

    describe file('/var/cache/fscache') do
      it { is_expected.to be_directory }
    end

    describe file('/etc/cachefilesd.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{dir /var/cache/fscache} }
    end

    describe file('/etc/default/cachefilesd'), if: fact('os.family') == 'Debian' do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{RUN=yes} }
    end

    describe service('cachefilesd') do
      it { is_expected.to be_enabled }
      it { is_expected.not_to be_running }
    end
  end
end
