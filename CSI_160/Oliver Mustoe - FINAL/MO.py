# Menu

from os.path import exists
import sys
import CC

# Blank variable where a loaded csv would live
loaded_file_name = ''


def menu():
    """
    Main menu which is served to the user to choose user operations
    :return: None
    """
    while True:
        global loaded_file_name
        print('Welcome to Oliver\'s quiz maker!\n'
              'Please input a number for one of the following options:\n'
              '1. Make quiz\n'
              '2. Load quiz\n'
              '3. Edit quiz (MUST HAVE ONE LOADED)\n'
              '4. Take quiz (MUST HAVE ONE LOADED)\n'
              'Other. Exit program', end='')
        if loaded_file_name != '':
            print(f'\nCurrently loaded file is "{loaded_file_name}.csv"\n')
        else:
            print('\n')

        user_i = input('Inputted option: ')

        # If statements depending on user choice
        if user_i == '1':
            CC.make_quiz()
        elif user_i == '2':
            # Get a name for a loaded file and '.csv'
            temp_f_name = input('Please enter the name of the file to load (NO ".csv" IN NAME): ')
            # If the file exists as csv, then make it the loaded file, if not, print that the file is not found
            # From https://www.pythontutorial.net/python-basics/python-check-if-file-exists/
            if exists(temp_f_name + '.csv'):
                loaded_file_name = temp_f_name
                print('\nFILE LOADED\n')
            else:
                print('\nFILE NOT FOUND\n')
        elif user_i == '3':
            if loaded_file_name != '':
                CC.edit_quiz(loaded_file_name)
            else:
                print('\nPLEASE INSERT A FILE!!\n')
        elif user_i == '4':
            if loaded_file_name != '':
                CC.take_quiz(loaded_file_name)
            else:
                print('\nPLEASE INSERT A FILE!!\n')
        else:
            sys.exit()


menu()
