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
    # Create a list of oks for password in Windows
    password_complexity_req = string.ascii_letters + string.digits + '~!@#$%^&*_-+=`|\(){}[]:;"\'<>.?/'
    return_str = ''.join(random.choice(password_complexity_req) for i in range(length))
    return return_str

def main(args):
    try:
        # with open('files/windows/userandgroups.csv.vault', 'r') as file, open("./usersgroupspasswords.csv.vault","w") as nfile:
        with open(args.inputcsv, 'r') as file, open(args.outputcsv,"w") as nfile:
            read_file = csv.DictReader(file)
            # newfile = csv.DictWriter(open("./usersgroupspasswords.csv","w"),fieldnames=read_file.fieldnames + ['Password'])
            newfieldnames = read_file.fieldnames + ['Password']
            newfile = csv.DictWriter(nfile,newfieldnames)
            newfile.writeheader()
            for r in read_file:
                r['Password'] = random_password(16)
                newfile.writerow(r)
    except Exception as e:
        print(e)

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
