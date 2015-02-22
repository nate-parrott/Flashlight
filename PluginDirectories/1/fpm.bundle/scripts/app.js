(function(w, d, $){

    //Utilities
    w.isFunction = function(fn) {
        return typeof fn === 'function';
    };
    w.ajax = function(options){
        var req = new w.XMLHttpRequest();
        req.open((options.method || 'GET').toUpperCase(), options.url, true);
        if(options.auth && options.auth.user && options.auth.password) {
            req.setRequestHeader("Authorization", "Basic " + btoa(options.auth.user + ':' + options.auth.password));
        }
        req.onreadystatechange = function (aEvt) {
            var data, contentType;
            if (req.readyState === 4 && req.status === 200) {
                //Success
                if(isFunction(options.success)) {
                    data = req.responseText;
                    contentType = req.getResponseHeader('Content-Type');
                    if(contentType && /json/i.test(contentType) || options.json) {
                        data = JSON.parse(data);
                    }
                    options.success.call(req, data);
                }
            }
            else {
                //Failure
                if(isFunction(options.error)) {
                    options.error.call(req);
                }
            }
        };
        req.send(null);
    };
    //end utilities

    //Since using the API is not really an option due to the rate limits
    //let's just scrape the user's Github homepage...
    function scrape(htmldata) {
        var $htmldata = $(htmldata);
        var data = {};

        data.name = $htmldata.find('.vcard-fullname').text();
        data.avatar_url = $htmldata.find('.vcard-avatar').attr('href');
        data.location = $htmldata.find('.vcard-details [itemprop=homeLocation]').text();
        data.email = $htmldata.find('.vcard-details .email').text();
        data.url = $htmldata.find('.vcard-details .url').attr('href');

        return data;
    }


    //Get Flashlight-specific info from info.json
    w.ajax({
        url: 'https://raw.githubusercontent.com/{USER}/{REPO}/master/info.json'
                .replace('{USER}', w.config.user).replace('{REPO}', w.config.repo),
        json: true,
        success: function(info){
            d.querySelector('.description').innerHTML = info.description;
            d.querySelector('.version').innerHTML = 'Version: ' + (info.version || 'unknown');
            d.querySelector('.categories').innerHTML = 'Categories: ' + ((info.categories && info.categories.join(', ')) || 'unknown');
            if(info.examples) {
                d.querySelector('.examples-title').style.display = 'block';
                d.querySelector('.examples').innerHTML = info.examples.join('\n');
            }
        },
        error: function(e){
            if(this.status === 404) {
                d.querySelector('.description').innerHTML = 'The repository does not exist or is not a Flashlight plugin.';
                d.querySelector('.description').classList.add('error');
            }
        }
    });
    w.ajax({
        url: 'https://github.com/{USER}'.replace('{USER}', w.config.user),
        success: function(htmldata){
            var data = scrape(htmldata);
            d.querySelector('.owner-name').innerHTML = data && data.name;
            d.querySelector('.owner-email').innerHTML = data && data.email;
            d.querySelector('.owner-url').innerHTML = data && data.url && '<a href="' + data.url +'">' + data.url + '</a>';
            d.querySelector('.owner-location').innerHTML = data && data.location;
            d.querySelector('.owner-pic').style.backgroundImage = data && data.avatar_url && 'url(' + data.avatar_url + ')';
        },
        error: function(e){
            if(this.status === 404) {
                d.querySelector('.owner-name').innerHTML = 'This Github user does not exist.';

            }
        }
    });

})(window, document, jQuery);