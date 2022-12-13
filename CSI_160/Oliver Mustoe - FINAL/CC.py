# Making the quiz

import pyexcel
import random


def make_quiz():
    """
    Allows the user to make a quiz
    :return: None
    """
    print('\nTutorial: In making a quiz, you will first give your quiz a name. After, you will create at least 1'
          ' slide\n'
          'in your quiz deck, where you will be asked for a question, right answer, and other answers that will be\n'
          'supplied. You will then have the ability to keep creating more slides for your deck. After you are\n'
          'finished, export the quiz to a CSV file.\n')

    # Setup some base variables needed for quiz making
    quiz_count = 1

    quiz_slides = []

    quiz_name = input('Please enter the name of your quiz: ')

    while True:
        # Make a slide
        slide = slider_maker(quiz_count)

        # Append it
        quiz_slides.append(slide)

        # Ask for more input and act on a yes or no
        more_slides = input('Do you wish to create another slide? [y/N]: ')

        if more_slides.lower() == 'y':
            quiz_count += 1
            continue
        else:
            # If the user is done creating the quiz and wants to export it
            user_ii = input('Do you wish to save and export quiz? WARNING: answering no will destroy the quiz!!! '
                            '[y/N]: ')
            if user_ii.lower() == 'y':
                export_quiz(quiz_slides, quiz_name)
                print(f'\nQUIZ {quiz_name} SAVED!\n')
                break
            else:
                print('\nEXITING -- QUIZ DESTROYED\n')
                break


def edit_quiz(loaded_file_name):
    """
    Allows the user to edit a previously created quiz
    :param loaded_file_name: A string name of the file being edited
    :return: None
    """
    print('\nTutorial: In editing a quiz, you will first give the number of the question you wish to edit. Then\n'
          'prompts will appear which will guide you in the re-creation of that question.')

    nloaded_file_name = loaded_file_name + '.csv'

    try:
        # From https://docs.pyexcel.org/en/latest/sheet.html
        # https://docs.pyexcel.org/en/latest/generated/pyexcel.Sheet.html?highlight=%22to_records%22
        # Load the written quiz data, also convert into a generator object to parse
        loaded_quiz = pyexcel.get_sheet(file_name=nloaded_file_name, name_columns_by_row=0)
        record_of_quiz = pyexcel.Sheet.to_records(loaded_quiz)

        while True:
            print('\nWhich slide do you wish to edit?')
            # Try to parse the record of the generator object and print it, if not, print the exception and exit
            try:
                for slide in record_of_quiz:
                    print(f"{slide['slide_num']}: {slide['slide_Q']}")
            except Exception as e:
                print(e)
                return None

            user_change = input("Number of slide to change (blank to exit): ")

            # If the user did not enter a blank string... else exit
            if user_change != '':
                # If the user did not enter a 0...else echo that is wrong
                if user_change != '0':
                    # Try to subtract 1 from the user_change variable
                    try:
                        # -1 to accommodate for the sheet starting at 0
                        user_change_true = int(user_change) - 1
                        break
                    except Exception as e:
                        print(e, '-- INPUT MUST BE A NON-ZERO NUMBER')
                else:
                    print('\nERROR: ZERO IS NOT A SLIDE NUMBER!\n')
            else:
                print()
                return None

        n_row = []
        # Create a dictionary of new slide information in an expected output
        slide = slider_maker(user_change)

        # Gather all the values from the dictionary, append to n_row
        for value in slide.values():
            # Get all the value in the correct order
            n_row.append(value)

        # Make the row the values of the dictionary
        loaded_quiz.row[user_change_true] = n_row

        # Export the newly changed quiz
        export_quiz(loaded_quiz.to_records(), loaded_file_name)

        print(f'\nQUIZ "{loaded_file_name}" EDITED!\n')
    except Exception as e:
        print(f'\n{e}')
        print('MAKE SURE TO DOUBLE CHECK THAT CSV HAS CORRECT INFO (WAS IT CREATED WITH THIS PROGRAM?)\n')


