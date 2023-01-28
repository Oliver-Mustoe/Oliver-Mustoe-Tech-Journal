This page details how to turn this courses running documentation recorded in Google docs to markdown documentation:

1. Download document as a .docx file from Google drive

2. In word, save the file as "Web Page, Filtered" (agree to the warnings)

3. In Github, open a new issue, use the "Attach files" button to navigate to the chosen folder and select all files to upload (NOTE: Seemingly Github has a cooldown after a certain number of files, be wary of this), take these links and stick them inside a .txt file

4. Then, drag the newly created .htm file into the browser, will created webpage, press CTRL+A, and copy into a markdown editor (MarkText)

5. In a terminal, run the `python rtm.py -I {PATH_TO_MARKDOWN} -A {PATH_TO_LIST_OF_GIT_LINKS}` (should create a new md file)
