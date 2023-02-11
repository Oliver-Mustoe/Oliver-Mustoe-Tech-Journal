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
    # Expected image format: "image{number}{number}{number}.png"
    
    image_regex = ".*image.*"
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
            
            # Replace unneeded zeros
            r_input = re.sub(image_replace_regex,"image",r_input)
            
            # Turn images into list
            image_list = re.findall(image_regex,r_images)
                             
            i = 1
            
            # For each image
            while i <= len(image_list):
                # Create a new image regex
                image_regex2 = "!.*image" + str(i) + ".gif.*"
                replace = image_list[i-2]
                # Substitute based on image regex with the image, i-1 to use png image instead of gif image
                r_input = re.sub(image_regex2,replace,r_input)
                print(image_regex2)
                    
                i += 1
            
            

    return(r_input)

main()

# Still need to change the data set to just be the pngs!