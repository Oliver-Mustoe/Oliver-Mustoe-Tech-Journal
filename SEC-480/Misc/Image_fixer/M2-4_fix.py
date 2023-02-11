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
        "-F","--FirstLink",
        help="First link in the dataset (folder that was uploaded to Github)",
        required=True
    )
    
    arg_parser.add_argument(
        "-L","--LastImageNumber",
        help="Last number from link in dataset (folder uploaded to Github)",
        required=True
    )
    
    parsed_args = arg_parser.parse_args()
    return parsed_args



def image_replacer(arguments):
    # Expected image format: "image{number}{number}{number}.png"
    InputFile = arguments.InputFile
    
    r_input = None
    
    # Open the markdown file in read mode (not specified as default for open())
    with open(InputFile, encoding='utf-8') as input:
            # Read them
            r_input = input.read()
                                         
            i = 2
            ii = 1
            # While the last image number hasnt been reached
            while i <= int(arguments.LastImageNumber):
                # Create a new image regex
                image_regex2 = "!.*image" + str(i).zfill(3) + ".*gif.*"
                # Substitute based on image regex with the raw image link on github
                r_input = re.sub(image_regex2,"![image]("+arguments.FirstLink[:-7]+str(ii).zfill(3)+".png?raw=true)",r_input)
                                
                i += 2
                ii+= 2
            
            

    return(r_input)

main()

# Still need to change the data set to just be the pngs!