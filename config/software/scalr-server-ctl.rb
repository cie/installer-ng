#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# Copyright:: Copyright (c) 2015 Scalr, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name 'scalr-server-ctl'

dependency 'omnibus-ctl'

source :path => File.expand_path('files/scalr-server-ctl-commands', Omnibus::Config.project_root)

build do
  block do
    open("#{install_dir}/bin/scalr-server-ctl", 'w') do |file|
      file.print <<-EOH
#!/bin/bash
#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# Copyright:: Copyright (c) 2015 Scalr, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Ensure the calling environment (disapproval look Bundler) does not infect our
# Ruby environment if scalr-server-ctl is called from a Ruby script.
for ruby_env_var in RUBYOPT \\
                    BUNDLE_BIN_PATH \\
                    BUNDLE_GEMFILE \\
                    GEM_PATH \\
                    GEM_HOME
do
  unset $ruby_env_var
done
#{install_dir}/embedded/bin/omnibus-ctl scalr-server #{install_dir}/embedded/service/omnibus-ctl $@
      EOH
    end
  end

  command "chmod 755 #{install_dir}/bin/scalr-server-ctl"

  # additional omnibus-ctl commands
  command "rsync -a ./ #{install_dir}/embedded/service/omnibus-ctl/"
end