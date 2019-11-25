all:

config:
	ansible-playbook -v -i inventories/inventory install.yml --skip-tags "packages"

install:
	
	ansible-playbook -v -i inventories/inventory install.yml
