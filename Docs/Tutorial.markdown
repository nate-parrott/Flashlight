# Creating a Plugin

This document is a simple walkthrough for creating a plugin. We'll create a simple _say_ plugin, which wraps the OS X command-line `say` command to speak whatever text the system gives us.

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
   "categories": ["Utilities"]
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

**Sidenote**: sometimes, your Python script might crash. That's okay. You can view `plugin.py` crashes in `console.app` — just expand logs that say "Querying Flashlight plugins".

## Running the plugin
Of course, the plugin doesn't actually _do_ anything yet — ideally, we want it to speak something out loud when we hit Enter. That's easy. Just add a function `run` to `plugin.py`.

Now, we need some way of passing the message that we're supposed to speak to `run`. That's why we returned an array containing the message in the `run_args` fild of our `results` dictionary. `run` is invoked with the arguments from the `run_args` list (in fact, you _need_ a run_args list for `run` to even be called, although it can be empty.)

```
def run(message):
  import os
  os.system('say "{0}"'.format(message)) # TODO: proper escaping via pipes.quote
```

There. **Now our plugin should work.** Type "say hello" into Spotlight, hit enter, watch it go.

_The rest of this document is coming soon_

## Showing HTML inline in Spotlight

## Adding icons

## Internationalizing your plugin
