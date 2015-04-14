Animation = {
	iterateAsync: function(array, i, fn, done) {
		if (i < array.length) {
			fn(array[i], function() {
				Animation.iterateAsync(array, i+1, fn, done);
			});
		} else {
			done();
		}
	},
	run: function(searches, callback) {
		Animation.iterateAsync(searches, 0, function(search, next) {
			Animation.showSearch(search, function() {
				setTimeout(next, 1700);
			});
		}, function() {
			// done
			callback();
		});
	},
	showSearch: function(search, callback) {	
		var resultImage = document.getElementById('result');
		var emptyImage = document.getElementById('empty');
		var textNode = document.getElementById('text');
		
		resultImage
	  .setAttributeNS('http://www.w3.org/1999/xlink','href', '/static/animation/resources/' + search.image + '.png');
		resultImage.setAttribute('visibility', 'hidden');
		emptyImage.setAttribute('visibility', 'visible');
	
		var text = [""];
		for (var i=0; i<=search.text.length; i++) {
			text.push(search.text.substring(0, i));
		}
		
		Animation.iterateAsync(text, 0, function(text, next) {
			var opacity = "1.0";
			if (text.length == 0) {
				opacity = "0.3";
				text = "Spotlight Search";
			}
			textNode.textContent = text;
			textNode.setAttribute("opacity", opacity);
			setTimeout(next, 40);
		}, function() {
			resultImage.setAttribute('visibility', 'visible');
			emptyImage.setAttribute('visibility', 'hidden');
			callback();
		});
	}
}

var searches = [
	{
		text: "weather new york",
		image: "Weather"
	},
	{
		text: "text justin: where are you?",
		image: 'Messages'
	},
	{
		text: "calendar event \"dentist appointment\" tuesday",
		image: "CalendarEvents"
	},
	{
		text: "/apple watch launch",
		image: "WebSearch"
	},
	{
		text: "remind me to buy shampoo tomorrow",
		image: "Reminders"
	},
	{
		text: "beer emoji",
		image: "EmojiSearch"
	},
	{
		text: "translate bicycle to french",
		image: "Translate"
	},
	{
		text: "spell beuatiful",
		image: "Spelling"
	},
	{
		text: "twitter.com",
		image: "OpenURL"
	},
	{
		text: "call justin",
		image: "Call"
	},
	{
		text: "sadness gif",
		image: "Giphy"
	},
	{
		text: "email titanic.png to nate",
		image: "Emails"
	},
	{
		text: "new note 718 123 4567",
		image: "CreateNote"
	}
]

function loopAnimation() {
	Animation.run(searches, function() {
		loopAnimation();
	})
}

document.addEventListener("DOMContentLoaded", function(event) { 
	loopAnimation();
});

