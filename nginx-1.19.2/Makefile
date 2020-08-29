
default:	build

clean:
	rm -rf Makefile objs

build:
	$(MAKE) -f objs/Makefile

install:
	$(MAKE) -f objs/Makefile install

modules:
	$(MAKE) -f objs/Makefile modules

upgrade:
	/home/ironfox/iron/sbin/ -t

	kill -USR2 `cat /home/ironfox/iron/logs/nginx.pid`
	sleep 1
	test -f /home/ironfox/iron/logs/nginx.pid.oldbin

	kill -QUIT `cat /home/ironfox/iron/logs/nginx.pid.oldbin`