def take_quiz(loaded_file_name):
    """
    Allows user to take a quiz
    :return: None
    """

    print('\nTutorial: In taking a quiz, you will be asked a series of questions where you will answer it with a\n'
          'numerical input corresponding to that answers number. Afterwards, it will be reported if you got the\n'
          'question right or wrong. At the end of the quiz, you percentage on the quiz will be displayed for you!')
    r_answers = 0
    w_answers = 0
    loaded_file_name = loaded_file_name + '.csv'
    # Load the written quiz data as a generator object to parse
    loaded_quiz = pyexcel.iget_records(file_name=loaded_file_name)
    # Try to see if the data can be parsed with a for loop
    try:
        for slide in loaded_quiz:
            # Make the string list into an actual list
            slide['slide_all_ans'] = eval(slide['slide_all_ans'])
            # From https://smallbusiness.chron.com/randomize-list-python-26724.html
            # Randomize the order of the list
            random.shuffle(slide['slide_all_ans'])

            # Show a quiz slide with the data from the loaded slide
            empty_slide(slide)

            while True:
                try:
                    user_answer = int(input('What is the right answer (A1 = 1): ')) - 1
                    break
                except Exception as e:
                    print(e, '-- INPUT MUST BE A NON-ZERO NUMBER')

            # From https://www.programiz.com/python-programming/methods/list/index
            # See if the users answer equals the index of the right answer in the entire answer pool
            if user_answer == slide['slide_all_ans'].index(slide['slide_right_ans']):
                print('CORRECT')
                r_answers += 1
            else:
                print('INCORRECT')
                w_answers += 1
                # continue
        # From https://blog.finxter.com/how-to-print-a-percentage-value-in-python/
        # Make a percentage and give it to the user
        print(f'\nYou got a {(r_answers / (r_answers + w_answers)):.0%} on the quiz!\n')
    except Exception as e:
        print(f'\n{e}')
        print('MAKE SURE TO DOUBLE CHECK THAT CSV HAS CORRECT INFO (WAS IT CREATED WITH THIS PROGRAM?)\n')


def export_quiz(quiz_slides, quiz_name):
    """
    Takes the quiz and exports it to a CSV file
    :param quiz_slides: A list of all the slides dictionaries
    :param quiz_name: String of the quiz's name
    :return: None
    """
    # Add '.csv' to quiz_name
    quiz_name = quiz_name + '.csv'

    # Credit goes to the following for pyexcel:
    # https://stackoverflow.com/questions/41795296/python-write-a-list-of-dictionaries-to-csv
    # https://docs.pyexcel.org/en/latest/

    # Try to save the quiz to a CSV file, if errors are run into in the file saving process, print them to screen
    try:
        pyexcel.save_as(records=quiz_slides, dest_file_name=quiz_name)
        pyexcel.free_resources()
    except Exception as e:
        print(e)

    pass


def slider_maker(quiz_count):
    """
    Creates slides for a quiz
    :param quiz_count: A integer of what question this is asking
    :return: A dictionary with expected information for a slide
    """
    while True:
        # First answer at this stage will always be right
        answers = []

        # Gather question and answers as well as a right answer
        print(f'\nPlease enter the question slide {quiz_count} will ask: ')
        slide_question = input()

        answers.append(input('Please write what the correct answer to the above question is: '))

        while True:
            user_f_ans = input('Please enter in false answers to the question above (enter nothing to exit): ')

            if user_f_ans != '':
                answers.append(user_f_ans)
            else:
                break

        # Create a dictionary of expected output
        slide_all = [slide_question, answers]
        slides_set = slide_setter(slide_all, quiz_count)

        # Ensure the user likes the input, if they do, ask if they want another slide
        print('Does the following look correct? (NOTE: Answers will be randomized when the test is taken!)')

        empty_slide(slides_set)

        user_i_final = input('Look correct? [y/N] (\'n\' will restart this slides creation): ')

        if user_i_final.lower() == 'y':
            # If user likes the slide, append setter output to the overall quiz
            return slides_set
        else:
            continue


def slide_setter(user_inp_list, num):
    """
    Takes a list of user input and creates a dictionary that is in the expected format for exporting/importing
    :param user_inp_list: A list of user inputs (0=question, 1=right answer, 2+=wrong answers)
    :param num: A integer of what slide this is
    :return: A dictionary including the slide number, question, randomized answer list, and the right answers value
    """
    # Expected format
    ndict = {'slide_Q': user_inp_list[0],
             'slide_all_ans': user_inp_list[1],
             'slide_num': num,
             'slide_right_ans': user_inp_list[1][0]
             }
    return ndict

    pass


def empty_slide(slide_to_load):
    """
    Takes a dictionary input of expected data and prints a slide
    :param slide_to_load: Dictionary in expected data form
    :return:
    """
    print(f'--------------------------------------\n'
          f"Question {slide_to_load['slide_num']}: {slide_to_load['slide_Q']}")
    count_num = 1
    for i in slide_to_load['slide_all_ans']:
        print(f'A{count_num}: {i}')
        count_num += 1

    print('--------------------------------------')
