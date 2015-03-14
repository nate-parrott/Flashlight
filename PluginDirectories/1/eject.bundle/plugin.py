import os
import i18n
import commands


def run(cmd):
    os.system(cmd)

def getvolumes(fields):
    value = fields.get('~device')
    if value==None:
        command="find /Volumes -maxdepth 1 -not -user root -a -not -name '.*' -iname '*'"
    else:
        command="find /Volumes -maxdepth 1 -not -user root -a -not -name '.*' -iname '"+value+"*'"
    status, output = commands.getstatusoutput(command)
    return output

def results(fields, original_query):

    if ('eject all' in original_query or "ejectall" in original_query or "ejecall" in original_query         
        or "ejall" in original_query or "ej all" in original_query):
        return {
            "title": i18n.localstr('Eject All Volumes'),
            "run_args": ["osascript -e 'tell application \"Finder\" to eject (every disk whose ejectable is true)';find /Volumes -maxdepth 1 -not -user root -a -not -name '.*' -print0 | xargs -0 umount"]
        }
        
    if ('eject' in original_query  or 'ej' in original_query):
        command=getvolumes(fields);
        if len(command)>0:
            return {
                "title": "Eject "+command.replace("/Volumes/",""),
                "run_args": ["umount "+command.replace(" ","\ ")+";diskutil eject "+command.replace(" ","\ ")]
            }  
        else:
            return None