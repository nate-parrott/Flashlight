import os
import i18n


def run(cmd, lock=False):
    if lock is True:
        # Taken from http://apple.stackexchange.com/a/123738
        import objc
        # We don't load module_globals as we only need the principalClass
        bundle = objc.loadBundle('AppleKeychainExtra',
                                 bundle_path="/Applications/Utilities/Keychain Access.app/Contents/Resources/Keychain.menu",
                                 module_globals=None, scan_classes=False)
        instance = bundle.principalClass().alloc().init()
        instance.performSelector_withObject_("_lockScreenMenuHit:", None)
    else:
        os.system(cmd)


def results(parsed, original_query):
    if ("lock_command" in parsed):
        return {
            "title": i18n.localstr('Lock Mac'),
            "run_args": ["",True] # **kwargs doesn't work so use argument positions.
        }

    if ("switch_user_command" in parsed):
        return {
            "title": i18n.localstr('Switch User'),
            "run_args": ["/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"]
        }

    if ('restart_command' in parsed):
        return {
            "title": i18n.localstr('Restart Mac'),
            "run_args": ["osascript -e 'tell app \"System Events\" to restart'"]
        }

    if ('sleep_command' in parsed):
        title = i18n.localstr('Put Mac to sleep')
        return {
            "title": title,
            "run_args": ["osascript -e 'tell app \"System Events\" to sleep'"]
        }

    if ('shutdown_command' in parsed):
        return {
            "title": i18n.localstr('Shut down Mac'),
            "run_args": ["osascript -e 'tell app \"System Events\" to shut down'"]
        }

    if ('logout_command' in parsed):
        return {
            "title": i18n.localstr('Log out'),
            "run_args": ["osascript -e 'tell app \"System Events\" to log out'"]
        }

    if ('empty_trash_command' in parsed):
        return {
            "title": i18n.localstr('Empty the Trash'),
            "run_args": ["osascript -e 'tell app \"Finder\" to empty the trash'"]
        }

    if('screen_saver' in parsed):
        return {
            "title": i18n.localstr('Turn on Screen Saver'),
            "run_args": ["open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app"]
        }
