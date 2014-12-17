import i18n

def results(parsed, original):
  import json
  return {
    "title": i18n.localstr("Yes or no?!"),
    "html": open(i18n.find_localized_path("yesno.html")).read(),
    "pass_result_of_output_function_as_first_run_arg": True,
    "webview_transparent_background": True
  }
