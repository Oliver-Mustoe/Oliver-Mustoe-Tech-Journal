import argparse
import re

def main():
    # Setup arguments
    arguments = args()
    
    # Open file and place the new contents inside
    with open('new_markdown.md','w',encoding='utf-8') as nm:
        nm.write(image_replacer(arguments))
    
    
    
def args():
    # Basic parser
    arg_parser = argparse.ArgumentParser(
        prog="rtd",
        description="Program to take a markdown file and replace bad images with good ones"
    )
    
    # Add arguments
    arg_parser.add_argument(
        "-I",'--InputFile',
        help="Markdown file location",
        required=True
    )
    
    arg_parser.add_argument(
        "-A","--AllImages",
        help="Location of images",
        required=True
    )
    
    parsed_args = arg_parser.parse_args()
    return parsed_args



def image_replacer(arguments):
    # Expected image format: "image{number}{number}{number}.gif"
    
    image_regex = "!.*image\d{3}.*"
    image_replace_regex = "image0*"
    InputFile = arguments.InputFile
    Images = arguments.AllImages
    
    r_input = None
    
    # Open each file in read mode (not specified as default for open())
    with open(InputFile, encoding='utf-8') as input:
        with open(Images, encoding='utf-8') as images:
            # Read them
            r_input = input.read()
            r_images = images.read()
            
            # Turn images into list
            image_list = re.findall(image_regex,r_images)
            
            # Replace unneeded zeros
            r_input = re.sub(image_replace_regex,"image",r_input)
            
            i = 1
            # For each image
            for image in image_list:
                # Create a new image regex
                image_regex2 = "!.*image" + str(i) + ".*"

                # Substitute based on image regex with the image
                r_input = re.sub(image_regex2,image,r_input)
                
                i += 1

    return(r_input)

main()