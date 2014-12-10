import re
from commanding import Phrase

tagged_text = re.compile(r"([a-zA-Z0-9_\-\~\*\/@]+)\(([^\)]+)\)")

def parse_example_to_phrase(phrase_intent, example):
        prev_index = 0
        tokens = []
        for match in re.finditer(tagged_text, example):
            if match.start() > prev_index:
                text = example[prev_index:match.start()].strip()
                if len(text):
                    tokens.append(text)
            tokens.append([match.group(1).strip(), match.group(2).strip()])
            prev_index = match.end()
        if prev_index < len(example):
            tokens.append(example[prev_index:].strip())
        return Phrase(phrase_intent, tokens)

if __name__=='__main__':
    assert str(Phrase("weather", ["how's the weather in", ["place", "Scotland"], "?"])) == str(parse_example_to_phrase("weather", "how's the weather in place(Scotland)?"))
