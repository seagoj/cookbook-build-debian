# --- Install packages we need ---
#include_attribute "build-debian::php-5.5.2"

require 'rubygems'
require 'json'
packages = %w(checkinstall automake build-essential make auto-apt bison re2c libcurl4-openssl-dev pkg-config openssl libssl-dev libxml2-dev php5-dev firebird2.5-classic-common firebird2.5-common firebird2.5-common-doc firebird2.5-server-common firebird2.5-superclassic libfbclient2 libfbembed2.5 libib-util libxslt-dev)
packages.each{ |p| package p }

execute "Link libfbclient.so" do
    cwd "/usr/lib/x86_64-linux-gnu"
    user "root"
    command "ln -s libfbclient.so.2.5.1 libfbclient.so"
end

extensions = ['.tgz', '.tar.gz', '.bz2', '.tar.bz2']
builds = []
extensions.each do |ext|
    Dir.chdir("/vagrant");
    glob = Dir.glob("*#{ext}")
    glob.each do |g|
        project = g.slice(0,g.length-ext.length)
        builds << {
            :archive=>g,
            :project=>project,
            :config=>node[project.to_sym][:config],
            :source=>node[project.to_sym][:source]
        }
    end
end

builds.each do |build|
    if File.exists?("/vagrant/#{build[:project]}")
        execute "Cleanup #{build[:project]}" do
            cwd "/vagrant"
            user "root"
            command "rm -r #{build[:project]}"
        end
    end

    # Reuse or pull down source archive
    unless File.exists?(build[:archive])
        remote_file build[:archive] do
            source "build[:source]"
            mode "0755"
        end
    end

    execute "Expand PHP tarball" do
        cwd "/vagrant"
        user "root"
        command "tar -xvf #{build[:archive]}"
    end

    cookbook_file "/vagrant/php-5.5.5/ext/interbase/ibase.h" do
        owner "root"
        group "root"
        source "ibase.h"
        mode 00755
    end

    execute "Configure" do
        cwd "#{build[:project]}"
        user "root"
        command "auto-apt run ./configure #{build[:config]}"
    end

    execute "Make" do
        cwd "#{build[:project]}"
        user "root"
        command "make"
        timeout 7200
    end

    execute "Make Test" do
        cwd "#{build[:project]}"
        user "root"
        command "make test"
        timeout 7200
    end

    execute "Build" do
        cwd "#{build[:project]}"
        user "root"
        command "checkinstall"
        timeout 7200
    end

    execute "Move Debian" do
        cwd "#{build[:project]}"
        user "root"
        command "mv *.deb .."
    end
end
