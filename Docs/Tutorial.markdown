# Creating a Plugin

This document is a simple walkthrough for creating a plugin. We'll create a simple _say_ plugin, which wraps the OS X command-line `say` command to speak whatever text the system gives us.

If you're writing a simple plugin like search, you may instead want to try copying and modifying an existing plugin like _websearch_.

A plugin needs a couple things, which we'll explain below:

 - a .bundle file
 - an info.json
 - an examples.txt
 - a plugin.py

## Creating the bundle

All plugins live in `~/Library/FlashlightPlugins`. To begin, create a folder and name it `say.bundle`. OS X will immediately give it a fancy lego-brick icon. Right-click and _Show Package Contents_. 

## info.json

The first thing we need is an `info.json` file. Here's what to put in it:

```
{
   "name": "say", (this must be the same as your folder name)
   "displayName": "Say Something",
   "description": "Speaks your input text",
   "examples": ["say hello world", "say good morning"], (these appear by your plugin's description),
   "categories": ["Utilities"],
   "creator_name": "Your name",
   "creator_url": "A link of your choosing"
}
```

Once that's there, you should be able to open up the Flashlight _Installed_ list and see your plugin. It doesn't do anything yet.

## examples.txt

We need to give Flashlight some examples of commands that should invoke your plugin. Create an `examples.txt` file.

If this were a simple plugin like `shutdown`, which shuts down your computer, the examples would the things like _shutdown_, _shut down_, and _turn off my computer_. Our plugin, though, takes text input (the text to speak), so we need to add a _field_ — a slot that Flashlight will fill with text, and pass on to us. That looks like this:

```
say ~message(Good Morning)
speak ~message(Hello, world)
please speak ~message(what's up) out loud
```

As you can imagine, Flashlight will recognize phrases like _speak good morning out loud_ and pass _good morning_ on to our plugin.

If you have more complex queries you want to process, you should [learn more about the parser and examples.txt](Parser.markdown).

## plugin.py

When someone types a command like _speak good morning_ (but before they press enter), our `plugin.py` file will be loaded, and the `results` function is going to be invoked. It'll pass in a dictionary containing all our _fields_ — in this case, just _~message_, which will be set to _good morning_. It'll also pass the entire original query if we need it.

All we need to do is return a dictionary containing information about what should appear in Spotlight.

```
def results(fields, original_query):
  message = fields['~message']
  return {
    "title": "Say '{0}'".format(message),
    "run_args": [message] # ignore for now
  }

```

There. Now, if we type "speak hello spotlight" into Spotlight, we'll see the title our plugin returned.

## Detour: debugging

Sometimes, your Python script might crash. That's okay. You can view `plugin.py` crashes in `console.app` — just expand logs that say "Querying Flashlight plugins".

## Running the plugin
Of course, the plugin doesn't actually _do_ anything yet — ideally, we want it to speak something out loud when we hit Enter. That's easy. Just add a function `run` to `plugin.py`.

Now, we need some way of passing the message that we're supposed to speak to `run`. That's why we returned an array containing the message in the `run_args` fild of our `results` dictionary. `run` is invoked with the arguments from the `run_args` list (in fact, you _need_ a run_args list for `run` to even be called, although it can be empty.)

```
def run(message):
  import os
  os.system('say "{0}"'.format(message)) # TODO: proper escaping via pipes.quote
```

There. **Now our plugin should work.** Type "say hello" into Spotlight, hit enter, watch it go.

## Showing HTML inline in Spotlight

Many plugins, like Weather and Google, return HTML and JavaScript to show content inline in the Spotlight window. You can do this by returning an HTML string from your `results` function:

```
def results(fields, original_query):
  message = fields['~message']
  html = "<h1>{0}</h1>".format(message)
  return {
    "title": "Say '{0}'".format(message),
    "run_args": [message] # ignore for now,
    "html": html
  }

```

If you'd like to load a web URL, you should return a `delayed Javascript redirect`, which looks like this:

```
<script>
setTimeout(function() {
  window.location = 'http://google.com'
}, 500); // delay so we don't get rate-limited by doing a request after every keystroke
</script>
```

There are two more fields you can return in your `results` json that may be relevant if you're using webviews:

 - `webview_links_open_in_browser`: _optional_ when the user clicks links in the webview, they'll close Spotlight and open in a browser
 - `webview_user_agent`: _optional_ override the user agent in the webview. Useful if you want to load a mobile-optimized site that fits the size of the Spotlight window.

## Performance

**Your results function should return fast.** There's no time to perform HTTP requests. If you need to fetch data from the web (like the Weather plugin), you should _return HTML and Javascipt_ that make the request. This way, users can see your result while it's loading. The JS you return from `results` is not subject to the same-origin policy.

## Adding icons

Add a 512x512 (or smaller) icon to your bundle, and call it `Icon.png`. Circular icons are preferred.

## Internationalizing your plugin

See [internationalization](Internationalization.markdown).

## Other tasks

If you're doing things like searching contacts or running Applescript, you should check out the [useful modules for plugins](https://github.com/nate-parrott/Flashlight/tree/master/UsefulModulesForPlugins).

## Submitting the plugin

Once you've written a plugin, we'd love for you to submit it so others can download it from within Flashlight. Clone Flashlight, stick your `.bundle` in `PluginDirectories/1`, and submit a pull request.

