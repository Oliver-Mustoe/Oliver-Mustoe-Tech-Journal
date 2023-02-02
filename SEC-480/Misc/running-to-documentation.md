This page details how to turn this courses running documentation recorded in Google docs to markdown documentation:

1. Download document as a .docx file from Google drive

2. In word, save the file as "Web Page"

3. In Github, open a new issue, use the "Attach files" button to navigate to the chosen folder and select all files to upload (NOTE: Seemingly Github has a cooldown after a certain number of files, be wary of this), take these links and stick them inside a .txt file IN ORDER (ALSO, seems word creates a copy of each of the files, so you only need the even number of each)

4. Then, drag the newly created .htm file into the browser, will created webpage, press CTRL+A, and copy into a markdown editor (MarkText)

5. In a terminal, run the `python rtm.py -I {PATH_TO_MARKDOWN} -A {PATH_TO_LIST_OF_GIT_LINKS}` (should create a new md file)

TODO: Made a python program to remove the images as well