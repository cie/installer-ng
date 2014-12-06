# Scalr attributes
default[:scalr][:id] ='unset'

# Users
default[:scalr][:core][:group] = 'scalr'
default[:scalr][:core][:users][:service] = 'root'
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'fedora' => 'apache', 'debian' => 'www-data')

#TODO -> Move to :deployment
default[:scalr][:package][:name] = 'scalr'
default[:scalr][:package][:revision] = 'HEAD'
default[:scalr][:package][:repo] = 'https://github.com/Scalr/scalr.git'
default[:scalr][:package][:deploy_to] = '/opt/scalr'

default[:scalr][:package][:version] = '4.5.0'
default[:scalr][:package][:version_obj] = Gem::Version.new(node.scalr.package.version)

# Only used if deploying from a private repo
default[:scalr][:deployment][:ssh_key_path] = ''
default[:scalr][:deployment][:ssh_key] = ''
default[:scalr][:deployment][:ssh_wrapper_path] = '/tmp/chef_ssh_deploy_wrapper'

# Useful locations for Scalr
default[:scalr][:core][:location] = File.join(node.scalr.package.deploy_to, 'current')
default[:scalr][:core][:configuration] = "#{node.scalr.core.location}/app/etc/config.yml"
default[:scalr][:core][:cryptokey_path] = "#{node[:scalr][:core][:location]}/app/etc/.cryptokey"
default[:scalr][:core][:id_path] = "#{node[:scalr][:core][:location]}/app/etc/id"

default[:scalr][:python][:venv] = "#{node.scalr.package.deploy_to}/venv"
default[:scalr][:python][:venv_python] = "#{node.scalr.python.venv}/bin/python"
default[:scalr][:python][:venv_pip] = "#{node.scalr.python.venv}/bin/pip"

default[:scalr][:python][:venv_force_install] = [['httplib2', nil], ['pymysql', nil], ['cherrypy', '3.2.6'], ['pytz', nil]]

# Here, it is crucial NOT to use ENV["PATH"], as this would include the Chef PATH, which ships its own pkg-config,
# and will result in package builds failing in the virtual environment (because despite Chef having pkg-config, it will
# not find our packages).
default[:scalr][:python][:venv_build_path] = "#{node.scalr.python.venv}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Misc dirs
default[:scalr][:core][:log_dir] = '/var/log/scalr'
default[:scalr][:core][:pid_dir] = '/var/run/scalr'

# User settings
default[:scalr][:admin][:username] = 'admin'
default[:scalr][:admin][:password] = 'scalr'

# Database settings
default[:scalr][:database][:username] = 'scalr'
default[:scalr][:database][:password] = 'scalr'
default[:scalr][:database][:host] = 'localhost'
default[:scalr][:database][:port] = 3306
default[:scalr][:database][:scalr_dbname] = 'scalr'
default[:scalr][:database][:analytics_dbname] = 'analytics'

default[:scalr][:database][:client_host] = 'localhost'  # Where will the client connect from?

# Email settings
default[:scalr][:email][:from] = 'scalr@scalr.example.com'
default[:scalr][:email][:name] = 'Scalr Service'

# Host settings
default[:scalr][:endpoint][:scheme] = 'http'
default[:scalr][:endpoint][:host_ip] = '127.0.0.1'
default[:scalr][:endpoint][:host] = node.scalr.endpoint.host_ip

# Plotter settings #TODO: Deprecate when updating to 4.5
default[:scalr][:endpoint][:local_ip] = '127.0.0.1'
default[:scalr][:endpoint][:set_hostname] = false  # If you host can't resolve its IP to a name (gethostbyaddr fails), use this.

# Instance connection settings
default[:scalr][:instances_connection_policy] = 'auto'

# Load reporting settings
default[:scalr][:rrd][:rrd_dir] = '/var/lib/rrdcached/db'
default[:scalr][:rrd][:journal_dir] = '/var/lib/rrdcached/journal'
default[:scalr][:rrd][:run_dir] = value_for_platform_family(
  %w(rhel fedora) => '/var/rrdtool/rrdcached',
  'debian' => '/var/run'
)
# ^^ Don't change this. Scalrpy somehow wants rrdcached.pid to be found in this
# run_dir. Unfortunately, neither Ubuntu nor Debian let us specify this, so instead
# of pointing rrd at the right directory, we point Scalrpy to it.
default[:scalr][:rrd][:img_url] = '/graphics'
default[:scalr][:rrd][:img_dir] = "#{node.scalr.core.location}/app/www#{node.scalr.rrd.img_url}"
default[:scalr][:rrd][:port] = 8080

# Scalr Daemon Attributes
default[:scalr][:services] = [
  {:service_name => 'msgsender', :service_module => 'msg_sender', :service_desc => 'Scalr Messaging Daemon', :service_extra_args => '', :run => {
    :daemon => true
  }},
  {:service_name => 'dbqueue', :service_module => 'dbqueue_event', :service_desc => 'Scalr DB Queue Event Poller', :service_extra_args => '', :run => {
    :daemon => true
  }},
  {:service_name => 'plotter', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Plotter', :service_extra_args => '--plotter', :run => {
    :daemon => true
  }},
  {:service_name => 'poller', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Poller', :service_extra_args => '--poller', :run => {
    :daemon => true
  }},
]

