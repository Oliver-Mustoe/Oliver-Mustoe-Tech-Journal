# Version 0.4
# Description: Converts HTML page links (relative & absolute) from Wikipedia into a readable list, absolute links are restricted to three letter top domains
# TODO: Relative links need work on se to make it work
import re

test=open("EXAMPLELINKS.txt")

# Use with on open to ensure cleanup, rename to "test_str"
with test as test_str:
    # Go through each line of input
    for xx in test_str:
        # Cleanup input by removing trailing characters with rstrip
        x=xx.rstrip()
        # Absolute links
        # If line contains http: or https: then-
        if re.search(r'http(s?):',x):
            # Absolite links
            # -find link by using regex, then print
            pri=re.findall(r'(?<=a href=").+(?=")', x)
            pri.extend(re.findall(r'(?<=\.\w\w\w">).+(?=<\/a>)', x))
            # indexs for cleaner output
            print(pri[0]+","+pri[1])
        # Relative links
        # Simliar to above, finds the relative links by searching for "a href=", then finds link with regex
        elif re.search(r'a href=',x):
            pri2=re.findall(r'(?<=a href=").+(?=" title)', x)
            pri2.extend(re.findall(r'(?<=>)\b.+(?=<\/a><\/li>$)', x))
            print(pri2[0]+","+pri2[1])