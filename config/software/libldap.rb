name 'libldap'
default_version '2.4.40'

source url: "http://ftp.debian.org/debian/pool/main/o/openldap/openldap_#{version}.orig.tar.gz"

version '2.4.40' do
  source md5: '03a8658e62131c0cdbf85dd604e498db'
end

dependency 'openssl'
dependency 'libsasl'

relative_path "openldap_#{version}.orig"

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          ' --disable-slapd' \
          ' --with-tls=openssl' \
          ' --with-cyrus-sasl' \
          " --sysconfdir=#{install_dir}/etc" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers} depend", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  # Remove unused configuration (it is re-created by the installer, we don't want to include it in the package)
  delete "#{install_dir}/etc/openldap"
end
