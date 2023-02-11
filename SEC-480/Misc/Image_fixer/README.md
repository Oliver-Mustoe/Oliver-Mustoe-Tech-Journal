This page details how to turn this courses .gif files into the proper .png.

1. Download document as a .docx file from Google drive

2. In word, save the file as "Web Page"

3. Remove all of the .gif files from the folder of images that is created (search for .gif, select all, delete)

4. Upload all of the images onto Github, navigate to the first image (image001), copy it

5. In a terminal, run the `python .\M2-4_fix.py -I {MARKDOWN_FILE} -F {FIRST_IMAGE_LINK} -L {LAST_IMAGE_NUMBER}` (should create a new md file)