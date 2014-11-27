import os
import i18n


def run(cmd):
    os.system(cmd)


def results(parsed, original_query):
    if ("lock_command" in parsed):
        return {
            "title": i18n.localstr('Lock Mac'),
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
