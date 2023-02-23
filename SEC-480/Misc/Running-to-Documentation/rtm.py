import argparse
import re

def main():
    # Setup arguments
    arguments = args()
    
    # Open file and place the new contents inside
    filename = arguments.Name + '.md'
    with open(filename,'w',encoding='utf-8') as nm:
        nm.write(image_replacer(arguments))
    
    
    
def args():
    # Basic parser
    arg_parser = argparse.ArgumentParser(
        prog="rtd",
        description="Program to take a markdown file and replace bad images with good ones"
    )
    
    # Add arguments
    arg_parser.add_argument(
        "-i",'--InputFile',
        help="Markdown file location",
        required=True
    )
    
    arg_parser.add_argument(
        "-a","--AllImages",
        help="Location of images",
        required=True
    )
    
    arg_parser.add_argument(
        "-n","--Name",
        help="Name of the output file, no .md in name",
        required=True
    )
    
    parsed_args = arg_parser.parse_args()
    return parsed_args



def image_replacer(arguments):
    # Expected image format: "image{number}{number}{number}.png"

    InputFile = arguments.InputFile
    Images = arguments.AllImages
    
    r_input = None
    
    # Open each file in read mode (not specified as default for open())
    with open(InputFile, encoding='utf-8') as input, open(Images, encoding='utf-8') as images:
        # Read them
        r_input = input.read()
        r_images = images.read()
        
        # With current method, embedded in the webpage should be .gif files in intervals of 2's, need to replace them with the png files (same amount)
        
        # Replace unneeded zeros
        # r_input = re.sub(image_replace_regex,"image",r_input)
        
        # Turn images into list
        image_list = r_images.splitlines()
                            
        i = 2
        ii = 0
        # For each image
        while ii < len(image_list):
            # Create a new image regex to search for the .gifs
            image_regex = "!.*image" + str(i).zfill(3) + ".gif.*"
            replace = image_list[ii]
            # Substitute based on image regex with the .png, which happens to the index of i-2 or ii
            r_input = re.sub(image_regex,replace,r_input)
                
            i += 2
            ii += 1
            
            

    return(r_input)

main()

# Still need to change the data set to just be the pngs!