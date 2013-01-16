Create screenshots from websites via json jobfiles
==================================================

This script creates screenshots from websites via `PhantomJS`_

This script is used as backend for the `Screener`_ webapp.

JSON jobfile
++++++++++++

	{
	 "Output": "/tmp/foobar.png",

	 "ViewPort": "1280x1024",

	 "Url": "http://www.fotokasten.de",

	 "UserAgent": "HggH Screenshot System with PhantomJS",

	}

PJS Configuration
+++++++++++++++++

Please use conf/pjs.example.conf as example configuration file.


PJS with Selenium Webdriver with PhantomJS
++++++++++++++++++++++++++++++++++++++++++

With PhantomJS >= 1.8 you can start PhantomJS with '''phantomjs --webdriver=127.0.0.1:8910'''.

After starting up PhantomJS, please set :selenium_phantomjs to true. So pjs will not start for every
screenshot the phantomJS binary.

This feature requires to install the "selenium-webdriver" gem.


Contact?
++++++++
Jonas Genannt / http://blog.brachium-system.net



.. _PhantomJS: http://www.phantomjs.org/
.. _Screener: http://screener.brachium-system.net/
