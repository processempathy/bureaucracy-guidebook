#!/usr/bin/env python3

"""
To use this file,

    python3 find_duplicate_phrases.py 

which produces output like

    character count: 852293
    word count 101871
    "person at the top of the hierarchy does" is at 2279 and 2267
    "at the top of the hierarchy does not" is at 2280 and 2268

The integers are the position in the string.

Once the string is identified, the next step is to find the duplicate strings in .tex files using something like

    grin "of an organization is" latex/*.tex

To find duplicate strings in .pdf files,

    docker run -it --rm -v `pwd`:/scratch -w /scratch/ latex_debian pdfgrep "of an organization is" /scratch/bin/bureaucracy_main_pdf_for_printing_and_binding_with_cover.pdf

"""

import glob
import re

def contains(small: list, big: list):
    """ find the first match of "small" in "big"
    from https://stackoverflow.com/a/3847585/1164295
    """
    for i in range(len(big)-len(small)+1):
        for j in range(len(small)):
            if big[i+j] != small[j]:
                break
        else:
            return i, i+len(small)
    return False

if __name__ == "__main__":
    list_of_tex_files = glob.glob("latex/*.tex")


    all_file_content = " "
    for this_filename in list_of_tex_files:
        with open(this_filename, 'r') as file_handle:
            file_content = file_handle.read()
        all_file_content += file_content
        all_file_content += " "

    all_file_content.replace("\n"," ")

    print("character count:",len(all_file_content))

    all_file_content_list = all_file_content.split(" ")

    # remove empty strings from list as per https://stackoverflow.com/a/3845453/1164295
    all_file_content_list = list(filter(None, all_file_content_list))

    print("word count", len(all_file_content_list))

    #print(all_file_content_list[:200])

    # TODO: make this an argument
    ngram_length = 8 # window size

    for initial_word_index in range(0,len(all_file_content_list)):
        phrase_list = all_file_content_list[initial_word_index:initial_word_index+ngram_length]
        #print(phrase_list)
        if len(phrase_list)==ngram_length: # the end of the search results in lists shorter than ngram_length
            result = contains(phrase_list, all_file_content_list)
            if result:
                if result[0]!=initial_word_index:
                    list_as_string=" ".join(phrase_list)
                    if "LONG" not in list_as_string:
                        print('"'+list_as_string+'" is at '+str(initial_word_index),"and",result[0])


#EOF
