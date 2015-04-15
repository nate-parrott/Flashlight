def results(parsed, query):
    from random import randint
    from random import choice
    from re import findall

    cc = ""
    length = 0

    if ("visa" in query.lower()):
        cc += "4"
        length = 16

    if ("master" in query.lower()):
        cc += str(randint(51,55))
        length = 16

    if ("amex" in query.lower()):
        cc += choice(["34", "37"])
        length = 15

    if ("diners" in query.lower()):
        cc += "54"
        length = 16

    if ("jcb" in query.lower()):
        cc += str(randint(3528, 3589))
        length = 16

    if ("discover" in query.lower()):
        cc += choice(["6011", str(randint(622126, 622925)), str(randint(644, 649)), "65"])
        length = 16

    if ("hiper" in query.lower()):
        cc += "384"
        length = 16

    while (len(cc) < length - 1):
        cc += str(randint(0,9))

    cc += str(luhn(cc))

    return {
        "title": "Copy {0} to clipboard".format(" ".join(findall('....?', cc))),
        "run_args": [cc]
    }

def run(message):
    from os import system

    system('echo ' + message + " | pbcopy && osascript -e 'display notification \"Credit card copied to clipboard.\" with title \"Flashlight\"'")

def luhn(input):
    digits = [int(c) for c in input if c.isdigit()]
    digits.reverse()
    doubled = [2 * d for d in digits[0::2]]
    total = sum(d - 9 if d > 9 else d for d in doubled) + sum(digits[1::2])
    return (total * 9) % 10
