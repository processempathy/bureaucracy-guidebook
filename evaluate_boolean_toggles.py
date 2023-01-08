#!/usr/bin/env python3

import glob
import re

"""
 Pandoc doesn't interpret "\iftoggle{}"
 so this script finds the definition in main.tex
 and then rewrites .tex files use the definitions

To define a toggle,

    \newtoggle{name}

to use the toggle,

    \togglefalse{name}

and the use looks like

    \iftoggle{name}{<true>}{<false>}

"""

main_file = "latex/main.tex"

with open(main_file,'r') as file_handle:
    file_content_as_list = file_handle.readlines()

list_of_toggles=[]
for file_line in file_content_as_list:
    if file_line.strip().startswith("%"):
        continue # go to next iteration in loop
    if file_line.strip().startswith("\\newtoggle"):
        list_of_toggles.append(file_line.strip().replace("\\newtoggle{","").replace("}",""))

toggle_values={}
for toggle in list_of_toggles:
    #print("current toggle: ",toggle)
    for file_line in file_content_as_list:
        if file_line.strip().startswith("%"):
            continue # go to next iteration in loop
        if ("{"+toggle+"}" in file_line) and (file_line.startswith("\\toggle")):
            boolean_value_of_toggle=file_line.strip().replace("{"+toggle+"}","").replace("\\toggle","")
            if boolean_value_of_toggle=="false":
                toggle_values[toggle]=False
            elif boolean_value_of_toggle=="true":
                toggle_values[toggle]=True

#print(toggle_values)

list_of_files = glob.glob("latex/*.tex")

list_of_replacements = []
for toggle_name, toggle_bool_value in toggle_values.items():
    #print("toggle=",toggle_name,"value=",toggle_bool_value)
    for file_name in list_of_files:
        if file_name==main_file:
            continue # go to next iteration in loop
        #print(file_name)
        with open(file_name,'r') as file_handle:
            file_content_as_list = file_handle.readlines()

        for file_line in file_content_as_list:
            if file_line.strip().startswith("%"):
                continue # go to next iteration in loop
            if toggle_name in file_line:
                #print(file_line.strip()) # \iftoggle{showminitoc}{\minitoc}{}
                up_to_choices = file_line.strip().replace("\iftoggle{"+toggle_name+"}{","")
                #print("  up_to_choices=",up_to_choices)
                if_true = up_to_choices.split("}{")[0].strip()
                if_false = up_to_choices.split("}{")[1][:-1].strip() # always drop the last character, }
                #print("  if true:", if_true)
                #print("  if false:", if_false)
                #print("   replace")
                #print("\iftoggle{"+toggle_name+"}{"+if_true+"}{"+if_false+"}")
                #print("   with")
                if toggle_bool_value:
                    #print(if_true)
                    replace_with=if_true
                else:
                    #print(if_false)
                    replace_with=if_false

                list_of_replacements.append(
                    {"file name": file_name,
                     "to replace": "\iftoggle{"+toggle_name+"}{"+if_true+"}{"+if_false+"}",
                     "replace with": replace_with})

for replacement_dict in list_of_replacements:
    with open(replacement_dict["file name"], 'r') as file_handle:
        file_content = file_handle.read()

    file_content.replace(replacement_dict["to replace"],replacement_dict["replace with"])

     with open(replacement_dict["file name"], 'w') as file_handle:
         file_handle.write(file_content)
         
