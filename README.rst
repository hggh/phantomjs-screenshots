Create screenshots from websites via json jobfiles
==================================================

This script creates screenshots from websites via `PhantomJS`_

This script is used as backend for the `Screener`_ webapp.

JSON jobfile
++++++++++++

	{
	 "Output":"/tmp/foobar.png",
	 "ViewPort":"1280x1024",
	 "Url":"http://www.fotokasten.de"
	}

PJS Configuration
+++++++++++++++++

Please use conf/pjs.example.conf as example configuration file.

Contact?
++++++++
Jonas Genannt / http://blog.brachium-system.net



.. _PhantomJS: http://www.phantomjs.org/
.. _Screener: http://screener.brachium-system.net/
