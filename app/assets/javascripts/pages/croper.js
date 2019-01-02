'use strict';
$(document).ready(function() {
	var $image = $('#image');
	var $download = $('#download');
	var $dataX = $('#dataX');
	var $dataY = $('#dataY');
	var $dataHeight = $('#dataHeight');
	var $dataWidth = $('#dataWidth');
	var options = {
		aspectRatio: 1,
		preview: '.img-preview',
		crop: function (e) {
			$dataX.val(Math.round(e.x));
			$dataY.val(Math.round(e.y));
			$dataHeight.val(Math.round(e.height));
			$dataWidth.val(Math.round(e.width));
		}
	};

	// Cropper
	$image.on({
	}).cropper(options);

	// Buttons
	if (!$.isFunction(document.createElement('canvas').getContext)) {
		$('button[data-method="getCroppedCanvas"]').prop('disabled', true);
	}

	// Options
	$('.docs-toggles').on('change', 'input', function () {
		var $this = $(this);
		var name = $this.attr('name');
		var type = $this.prop('type');
		var cropBoxData;
		var canvasData;

		if (!$image.data('cropper')) {
			return;
		}

		if (type === 'checkbox') {
			options[name] = $this.prop('checked');
			cropBoxData = $image.cropper('getCropBoxData');
			canvasData = $image.cropper('getCanvasData');

			options.built = function () {
				$image.cropper('setCropBoxData', cropBoxData);
				$image.cropper('setCanvasData', canvasData);
			};
		} else if (type === 'radio') {
			options[name] = $this.val();
		}

		$image.cropper('destroy').cropper(options);
	});

	// Methods
	$('.docs-buttons').on('click', '[data-method]', function () {
		var $this = $(this);
		var data = $this.data();
		var $target;
		var result;

		if ($this.prop('disabled') || $this.hasClass('disabled')) {
			return;
		}

		if ($image.data('cropper') && data.method) {
			data = $.extend({}, data); // Clone a new one

			if (typeof data.target !== 'undefined') {
				$target = $(data.target);

				if (typeof data.option === 'undefined') {
					try {
						data.option = JSON.parse($target.val());
					} catch (e) {
						console.log(e.message);
					}
				}
			}

			result = $image.cropper(data.method, data.option, data.secondOption);
			result.toBlob(function (blob) {
				var formData = new FormData();
				formData.append('avatar', blob, '<%= @image.id %>_cut.png');
				formData.append('image_id', '<%= @image.id %>');
				$.ajax('/avatar-upload/'+userId, {
					method: "POST",
					data: formData,
					processData: false,
					contentType: false,
					success: function (returned) {
						if(returned.error) {
							alert(returned.error);
						} else {
							location.pathname = "/users";
						}
					},
					error: function () {
						alert('Error');
					}
				});
			});
		}
	});

	// Keyboard
	$(document.body).on('keydown', function (e) {

		if (!$image.data('cropper') || this.scrollTop > 300) {
			return;
		}

		switch (e.which) {
			case 37:
			e.preventDefault();
			$image.cropper('move', -1, 0);
			break;

			case 38:
			e.preventDefault();
			$image.cropper('move', 0, -1);
			break;

			case 39:
			e.preventDefault();
			$image.cropper('move', 1, 0);
			break;

			case 40:
			e.preventDefault();
			$image.cropper('move', 0, 1);
			break;
		}

	});
});