if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
  # The Scalarizr Update and Cost Analytics Scalrpy were introduced in Scalr 5.0

  if Gem::Dependency.new('scalr', '>= 5.1').match?('scalr', node.scalr.package.version)
    # In Scalr 5.1, the Scarlrpy jobs all run as daemons instead of services.
    poller_run = {:daemon => true}
    processor_run = {:daemon => true}
    updater_args = ''
  else
    poller_run = {:cron => {:hour => '*', :minute => '*/5'}}
    processor_run = {:cron => {:hour => '*', :minute => '7,37'}}
    updater_args = '--interval=120'
  end

  extra_services = [
    {:service_name => 'szrupdater', :service_module => 'szr_upd_service', :service_desc => 'Scalarizr Update Client', :service_extra_args => updater_args, :run => {
      :daemon => true
    }},
    {:service_name => 'analytics_poller', :service_module => 'analytics_poller', :service_desc => 'Scalr Analytics Poller', :service_extra_args => '', :run => poller_run},
    {:service_name => 'analytics_processor', :service_module => 'analytics_processing', :service_desc => 'Scalr Analytics Processor', :service_extra_args => '', :run => processor_run},
  ]

  default[:scalr][:services].concat extra_services
end


default[:scalr][:cron][:path] = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
default[:scalr][:cron][:crons] = [
  {:hour => '*',    :minute => '*',    :ng => false, :name => 'Scheduler'},
  {:hour => '*',    :minute => '*/5',  :ng => false, :name => 'UsageStatsPoller'},
  {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Scaling'},
  {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'BundleTasksManager'},
  {:hour => '*',    :minute => '*/15', :ng => true,  :name => 'MetricCheck'},
  {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Poller'},
  {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'},
  {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'EBSManager'},
  {:hour => '*',    :minute => '*/20', :ng => false, :name => 'RolesQueue'},
  {:hour => '*',    :minute => '*/5',  :ng => true,  :name => 'DbMsrMaintenance'},
  {:hour => '*',    :minute => '*/20', :ng => true,  :name => 'LeaseManager'},
  {:hour => '*',    :minute => '*',    :ng => true,  :name => 'ServerTerminate'},
  {:hour => '*/5',  :minute => '0',    :ng => false,  :name => 'RotateLogs'},
]

if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
  extra_crons = [
    {:hour => '*/12',  :minute => '0',    :ng => false,  :name => 'CloudPricing'},
    {:hour => '1',     :minute => '0',    :ng => false,  :name => 'AnalyticsNotifications'},
  ]

  default[:scalr][:cron][:crons].concat extra_crons

  messaging_crons = %w{
    SzrMessagingAll SzrMessagingAll2
    SzrMessagingBeforeHostUp SzrMessagingBeforeHostUp2
    SzrMessagingHostInit SzrMessagingHostInit2
    SzrMessagingHostUp SzrMessagingHostUp2
  }
else
  messaging_crons = %w{SzrMessaging}
end

messaging_crons.each do |messaging_cron|
  default[:scalr][:cron][:crons].push({:hour => '*', :minute => '*/2', :ng => false, :name => messaging_cron})
end


# Time attributes
default['tz'] = 'UTC'

# PHP attributes
include_attribute 'php'

default['php']['version'] = '5.5.7'
default['php']['install_method'] = 'package'

case node['platform_family']
when 'rhel', 'fedora'
  # View here for package contents (extensions): https://webtatic.com/packages/php55/
  default['php']['packages'] = %w{php55w php55w-devel php55w-cli php55w-mysql php55w-mcrypt php55w-snmp php55w-process php55w-xml php55w-soap php55w-pear}
  default['php']['cnf_dirs'] = %w{/etc/php.d}
when 'debian'
  # View here for package contents (extensions): http://ppa.launchpad.net/ondrej/php5/ubuntu/dists/precise/main/binary-amd64/Packages
  default['php']['packages'] = %w{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
end

default['php']['session_save_path'] = '/var/lib/scalr/sessions'


# Apache attributes
default['apache']['user'] = node.scalr.core.users.web
default['apache']['group'] = node.scalr.core.group
default['apache']['mpm'] = 'prefork'  # For mod_php
default['apache']['extra_modules'] = %w{rewrite deflate filter headers php5 authz_owner}

if node['platform_family'] == 'debian'
  # The debphp PPA we use ships Apache 2.4. These are the attributes the Apache 2 Cookbook for Apache 2.4.
  # We have to *all* of those here (not just the version), because they are defined based on the
  # apache/version attribute in the Apache 2 Cookbook.
  default['apache']['version'] = '2.4'
  default['apache']['pid_file']    = '/var/run/apache2/apache2.pid'
  default['apache']['docroot_dir'] = '/var/www/html'
end

if node['apache']['version'] == '2.4'
  # Our Scalr virtualhost uses Apache 2.2-style rules here
  default['apache']['extra_modules'].push 'access_compat'
end

# Override for a bug in yum-mysql-community cookbook (that ignores RHEL 7)
# TODO - probably doesn't need to be an override here
override['yum']['mysql55-community']['baseurl'] = "http://repo.mysql.com/yum/mysql-5.5-community/el/#{node['platform_version'].to_i}/$basearch/"

