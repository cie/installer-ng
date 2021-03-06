Scalr Installer
===============

Welcome to the Scalr installer!

Install instructions can be found below in this README, or
[on the Scalr Wiki][00].

Note: this installer replaces [scalr/installer][01].


Supported Platforms
-------------------

The Scalr Installer supports the following platforms:

  + Ubuntu: 12.04 and 14.04. **amd64 packages only.**
  + Debian: Wheezy and Jessie. **amd64 packages only.**
  + CentOS / RHEL / OEL: 6 and 7. **x86_64 packages only.**


Deploying Scalr
===============

Step 0: Choosing Your Server
----------------------------

Scalr needs to be able to talk to the cloud APIs and instances you want to
manage with it, and your instances need to be able to talk back to Scalr. You
should ensure that the server you deploy Scalr to matches those requirements.

For more information, review: [Required Network Configuration for Scalr][05].


Step 1: Installation
--------------------

Start by deploying the Scalr package appropriate for your system.

### Debian, Ubuntu ###

    curl -L https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.deb | sudo bash
    apt-get install -y scalr-server

### RHEL, CentOS, OEL ###

    curl -L https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.rpm | sudo bash
    yum install -y scalr-server


Step 2: Configuration
---------------------

Once you've deployed the packages, you need to configure Scalr. Since Scalr
can auto-detect configuration in most common deployment scenarios (e.g. when
deploying on a cloud), you should first check whether the auto-detected
configuration is suitable.

Run the following command, and follow the instructions (`/usr/bin` needs to
be on your `PATH`):

    scalr-server-wizard

If you're happy with the configuration, run:

    scalr-server-ctl reconfigure

If not, visit this link: [Packages - Advanced Usage][20].


Step 3: Access Scalr
--------------------

Once the `reconfigure` step has completed, your Scalr instance is ready to use.

Get your admin password from the Scalr secrets file in
`/etc/scalr-server/scalr-server-secrets.json`, under `admin_password`.

The admin username is `admin`.

Use those credentials to login. Scalr is listening on port 80 on your server.


Next Steps
==========

We encourage you to review the following documentation entries:

  + [First Steps as a Scalr Administrator][10] - Unless you've administered a
    Scalr install before, this is where you should start.
  + [Packages - Advanced Usage][20] - If you'd like to deploy a more
    complicated setup than the default configuration.


  [00]: https://scalr-wiki.atlassian.net/wiki/x/QgAeAQ
  [01]: https://github.com/scalr/installer
  [05]: https://scalr-wiki.atlassian.net/wiki/x/CYA0
  [10]: https://scalr-wiki.atlassian.net/wiki/x/fQAeAQ
  [20]: https://scalr-wiki.atlassian.net/wiki/x/RgAeAQ
