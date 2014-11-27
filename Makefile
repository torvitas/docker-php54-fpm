-include make.d/*

build:
	docker build -t $(DOCKERPREFIX)php54-fpm .

pull:
	docker pull torvitas/php54-fpm 

install:
	sudo cp systemd/docker-php54-fpm.service.tmpl $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php54-fpm.service
	sudo cp -r systemd/docker-php54-fpm.service.d $(SYSTEMDSERVICEFOLDER)
	sudo sed -i s/$(DOCKERNAMESPACEPLACEHOLDER)/$(DOCKERNAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php54-fpm.service
	sudo sed -i s/$(NAMESPACEPLACEHOLDER)/$(NAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php54-fpm.service
	cd $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php54-fpm.service.d/ && sudo ln -s ../$(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php-fpm.service.d/EnvironmentFile
	sudo sed -i s/LINKSTO=/LINKSTO=--link\ $(NAMESPACE)-php54-fpm:fpm54\ /g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service.d/EnvironmentFile
	sudo systemctl enable $(NAMESPACE)-php54-fpm.service

run:
	sudo systemctl start $(NAMESPACE)-php54-fpm

systemd-service-folder:
	sudo mkdir -p $(SYSTEMDSERVICEFOLDER)

uninstall:
	-sudo systemctl stop $(NAMESPACE)-php54-fpm
	-sudo systemctl disable $(NAMESPACE)-php54-fpm
	-docker stop $(NAMESPACE)-php54-fpm
	-docker rm $(NAMESPACE)-php54-fpm
	-cd $(SYSTEMDSERVICEFOLDER); sudo rm -r $(NAMESPACE)-php54-fpm.service*
	sudo sed -i s/--link\ $(NAMESPACE)-php54-fpm:fpm54\ //g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service.d/EnvironmentFile
