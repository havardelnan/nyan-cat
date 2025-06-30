console.log('Nyan!');

var NyanCat = function () {
	return {
		init: function () {
			this.cat = $('#nyan-cat');
			this.framesAmount = 6;
			this.currentFrame = 1;
		},

		cycleFrames: function () {
			var myself = this;
			this.cat.removeClass('frame' + myself.currentFrame).addClass('frame' + myself.cycleIds(myself.currentFrame));
			this.currentFrame = this.cycleIds(this.currentFrame);
		},

		cycleIds: function (_currId) {
			if (_currId >= this.framesAmount) {
				_currId = 1;
			} else {
				_currId += 1;
			}

			return _currId;
		}
	}
}

var Sparks = function () {
	return {
		init: function (_combo) {
			var yCombosAmount = Math.ceil($(document).height() / _combo.height()),
					comboTags = $(document.createElement('div')),
					newCombo = null;

			for (var a = 0; a < yCombosAmount-1; a += 1) {
				newCombo = _combo.clone();
				comboTags.append(newCombo); // <- still have to improve this crap
			}

			$('body').prepend(comboTags.html());
		}
	}
};

$(function() {
	var nyancat = new NyanCat(),
			sparks = new Sparks();

	nyancat.init();
	sparks.init($('.sparks-combo'));

	// Display hostname, image and tag on the rainbow
	var hostname = window.ENV_HOSTNAME || window.location.hostname || 'localhost';
	var image = window.ENV_IMAGE || 'unknown';
	var tag = window.ENV_TAG || 'latest';
	
	// Clean up if they contain template placeholders
	if (hostname === '${HOSTNAME}' || hostname === '') {
		hostname = window.location.hostname || 'localhost';
	}
	if (image === '${IMAGE}' || image === '') {
		image = 'unknown';
	}
	if (tag === '${TAG}' || tag === '') {
		tag = 'latest';
	}
	
	// Create display text with hostname, image and tag
	var displayText = "Hostname: " + hostname + '\n Image: ' + image + ':' + tag;
	$('#hostname-display').html(displayText.replace(/\n/g, '<br>'));

	var timer = setInterval(function () {
		nyancat.cycleFrames();
	}, 70);
});