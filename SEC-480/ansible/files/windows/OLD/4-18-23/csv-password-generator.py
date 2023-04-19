# maybe add argparse for reusability
import csv
import string
import random
import argparse

def args():
    """
    A function to gather arguments for parsing
    :return: args: Populated namespace of argument values
    """
    # Setup basic parser
    arg_parser = argparse.ArgumentParser(
        prog="csv-password-generator",
        description="CLI tool to add a password column to a csv"
    )

    # Add arguments
    arg_parser.add_argument(
     "-i","--inputcsv",
     help="path to csv containing the info you want to add a password column to"
    )

    arg_parser.add_argument(
     "-o","--outputcsv",
     help="path to output csv (can not exist as script will make it)"
    )

    # Parse the arguments then return namespace object
    args = arg_parser.parse_args()

    return args

def random_password(length):
    # Create a list of ok characters for passwords in Windows
    password_complexity_req = string.ascii_letters + string.digits + '~!@#$%^&*_-+=`|\(){}[]:;"\'<>.?/'

    # For the length, join a random character from the complexity req, return that new string
    return_str = ''.join(random.choice(password_complexity_req) for i in range(length))
    return return_str

def main(args):
    try:
        # Open 2 files, 1 where the csv that contains the data is and one where the data will be outputted
        with open(args.inputcsv, 'r') as file, open(args.outputcsv,"w") as nfile:
            # Created a Dictreader object
            read_file = csv.DictReader(file)

            # Get the fieldnames from the reader object, add 'Password', (need the new file to have the field since that is where we are writing to)
            newfieldnames = read_file.fieldnames + ['Password']

            # Create a Dictwriter object of the outputted file, use the fieldnames of made above
            newfile = csv.DictWriter(nfile,newfieldnames)

            # Write the fieldnames (same as header)
            newfile.writeheader()

            # Go through each of the rows in the Dictreader
            for r in read_file:
                # Add a new key, 'Password', that is set to a random 16 length string
                r['Password'] = random_password(16)

                # Write a new row in the new file inculding the fields Name,Group,Password
                newfile.writerow(r)
    except Exception as e:
        print(e)

# Check if being executed as a script, if so run args and main function
if __name__ == "__main__":
    args = args()
    main(args)

# some sources
# https://stackoverflow.com/questions/4872077/how-to-add-a-new-column-to-the-beginning-of-the-rows-of-a-csv-file
# https://stackoverflow.com/questions/16794875/python-writing-dictreader-to-csv-file
# https://www.freecodecamp.org/news/with-open-in-python-with-statement-syntax-example/
# https://stackoverflow.com/questions/9050355/using-quotation-marks-inside-quotation-marks
# https://pynative.com/python-generate-random-string/
# https://docs.python.org/3/library/csv.html
# https://www.geeksforgeeks.org/load-csv-data-into-list-and-dictionary-using-python/
