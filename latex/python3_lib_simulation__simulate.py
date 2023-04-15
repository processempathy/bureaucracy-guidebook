def simulate(skill_set_for_tasks:list,
             max_skill_level_per_task: int,
             max_ticks_to_simulate: int,
             max_task_duration_in_ticks:int,
             social_circle_size: int,
             list_of_people: list,
             show_narrative:bool,
             work_journal:bool):
    """
    primary function for time evolution of model
    https://en.wikipedia.org/wiki/Agent-based_model
    """
    tasks_dict = {}
    tick=-1
    while ((tick<max_ticks_to_simulate)):
        tick=tick+1
        if show_narrative: print('\n===== tick',tick,'=====')
        if show_narrative: print("   ===== status at the leading edge of this tick: =====")
        if show_narrative: current_status_of_people(list_of_people)
        if show_narrative: print("   ===== updates happening in this tick: =====")
        # each person looks in their backlog for work
        for person_index in range(len(list_of_people)):
            skill_dict = list_of_people[person_index].skill_specialization_dict
            if show_narrative: print("person",person_index,'has skills',skill_dict)

            # initialize the work journal
            if work_journal:
                list_of_people[person_index].work_journal_per_tick[tick] = {'number of tasks in backlog':
                                                     len(list_of_people[person_index].backlog_of_tasks)}
            if show_narrative: print("   person",
                                     person_index,"has backlog length",
                                     len(list_of_people[person_index].backlog_of_tasks))

            # make sure the idle people get assigned work
            if list_of_people[person_index].status=="idle":
                if work_journal:
                    list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                assert(list_of_people[person_index].assigned_task is None)
                if len(list_of_people[person_index].backlog_of_tasks)>0:
                    # new tasks get appended, so the oldest task is at position 0
                    list_of_people[person_index].assigned_task = list_of_people[person_index].backlog_of_tasks.pop(0)
                    if show_narrative: print("   person",
                                             person_index,"got task from their backlog")
                    if show_narrative: print("      task is",
                                             list_of_people[person_index].assigned_task)
                    if work_journal:
                        list_of_people[person_index].work_journal_per_tick[tick]['task from'] = 'my own backlog'
                else: # pop from empty list
                    if len(tasks_dict)==0: 
                        task_id = 0
                    else:
                        task_id = max(tasks_dict.keys())+1
                    tasks_dict = new_task(task_id,
                                          skill_set_for_tasks,
                                          max_skill_level_per_task,
                                          max_task_duration_in_ticks,
                                          tasks_dict)
                    list_of_people[person_index].assigned_task = tasks_dict[task_id]
                    if show_narrative: print("   person",
                                             person_index,"had no tasks in backlog; got new task from infinite queue")
                    if show_narrative: print("      task consists of",
                                             list_of_people[person_index].assigned_task)
                    if work_journal:
                        list_of_people[person_index].work_journal_per_tick[tick]['task from'] = 'infinite backlog'

            # at this point, regardless of status, the person has a task
            if not list_of_people[person_index].assigned_task:
                print('social_circle_size:',social_circle_size)
                print('max_task_duration_in_ticks:',max_task_duration_in_ticks)
                print('tick:',tick)
                print('tasks_dict:',tasks_dict)
                for person in list_of_people:
                    print('ID:',person.unique_id)
                    print('backlog',person.backlog_of_tasks)
                    print('task:',person.assigned_task)
                    print('status:',person.status)
                    print('skill_specialization_dict:',person.skill_specialization_dict)
                raise Exception("person",person_index,"should have a task")

            my_task = list_of_people[person_index].assigned_task
            if show_narrative:
                print("   person",person_index,"has an assigned task",my_task)
            if work_journal:
                list_of_people[person_index].work_journal_per_tick[tick]['task'] = my_task

            # can the person do the task, or do they need to coordinate?
            if (my_task['skill level'] <= skill_dict[my_task['specialization']]): # person can do task
                if show_narrative: print("   person",person_index,"can do the task!")
                list_of_people[person_index].status="working"
                if work_journal:
                    list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                if work_journal:
                    list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "working"
            else: # person doesn't have sufficient skill for task; person needs to find someone else
                if show_narrative: print("   person",person_index,"does not have sufficient skill")
                list_of_people[person_index].status="coordinating"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "coordinating"

            # no person is idle
            assert((list_of_people[person_index].status=="working") or
                   (list_of_people[person_index].status=="coordinating"))

            if list_of_people[person_index].status=="working":
                speedup = skill_dict[my_task['specialization']]/my_task['skill level']
                if show_narrative: print("   speedup for person",person_index,"is", speedup)
                list_of_people[person_index].assigned_task['remaining'] = my_task['remaining'] - speedup # "doing the work"
                if (list_of_people[person_index].assigned_task['remaining']<=0): # task was completed
                    if show_narrative: print("   task completed!")
                    list_of_people[person_index].assigned_task = None
                    list_of_people[person_index].status="idle"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "task completed"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                else: # update the task to reflect there being less work remaining because the person did some work
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "worked but task remains"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "working"
                    pass

            if list_of_people[person_index].status=="coordinating":
                contacts = list_of_people[person_index].contact_list
                if show_narrative: print("   person",person_index,"contacts=",contacts)
                if len(contacts)>0: # I know people!
                    if show_narrative: print("   person",person_index,"looks in contact list")
                    for contact_id in contacts: # do the people I know have the skills to do this task?
                        contacts_skill_dict = list_of_people[contact_id].skill_specialization_dict
                        if (my_task['skill level'] <= contacts_skill_dict[my_task['specialization']]): # contact can do task
                            list_of_people[contact_id].backlog_of_tasks.append(list_of_people[person_index].assigned_task)
                            list_of_people[person_index].assigned_task = None
                            list_of_people[person_index].status = "idle" # next tick will get new task from my own backlog or infinite backlog
                            if show_narrative: print("   person",person_index,"gave task to person",
                                                     contact_id,"from contact list")
                            if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = (
                                    "gave task to person "+str(contact_id)+" from contact list")
                            if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                            break
                # after looking through contacts, if the status is still "coordinating",
                # then person didn't have a contact who could do the work
                if list_of_people[person_index].status=="coordinating":
                    another_person_id = pick_a_random_person(person_index, contacts, list_of_people)
                    another_person_skill_dict = list_of_people[another_person_id].skill_specialization_dict
                    if (my_task['skill level'] <= another_person_skill_dict[my_task['specialization']]): # another_person can do task
                        list_of_people[another_person_id].backlog_of_tasks.append(my_task)
                        list_of_people[person_index].assigned_task = None
                        list_of_people[person_index].status = "idle"
                        if show_narrative: print("   person",
                                                 person_index,"gave task to person",
                                                 another_person_id,"from random search")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = (
                            "gave task to person "+str(another_person_id)+" from random search")

                        list_of_people[person_index].add_person_to_contact_list(another_person_id, social_circle_size)
                        if show_narrative: print("   person",person_index,"added",another_person_id,"to list of contacts")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                    else:
                        if show_narrative: print("   person",person_index,"not able give to",
                                                 another_person_id,"from random search")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = (
                            "not able to give to person "+str(another_person_id)+" from random search")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = (
                            "coordinating")

    return list_of_people, tasks_dict