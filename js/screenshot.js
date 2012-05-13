// Copyright Jonas Genannt <jonas@brachium-system.net>
// Licensed under the Apache License, Version 2.0

var page = new WebPage();
var fs   = require('fs');
page.viewportSize = { width: 1600, height: 1200 };
page.settings.userAgent = 'HggH PhantomJS Screenshoter';

if (phantom.args.length === 0) {
	console.log('Usage: screenshot.js <some JSON>');
	phantom.exit();
}

try {
	f = fs.read(phantom.args[0]);

} catch (e) {
	console.log(e);
}

var screenshot = JSON.parse(f);
var view_port  = screenshot.ViewPort.split(/x/);
page.viewportSize = { width: view_port[0], height: view_port[1] };

page.onLoadFinished = function (status) {
	if (status !== 'success') {
		phantom.exit(1);
	}
	page.render(screenshot.Output);
	phantom.exit();
}

page.open(screenshot.Url);
