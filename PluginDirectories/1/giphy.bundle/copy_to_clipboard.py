def copy_to_clipboard(text):
  import pipes, os
  os.system("echo %s | pbcopy"%pipes.quote(text))
  
if __name__=='__main__':
  copy_to_clipboard("this is a test")
