# --- Install packages we need ---
require 'rubygems'
require 'json'
packages = %w(checkinstall automake build-essential make auto-apt)
packages += JSON.parse(open("/vagrant/packages.json").read) if File.exists?("/vagrant/packages.json")
packages.each{ |p| package p }
config = JSON.parse(open("/vagrant/config.json").read) if File.exists?("/vagrant/config.json")

extensions = ['.tgz', '.tar.gz', '.bz2']
builds = {}
extensions.each do |ext|
    glob = Dir.glob("*#{ext}")
    glob.each do |g|
        project = g.slice(0,ext.length)
        builds += {:archive=>g, :project=>project, :config=>config[project], :source=>""}
    end
end

builds.each do |build|
    if File.exists?("/vagrant/#{build[:project]}")
        execute "Cleanup #{build[:project}" do
            cwd "/vagrant"
            user "root"
            command "rm -r #{build[:project]}"
        end
    end

    # Reuse or pull down source archive
    unless build[:archive].exists?
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

    execute "Configure" do
        cwd "#{build[:project]}"
        user "root"
        command "auto-apt run ./configure #{build[config]}"
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
